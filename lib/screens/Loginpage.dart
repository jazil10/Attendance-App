import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import 'package:xml/xml.dart' as xml;
import 'landing_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}

@override
void initState() {
  //super.initState();
  requestLocationPermission();
}

Future<void> requestLocationPermission() async {
  var status = await Permission.location.request();
  
  if (status.isGranted) {
    // Location permission is granted, you can proceed with your logic
    Get.snackbar(
  "Thank you",
  "Thank you for allowing location permission. You can mark your attendance now,",
  backgroundColor: Colors.green, // Customize the background color
  colorText: Colors.white, // Customize the text color
  duration: Duration(seconds: 1 ), // Adjust the duration as needed
);
  } else if (status.isDenied) {
    // Location permission is denied by the user
    // You can show a message to the user or request again

    Get.snackbar(
  "Allow Access",
  "Please allow access to location permission to mark attendance.",
  backgroundColor: Colors.red, // Customize the background color
  colorText: Colors.white, // Customize the text color
  duration: Duration(seconds: 1 ), // Adjust the duration as needed
);
  } else if (status.isPermanentlyDenied) {
    // Location permission is permanently denied
    // You can open the app settings to allow the user to manually enable it
    openAppSettings();
  }
}


class LoginController extends GetxController {
  var isLoading = false.obs;

  void setLoading(bool value) {
    isLoading.value = value;
  }
}



class LoginPage extends StatelessWidget {
  
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final loginController = Get.put(LoginController());


   Future<void> login(BuildContext context) async {

      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  String deviceToken = '';
  String deviceName = '';

  try {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      final IosDeviceInfo iosDeviceInfo = await deviceInfoPlugin.iosInfo;
      deviceToken = iosDeviceInfo.identifierForVendor!; // iOS Device ID
      deviceName = iosDeviceInfo.name; // iOS Device Name
    } else {
      final AndroidDeviceInfo androidDeviceInfo = await deviceInfoPlugin.androidInfo;
      deviceToken = androidDeviceInfo.id; // Android Device ID
      deviceName = androidDeviceInfo.model; // Android Device Name
    }
  } catch (e) {
    print('Error fetching device info: $e');
  }
  
  const String apiUrl = "http://iilhcm.ismailglobal.com/api/v1/login-process";

  // Replace these with your actual input values
final String userid = userNameController.text;
final String password = passwordController.text;


    Position? position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final String latitude = position.latitude.toString();
    final String longitude = position.longitude.toString();

      loginController.setLoading(true);

     print(deviceToken);
     print(deviceName);
  // Create a FormData object to build the multipart request
  final http.MultipartRequest request = http.MultipartRequest("POST", Uri.parse(apiUrl));
  // Set the headers
  request.headers["Content-Type"] = "multipart/form-data";

  // Add fields to the request
  request.fields["login_history_longitude"] = longitude;
  request.fields["login_history_latitude"] = latitude;
  request.fields["employee_code"] = userid;
  request.fields["employee_password"] = password;
  request.fields["device_token"] = deviceToken;
  request.fields["device_name"] = deviceName;

  // Send the request
  final http.StreamedResponse response = await request.send();


    final String responseBody = await response.stream.bytesToString();
    final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
    final String? message = jsonResponse['message'];
    final bool status = jsonResponse['status'];

  if (jsonResponse['status']) {
    
    // Parse the response
    // Extract the token and other data if needed
   final String? myToken = jsonResponse['token'];
final String? employee_name = jsonResponse["data"]?[0]?["employee_name"];
final String? employee_contactno = jsonResponse["data"]?[0]?['employee_contactno'];
final String? employee_cnic = jsonResponse["data"]?[0]?['employee_cnic'];
final String? employee_designation = jsonResponse["data"]?[0]?['designation_name'];

 if (myToken != null) {
        await saveTokenLocally(myToken);
        await empdeets(employee_name!, employee_designation!);
      }
    print(message);
    print(status);
    print(myToken);
    print(employee_name);
    print(employee_contactno );
    print(employee_cnic);
        print(employee_designation);

    fetchEmployeeMappedLocation();
    // Create a map with user data if needed
    final Map<String, String> userData = {
      'userId': jsonResponse['token'],
      'desiredLongitude': '67.086944917954',
      'desiredLatitude': '24.87009900430556',
      'radius': '100',
      'employee_name': jsonResponse["data"]?[0]?["employee_name"],
      'employee_designation': jsonResponse["data"]?[0]?['designation_name'],

    };
      loginController.setLoading(false);

    // Save user data locally if needed
    // await saveUserDataLocally(userData);
  Get.snackbar(
  "Message",
  "$message",
  backgroundColor: Colors.green, // Customize the background color
  colorText: Colors.white, // Customize the text color
  duration: Duration(seconds: 1), // Adjust the duration as needed
);
    // Navigate to the next page with user data
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LandingPage(userData: userData),
      ),
    );
  } else {
          loginController.setLoading(false);

    Get.snackbar(
  "Message",
  "$message",
  backgroundColor: Colors.red, // Customize the background color
  colorText: Colors.white, // Customize the text color
  duration: Duration(seconds: 1 ), // Adjust the duration as needed
);
  }
}

 // Function to make a GET request to the API
  Future<void> fetchEmployeeMappedLocation() async {
    final String apiUrl = "http://iilhcm.ismailglobal.com/api/v1/employee-mapped-location";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    
    if (token == null) {
      // Handle the case where the token is not available
      Fluttertoast.showToast(msg: "Token not available, please Login.", backgroundColor: Colors.red);
    }

    try {
      final http.Response response = await http.get(
        Uri.parse(apiUrl),
        headers: {
         "Bearer-Token": "$token",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final bool status = jsonResponse['status'];
        final String message = jsonResponse['message'];


        if (status) {
          final List<dynamic> data = jsonResponse['data'];
          if (data.isNotEmpty) {
            final String latitude = data[0]['location_latitude'];
            final String longitude = data[0]['location_longitude'];
           
            // Store latitude and longitude in local storage
            await prefs.setString('location_latitude', latitude);
            await prefs.setString('location_longitude', longitude);

            // Print the response and stored values
            print("Response: $jsonResponse");
            print("Latitude: $latitude");
            print("Longitude: $longitude");
                  Fluttertoast.showToast(msg: "$message", toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.green,
            textColor: Colors.white,
 );

          }
        } else {
          print("Error: $message");
              Fluttertoast.showToast(msg: "$message", toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            textColor: Colors.white,
);

        }
      } else {
        print("HTTP Error: ${response.statusCode}");
      }
    } catch (error) {
      print("Error: $error");
    }
  }
  Future<void> empdeets(String name,String designation) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('employee_name', name);
    await prefs.setString('employee_designation', designation);

}
// Function to save the token locally using shared_preferences
Future<void> saveTokenLocally(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', token);
}
Future<void> getTokenLocally() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // prefs.getString('token');
  print(prefs.getString('token'));
}
Future<void> saveUserDataLocally(Map<String, String> userData) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('userId', userData['userId']!);
  prefs.setString('desiredLongitude', userData['desiredLongitude']!);
  prefs.setString('desiredLatitude', userData['desiredLatitude']!);
  prefs.setString('radius', userData['radius']!);
  // You can add more data to save as needed
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background Image
          Image.asset(
            'assets/images/blue.jpg',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
           Center(
            child: SingleChildScrollView( // Wrap the input fields with SingleChildScrollView
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Company Logo
                Container(
  width: 300,
  height: 200, // Adjust the maximum height as needed
  child: Image.asset(
    'assets/images/ii.png',
    fit: BoxFit.contain, // Ensure the image fits within the container
  ),
),
                
                SizedBox(height: 55),
                // Input Fields
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                   // color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      InputField(
                        icon: Icons.person,
                        hintText: "Username",
                        controller: userNameController,
                      ),
                      SizedBox(height: 20),
                      InputField(
                        icon: Icons.lock,
                        hintText: "Password",
                        isPassword: true,
                        controller: passwordController,
                      ),
                      SizedBox(height: 35),
                      // Remember Me and Forgot Password
                      Row(
  mainAxisAlignment: MainAxisAlignment.spaceAround, // Center the content horizontally
  children: [
    Row(
      children: [
        RoundCheckBox(
              onTap: (selected) {},
              size: 25,
              uncheckedColor: Colors.white,
              isChecked: false,
              isRound: true,
              
            ),
        SizedBox(width: 4,),
        Text("Remember Me"),
      ],
    ),
    TextButton(
      onPressed: () {
        // Handle forgot password action
      },
      child: Text(
        "Forgot Password?",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w400,
        ),
      ),
    ),
  ],
),
                      SizedBox(height: 30),
                      // Login Button
                      ElevatedButton(
  onPressed: () {
    login(context);
  },
  style: ElevatedButton.styleFrom(
    primary: Colors.white, // Change the background color to white
    onPrimary: Colors.black,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    padding: EdgeInsets.symmetric(vertical: 15),
    elevation: 5,
    minimumSize: Size(200, 50), // Increase the button size
  ),
  child: Obx(() {
    return loginController.isLoading.value
        ? CircularProgressIndicator(backgroundColor: const Color.fromARGB(255, 240, 237, 237),color: Color.fromARGB(255, 3, 83, 136),)
        : Text(
            "Login",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          );
  }),
),

                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Signup Button
                TextButton( // Use TextButton for "Sign Up"
  onPressed: () {
    // Handle signup action
  },
  style: TextButton.styleFrom(
    primary: Colors.white, // Text color
    padding: EdgeInsets.symmetric(vertical: 15),
  ),
  child: Text(
    "Sign Up",
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w400,
    ),
  ),
),
              ],
            ),
          ),
           ),
        ],
      ),
    );
  }
}

class InputField extends StatelessWidget {
  final IconData icon;
  final String hintText;
  final bool isPassword;
  final TextEditingController controller;

  InputField({required this.icon, required this.hintText, this.isPassword = false, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10), // Add padding to the icon container
            child: Icon(icon, color: Colors.white),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
              ),
              child: TextField(
                obscureText: isPassword,
                controller: controller,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(color: Colors.black),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



