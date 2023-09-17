import 'dart:collection';
import 'dart:convert';
import 'package:hcm/screens/Loginpage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../widgets/footer.dart';
import '../widgets/positioned_button.dart';
import '../widgets/right_drawer.dart';
import '../widgets/square_button.dart';
import '../widgets/user_drawer.dart';
import 'package:get/get.dart';
import 'app_bar.dart';
import 'leave_page.dart';
import 'package:connectivity/connectivity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LandingPage extends StatefulWidget {
  final Map<String, String> userData;

  LandingPage({required this.userData});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Position? currentPosition;
  DateTime? checkInTime;
  DateTime? checkOutTime;
  bool isCheckInDisabled = false;
  bool isCheckOutDisabled = false;
  ConnectivityResult? connectivityResult;
  final Queue<Function> apiCallQueue = Queue<Function>();
  bool isInternetConnected = false;
  List<Map<String, dynamic>> offlineResponses = [];
  

 @override
void initState() {
  super.initState();
  Connectivity().onConnectivityChanged.listen((result) {
    setState(() {
      connectivityResult = result;
      isInternetConnected = result != ConnectivityResult.none;
    });
    // Check for saved check-in details when connectivity is restored
    if (isInternetConnected) {
      while (apiCallQueue.isNotEmpty) {
        final apiCall = apiCallQueue.removeFirst();
        apiCall(); // Execute pending API calls
      }
    }
    
    // Submit offline responses when connected
    submitOfflineResponses();
  });
}


void saveOfflineResponse(Map<String, dynamic> response) {
    offlineResponses.add(response);
    print("Offline response added: $response"); // Added print statement
    
  }

    Future<String?> getTokenFromSharedPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  print('Token from SharedPreferences: $token'); // Add this line for debugging
  return token;
}

Future<String?> getEmployeeNameFromSP() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  return prefs.getString('employee_name');
}

Future<String?> getEmployeeDesignationFromSP() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('employee_designation');
}


void logout(BuildContext context) async {
  // Show a confirmation dialog
  bool confirm = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Confirm Logout"),
        content: Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // User confirmed logout
            },
            child: Text("Yes"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // User canceled logout
            },
            child: Text("No"),
          ),
        ],
      );
    },
  );

  if (confirm == true) {
    try {
      // Remove the token from shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');

      // Navigate to the LoginPage
      Get.offAll(LoginPage()); // Replace '/login' with your login route
    } catch (e) {
      // Handle any errors that may occur during logout
      print('Error during logout: $e');
    }
  }
}




Future<void> FinalCheckIn() async {
  // Check for internet connectivity
  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
    // User is not connected to the internet, store the response
    final offlineResponse = {
      "checkin": 1,
      "formatted_date": DateTime.now().toLocal().toString().split('.').first,
    };
    saveOfflineResponse(offlineResponse);
    Get.snackbar(
      "Check-In",
      "Check-In response stored offline.",
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: Duration(seconds: 1),
    );
    return;
  } else {
    // If connected to the internet, make the API call
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final location_latitude = prefs.getString('location_latitude');
    final location_longitude = prefs.getString('location_longitude');

    print('location_latitude: $location_latitude');
    print('location_latitude: $location_longitude');

    if (location_latitude != null && location_longitude != null) {
      Position? newPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Calculate the distance between user's current location and the desired location
      double userLatitude = newPosition.latitude;
      double userLongitude = newPosition.longitude;

      double desiredLatitude = double.tryParse(location_latitude) ?? 0.0;
      double desiredLongitude = double.tryParse(location_longitude) ?? 0.0;

      double distanceInMeters = Geolocator.distanceBetween(
        userLatitude,
        userLongitude,
        desiredLatitude,
        desiredLongitude,
      );

      if (distanceInMeters <= 300) {
        MakeCheckInCall();
      } else {
        Get.snackbar(
          "Wrong location",
          "You are not in the radius of your desired location",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 1),
        );
      }
    } else {
      Get.snackbar(
        "Wrong location",
        "Location data is missing in the response.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 1),
      );
    }
  }
}
  
 Future<void> FinalCheckOut() async {
  if (isCheckOutDisabled) {
    return;
  }

  // Check for internet connectivity
  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
    // User is not connected to the internet, store the response
    offlineResponses.add({
      "checkout": 1,
      "formatted_date": DateTime.now().toLocal().toString().split('.').first,
    });
    Get.snackbar(
      "Check-out",
      "Check-out response stored offline.",
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: Duration(seconds: 1),
    );
    return;
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final location_latitude = prefs.getString('location_latitude');
  final location_longitude = prefs.getString('location_longitude');

  print('location_latitude: $location_latitude');
  print('location_latitude: $location_longitude');

  if (location_latitude != null && location_longitude != null) {
    Position? newPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Calculate the distance between user's current location and the desired location
    double userLatitude = newPosition.latitude;
    double userLongitude = newPosition.longitude;

    double desiredLatitude = double.tryParse(location_latitude) ?? 0.0;
    double desiredLongitude = double.tryParse(location_longitude) ?? 0.0;

    double distanceInMeters = Geolocator.distanceBetween(
      userLatitude,
      userLongitude,
      desiredLatitude,
      desiredLongitude,
    );

    if (distanceInMeters <= 300) {
      checkOut();
    } else {
      Get.snackbar(
        "Wrong location",
        "You are not in the radius of your desired location",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 1),
      );
    }
  } else {
    Get.snackbar(
      "Wrong location",
      "Location data is missing in the response.",
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: Duration(seconds: 1),
    );
  }
}


  // Function to submit stored responses when internet connectivity is available
   Future<void> submitOfflineResponses() async {
  if (isInternetConnected && offlineResponses.isNotEmpty) {
    try {
      const String apiUrl = "http://iilhcm.ismailglobal.com/api/v1/offline-attendance";
      String? token = await getTokenFromSharedPreferences();

      if (token == null) {
      
         Get.snackbar(
  "No Token",
  "User not logged in.",
  backgroundColor: Colors.red, // Customize the background color
  colorText: Colors.white, // Customize the text color
  duration: Duration(seconds: 1), // Adjust the duration as needed
);
        return;
      }

      printOfflineResponses();
      
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers['Bearer-Token'] = token;

      // Create a List of Map for the attendance_object
      List<Map<String, dynamic>> attendanceObject = offlineResponses.map((response) {
        return {
          if (response.containsKey('checkin')) 'checkin': 1,
          if (response.containsKey('checkout')) 'checkout': 1,
          'formatted_date': response['formatted_date'],
        };
      }).toList();

      // Convert the List to JSON and add it as a Multipart field
      final attendanceObjectJson = jsonEncode(attendanceObject);
      request.fields['attendance_object'] = attendanceObjectJson;

      var response = await request.send();

      if (response.statusCode == 200) {
        // Parse the response, if necessary
        final responseString = await response.stream.bytesToString();
        final Map<String, dynamic> jsonResponse = jsonDecode(responseString);

        final bool status = jsonResponse['status'];
        final String message = jsonResponse['message'];

        print("Offline Submission Status: $status");
        print("Offline Submission Message: $message");

        if (status) {
          offlineResponses.clear(); // Clear stored responses on successful submission
          
             Get.snackbar(
  "Offline Response Update",
  "Offline responses submitted successfully.",
  backgroundColor: Colors.green, // Customize the background color
  colorText: Colors.white, // Customize the text color
  duration: Duration(seconds: 1), // Adjust the duration as needed
);
        } else {
         
            Get.snackbar(
  "Offline Response Update",
  "Failed to submit offline responses.",
  backgroundColor: Colors.green, // Customize the background color
  colorText: Colors.white, // Customize the text color
  duration: Duration(seconds: 1), // Adjust the duration as needed
);
        }
      } else {
        // Handle the error response
        print("Error submitting offline responses. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error submitting offline responses: $e");
    }
  }
}
  

  @override
  void dispose() {
    // Dispose of the connectivity stream when the widget is disposed
    Connectivity().onConnectivityChanged.listen(null).cancel();
    super.dispose();
  }
  
void printOfflineResponses() {
  for (int i = 0; i < offlineResponses.length; i++) {
    print("Offline Response $i: ${offlineResponses[i]}");
  }
}
 

Future<void> MakeCheckInCall() async {
  final String apiUrl = "http://iilhcm.ismailglobal.com/api/v1/checkinattendance";
 // final data = widget.userData['userId'];
  
  // Get the token from shared preferences
  String? token = await getTokenFromSharedPreferences();

  if (token == null) {
    // Handle the case where the token is not available (user not logged in)
    Get.snackbar(
  "No Token",
  "User not logged in.",
  backgroundColor: Colors.red, // Customize the background color
  colorText: Colors.white, // Customize the text color
  duration: Duration(seconds: 1), // Adjust the duration as needed
);
    return;
  }

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      "Bearer-Token": "$token", // Include the token in the "Bearer-Token" header
    },
  );

final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    final bool status = jsonResponse['status'];
    final String message = jsonResponse['message'];
    print("Status: $status");
    print("Message: $message");

  if (status) {
   Get.snackbar(
  "Response",
  "$message",
  backgroundColor: Colors.green, // Customize the background color
  colorText: Colors.white, // Customize the text color
  duration: Duration(seconds: 1), // Adjust the duration as needed
);
  } else {
    Get.snackbar(
  "Response",
  "$message",
  backgroundColor: Colors.red, // Customize the background color
  colorText: Colors.white, // Customize the text color
  duration: Duration(seconds: 1), // Adjust the duration as needed
);
  }
}

    // Function to save check-in details locally
    // Future<void> saveCheckInDetailsLocally() async {
    //   SharedPreferences prefs = await SharedPreferences.getInstance();
    //   prefs.setString("currLat", currentPosition!.latitude.toString());
    //   prefs.setString("currLong", currentPosition!.longitude.toString());

    // }

    
      Future<void> checkOut() async {
        

        final String apiUrl = "http://iilhcm.ismailglobal.com/api/v1/checkoutattendance";
 // final data = widget.userData['userId'];
  
  // Get the token from shared preferences
  String? token = await getTokenFromSharedPreferences();

  if (token == null) {
    // Handle the case where the token is not available (user not logged in)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("User not logged in."),
      ),
    );
    return;
  }

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      "Bearer-Token": "$token", // Include the token in the "Bearer-Token" header
    },
  );

final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    final bool status = jsonResponse['status'];
    final String message = jsonResponse['message'];
    print("Status: $status");
    print("Message: $message");
  if (status) {
   Get.snackbar(
  "Response",
  "$message",
  backgroundColor: Colors.green, // Customize the background color
  colorText: Colors.white, // Customize the text color
  duration: Duration(seconds: 1), // Adjust the duration as needed
);
  } else {
    Get.snackbar(
  "Response",
  "$message",
  backgroundColor: Colors.red, // Customize the background color
  colorText: Colors.white, // Customize the text color
  duration: Duration(seconds: 1),
   // Adjust the duration as needed
);
  }

      }

       @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: Text(
          "Home",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.menu), // Drawer icon
          onPressed: () {
            // Open the drawer
            Scaffold.of(context).openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout), // Logout icon
            onPressed: () {
              logout(context);
              // Handle logout button tap
              // You can implement your logout logic here
            },
          ),
        ],
      ),
      drawer: Drawer(
        // Define your drawer contents here
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Drawer Header',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Item 1'),
              onTap: () {
                // Handle item 1 tap
              },
            ),
            ListTile(
              title: Text('Item 2'),
              onTap: () {
                // Handle item 2 tap
              },
            ),
            // Add more drawer items as needed
          ],
        ),
      ),
      body: Stack(
        children: [
          // Background Image
          Image.asset(
            'assets/images/blue.jpg',
            fit: BoxFit.cover, // Adjust this to your needs
            width: double.infinity,
            height: double.infinity,
          ),
          // Container(
          //   color: Colors.blue.shade900.withOpacity(0.8), // Overlay color
          // ),
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // User Profile Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // User Profile Image (Icon)
                      // User Profile Image (Icon) with blue border and slight curve
Column(
  children: [
    ClipRRect( // Wrap the Container with ClipRRect
      borderRadius: BorderRadius.circular(8), // Adjust the border radius as needed
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.blue, // Blue border color
            width: 2.0,
          ),
        ),
        child: Icon(
          Icons.person, // Replace with the user's icon
          size: 100,
          color: Colors.white, // Icon color
        ),
      ),
    ),
    SizedBox(height: 5),
    ElevatedButton.icon(
      onPressed: () {
        // Handle View Profile button tap
      },
      icon: Icon(Icons.person),
      label: Text("View Profile"),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(85, 28),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        primary: Colors.blue,
      ),
    ),
  ],
),

                      
Column(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    // User Name
    // User Name
Container(
  child: Text(
    widget.userData['employee_name'] ?? "John Doe",
    style: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
    ),
  ),
),

    Divider( // Add a Divider widget
      color: Colors.grey, // Grey color
      height: 20, // Adjust the height as needed
      thickness: 5, // Adjust the thickness as needed
    ),
    // User Designation
    Container(
      child: Text(
        widget.userData['employee_designation'] ?? "Associate General Manager", // Replace with user's designation
        style: TextStyle(
          fontSize: 13,
                fontWeight: FontWeight.w400,

          color: Colors.white,
        ),
      ),
    ),
  ],
),

                    ],
                  ),
                  SizedBox(height: 20), // Add spacing between profile and buttons
                  // Buttons Section 1 (Sync Data and Attendance Location)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Sync Data Button
                      ElevatedButton.icon(
  onPressed: () {
    // Handle Sync Data button tap
  },
  icon: Icon(Icons.sync),
  label: Text("Sync Data"),
  style: ElevatedButton.styleFrom(
    elevation: 20, // Adjust the elevation as needed
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8), // Adjust the border radius as needed
    ),
    fixedSize: Size(150, 40),

    primary: Colors.blue, // Blue color
  ),
),

                      SizedBox(width: 6),
                      // Attendance Location Button
                      ElevatedButton.icon(
  onPressed: () {
    // Handle Attendance Location button tap
  },
  icon: Icon(Icons.location_on),
  label: Text("Attendance Locations"),
  style: ElevatedButton.styleFrom(
    elevation: 20, // Adjust the elevation as needed
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8), // Adjust the border radius as needed
    ),
    fixedSize: Size(150, 40),
    primary: Colors.blue, // Blue color
  ),
)

                    ],
                  ),
                  SizedBox(height: 20), // Add spacing between buttons
                  // Heading for CheckIn/CheckOut
          Container(
  margin: EdgeInsets.only(top: 15),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(15.0), // Adjust the border radius as needed
    child: Container(
      color: const Color.fromARGB(255, 252, 251, 251).withOpacity(0.2), // Light grey background color
      width: double.infinity, // Take up the whole screen width
      height: 90,
      child: Column(
        children: [
          Text(
            "My CheckIn/CheckOut",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10), // Add spacing below heading
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // CheckIn Button
              ElevatedButton(
                onPressed: () {
FinalCheckIn();
                },
                child: Text("CheckIn"),
                style: ElevatedButton.styleFrom(
                  elevation: 2, // Adjust the elevation as needed
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Adjust the border radius as needed
                  ),
                  fixedSize: Size(150, 45),
                  primary: Colors.blue, // Blue color
                ),
              ),
              // CheckOut Button
              ElevatedButton(
                onPressed: () {
                    FinalCheckOut();
                },
                child: Text("CheckOut"),
                style: ElevatedButton.styleFrom(
                  primary: Colors.grey, // Blue color
                  elevation: 2, // Adjust the elevation as needed
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Adjust the border radius as needed
                  ),
                  fixedSize: Size(150, 45),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
),

    SizedBox(height: 10), // Add spacing below heading

    // Buttons Section 3 (Leave, Salary, Loan, Attendance, News)

// Container(
//   alignment: Alignment.center,
//   padding: EdgeInsets.symmetric(vertical: 10), // Add padding for spacing
//   child: Row(
//     mainAxisAlignment: MainAxisAlignment.spaceAround, // Adjust this as needed
//     children: [
//       _buildCircularIconButton("Leave", Icons.local_offer, Colors.blue.withOpacity(0.7)),
//       _buildCircularIconButton("Salary", Icons.attach_money, Colors.blue.withOpacity(0.7)),
//       _buildCircularIconButton("Loan", Icons.money, Colors.blue.withOpacity(0.7)),
//       _buildCircularIconButton("Attendance", Icons.calendar_today, Colors.blue.withOpacity(0.7)),
//       _buildCircularIconButton("News", Icons.new_releases, Colors.blue.withOpacity(0.7)),
//     ],
//   ),
// ),


                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Calendar Icon and Date Range Text
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.white),
                          SizedBox(width: 5),
                          Text(
                            "From 26-08-2023 To 26-08-2023",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      // Refresh Button
                      IconButton(
                        icon: Icon(Icons.refresh, color: Colors.white),
                        onPressed: () {
                          // Handle refresh button tap
                        },
                      ),
                    ],
                  ),
                  // Buttons Section 4 (Leave, Absent, Off Day, Deputation, Present, Leave)
                 Container(
  margin: EdgeInsets.only(top: 10),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(15.0), // Adjust the border radius as needed
    child: Container(
      color: const Color.fromARGB(255, 252, 251, 251).withOpacity(0.4), // Light grey background color
      width: 150,
      child: Column(
        children: [
                    SizedBox(height: 10), // Add spacing between rows

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                            SizedBox(width: 7),
              Expanded(
                child: _buildRectangularButton("Leave", Icons.local_offer, () {
                  // Handle Leave button tap
                }),
              ),
              SizedBox(width: 7),
              Expanded(
                child: _buildRectangularButton("Absent", Icons.close, () {
                  // Handle Absent button tap
                }),
              ),
                            SizedBox(width: 7),

              Expanded(
                child: _buildRectangularButton("Off Day", Icons.calendar_today, () {
                  // Handle Off Day button tap
                }),
              ),
                            SizedBox(width: 7),

            ],
          ),
          SizedBox(height: 28), // Add spacing between rows
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                            SizedBox(width: 6),

              Expanded(
                child: _buildRectangularButton("Deputation", Icons.work, () {
                  // Handle Deputation button tap
                }),
              ),
                            SizedBox(width: 7),

              Expanded(
                child: _buildRectangularButton("Present", Icons.check, () {
                  // Handle Present button tap
                }),
              ),
                            SizedBox(width: 7),

              Expanded(
                child: _buildRectangularButton("Leave", Icons.local_offer, () {
                  // Handle Leave button tap (second one)
                }),
              ),
                            SizedBox(width: 7),

            ],
          ),
          SizedBox(height: 7),
        ],
      ),
    ),
  ),
)


                  // Add more content below if needed
                ],  
              ),
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildCircularIconButton(String label, IconData iconData, Color buttonColor) {
  double screenWidth = MediaQuery.of(context).size.width;
  double buttonWidth = (screenWidth - 40) / 5; // 40 is the total horizontal padding

  return Container(
    width: buttonWidth, // Adjust the width based on available space
    child: ElevatedButton(
      onPressed: () {
        // Handle button tap here
      },
      style: ElevatedButton.styleFrom(
        primary: buttonColor, // Button color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // Adjust the border radius as needed
        ),
        elevation: 2, // Adjust the elevation as needed
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Container for the circular icon
          Container(
            width: buttonWidth,
            height: 50.0, // Adjust the height as needed for the icon container
            child: Center(
              child: Container(
                width: 50.0, // Adjust the width as needed for the icon container
                height: 50.0, // Adjust the height as needed for the icon container
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue, // Adjust the color as needed
                ),
                child: Center(
                  child: Icon(
                    iconData,
                    size: 30.0, // Adjust the size as needed
                    color: Colors.white, // Adjust the color to match the button
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 5),
          // Text label
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildRectangularButton(String label, IconData iconData, Function onTap) {
  return ElevatedButton(
    onPressed: () {
      
    },
    style: ElevatedButton.styleFrom(
      primary: Color.fromARGB(240, 185, 177, 177), // Button color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7.0), // Adjust the border radius as needed
        side: BorderSide(color: Colors.blue, width: 2.0), // Blue border
      ),
      elevation: 2, // No elevation
      // Adjust the minWidth property to accommodate the content
      minimumSize: Size(0, 70), // Maintain the specified height
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          label, // Relevant text
          style: TextStyle(
            color: Colors.white,
            fontSize: 7,
          ),
        ),
                SizedBox(width: 5),
                        Icon(iconData, color: Colors.white),


      ],
    ),
  );
}

}