      import 'dart:collection';
import 'dart:convert';
  import 'package:permission_handler/permission_handler.dart';
      import 'package:flutter/material.dart';
      import 'package:geolocator/geolocator.dart';
      import 'package:fluttertoast/fluttertoast.dart';
      import '../widgets/footer.dart';
      import '../widgets/positioned_button.dart';
      import '../widgets/right_drawer.dart';
      import '../widgets/square_button.dart';
      import '../widgets/user_drawer.dart';
      import 'app_bar.dart';
      import 'leave_page.dart';
      import 'package:connectivity/connectivity.dart'; // Import the connectivity package
      import 'package:shared_preferences/shared_preferences.dart';
    import 'package:http/http.dart' as http;
    import 'package:xml/xml.dart' as xml;

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
      // Initialize connectivity and listen for changes
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
      });
    }

    Future<String?> getTokenFromSharedPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  print('Token from SharedPreferences: $token'); // Add this line for debugging
  return token;
}

 Future<void> FinalCheckIn() async {
    // Check for internet connectivity
    if (!isInternetConnected) {
      // User is not connected to the internet, store the response
      offlineResponses.add({
        "checkin": 1,
        "formatted_date": DateTime.now().toString(),
      });
      // Inform the user that the response is stored offline
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Check-in response stored offline."),
        ),
      );
      return;
    }

    // If connected to the internet, make the API call
    const String apiUrl = "http://iilhcm.ismailglobal.com/api/v1/employee-mapped-location";
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

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        "Bearer-Token": "$token", // Include the token in the "Bearer-Token" header
      },
    );

    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    final bool status = jsonResponse['status'];
    final String message = jsonResponse['message'];

    String? locationLatitude = jsonResponse["data"]?[0]?['location_latitude'];
    String? locationLongitude = jsonResponse["data"]?[0]?['location_longitude'];

    print("Status: $status");
    print("Message: $message");
    print("loclat: $locationLatitude");
    print("loclong: $locationLongitude");

    if (status) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );

      if (locationLatitude != null && locationLongitude != null) {
        Position? newPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        // Calculate the distance between user's current location and the desired location
        double userLatitude = newPosition.latitude;
        double userLongitude = newPosition.longitude;

        double desiredLatitude = double.tryParse(locationLatitude) ?? 0.0;
        double desiredLongitude = double.tryParse(locationLongitude) ?? 0.0;

        double distanceInMeters = Geolocator.distanceBetween(
          userLatitude,
          userLongitude,
          desiredLatitude,
          desiredLongitude,
        );

        if (distanceInMeters <= 300) {
          MakeCheckInCall();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("You are not in the radius of your desired location"),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Location data is missing in the response."),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }
  }

  // Function to submit stored responses when internet connectivity is available
  Future<void> submitOfflineResponses() async {
    if (offlineResponses.isNotEmpty) {
      // Make the API call to submit offline responses
      const String apiUrl = "http://iilhcm.ismailglobal.com/api/v1/offline-attendance";
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

      final List<Map<String, dynamic>> offlineResponseCopy = [...offlineResponses];
      offlineResponses.clear(); // Clear stored responses

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Bearer-Token": "$token",
        },
        body: {
          "attendance_object": jsonEncode(offlineResponseCopy),
        },
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final bool status = jsonResponse['status'];
      final String message = jsonResponse['message'];

      print("Offline Submission Status: $status");
      print("Offline Submission Message: $message");

      if (status) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Offline responses submitted successfully."),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to submit offline responses."),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Dispose of the connectivity stream when the widget is disposed
    Connectivity().onConnectivityChanged.listen(null).cancel();
    super.dispose();
  }

 

Future<void> MakeCheckInCall() async {
  final String apiUrl = "http://iilhcm.ismailglobal.com/api/v1/checkinattendance";
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}



    Future<void> checkIn() async {
      if (isCheckInDisabled) {
        return;
      }

      PermissionStatus permission = await Permission.location.request();

      if (permission.isGranted) {
        Position newPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        double distanceInMeters = Geolocator.distanceBetween(
          newPosition.latitude,
          newPosition.longitude,
          double.parse(widget.userData['desiredLatitude']!),
          double.parse(widget.userData['desiredLongitude']!),
        );
        // print(newPosition.latitude);
        // print(newPosition.longitude);

        if (distanceInMeters <= double.parse(widget.userData['radius']!)) {
          if (isInternetConnected) {
            MakeCheckInCall();
          } else {
            // No internet connection, queue the API call
            apiCallQueue.add(MakeCheckInCall);
          }

          setState(() {
            currentPosition = newPosition;
            checkInTime = DateTime.now();
            isCheckInDisabled = true;
            isCheckOutDisabled = false;
          });

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Check-Out Details"),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Time: ${checkOutTime!.toString()}",
                        style: TextStyle(color: Colors.green),
                      ),
                      Text("Current Latitude: ${currentPosition!.latitude.toStringAsFixed(6)}"),
                      Text("Current Longitude: ${currentPosition!.longitude.toStringAsFixed(6)}"),
                      Text("Desired Latitude: ${widget.userData['desiredLatitude']}"),
                      Text("Desired Longitude: ${widget.userData['desiredLongitude']}"),
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Close"),
                    ),
                  ],
                );
              },
            );
          } else {
          Fluttertoast.showToast(
            msg: "Check-in not possible. You are too far from the desired location.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "Location permission is required to perform CheckIn.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
        );
      }
    }
    // Function to save check-in details locally
    Future<void> saveCheckInDetailsLocally() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("currLat", currentPosition!.latitude.toString());
      prefs.setString("currLong", currentPosition!.longitude.toString());

    }

    // Function to submit saved check-in details when internet connectivity is available
    Future<void> submitSavedCheckInDetails() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedCheckInTime = prefs.getString("savedCheckInTime");

      if (savedCheckInTime != null) {
      
        // prefs.remove("savedCheckInTime");
      }
    }
      Future<void> checkOut() async {
        if (isCheckOutDisabled) {
          return;
        }

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

      }

        @override
        Widget build(BuildContext context) {
          return Scaffold(
            key: _scaffoldKey,
            appBar: buildAppBar(_scaffoldKey, context),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.green], // Adjust gradient colors
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 1.0], // Add stops for more control
                  tileMode: TileMode.clamp, // Adjust this as needed
                ),
              ),
              child: Center(
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            PositionedButton(
                              position: 0,
                              buttonText: 'CheckIn',
                              onTap: FinalCheckIn,
                              isDisabled: isCheckInDisabled,
                            ),
                            PositionedButton(
                              position: 0,
                              buttonText: 'Checkout',
                              onTap: checkOut,
                              isDisabled: isCheckOutDisabled,
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                       
                      ],
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SquareButton(
                                  text: 'Leave',
                                  icon: Icons.calendar_today,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LeavePage(),
                                      ),
                                    );
                                  },
                                ),
                                SquareButton(
                                  text: 'Salary',
                                  icon: Icons.attach_money,
                                  onTap: () {
                                    // Implement Salary button functionality
                                  },
                                ),
                                SquareButton(
                                  text: 'Loan',
                                  icon: Icons.monetization_on,
                                  onTap: () {
                                    // Implement Loan button functionality
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SquareButton(
                                  text: 'Attendance',
                                  icon: Icons.access_time,
                                  onTap: () {
                                    // Implement Attendance button functionality
                                  },
                                ),
                                SquareButton(
                                  text: 'News',
                                  icon: Icons.announcement,
                                  onTap: () {
                                    // Implement News button functionality
                                  },
                                ),
                                SquareButton(
                                  text: 'Tracking',
                                  icon: Icons.location_on,
                                  onTap: () {
                                    // Implement Tracking button functionality
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            drawer: buildUserDrawer(context),
            endDrawer: buildRightDrawer(context),
            bottomNavigationBar: buildFooter(),
          );
        }
      }