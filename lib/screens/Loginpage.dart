import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

class LoginPage extends StatelessWidget {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


   Future<void> login(BuildContext context) async {
  const String apiUrl = "http://iilhcm.ismailglobal.com/api/v1/login-process";

  // Replace these with your actual input values
final String userid = userNameController.text;
final String password = passwordController.text;


    Position? position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final String latitude = position.latitude.toString();
    final String longitude = position.longitude.toString();
  // Create a FormData object to build the multipart request
  final http.MultipartRequest request = http.MultipartRequest("POST", Uri.parse(apiUrl));

  // Set the headers
  request.headers["Content-Type"] = "multipart/form-data";

  // Add fields to the request
  request.fields["login_history_longitude"] = longitude;
  request.fields["login_history_latitude"] = latitude;
  request.fields["employee_code"] = userid;
  request.fields["employee_password"] = password;
  request.fields["device_token"] = '76o3CbR4998';
  request.fields["device_name"] = 'Samsung Galaxy A32 5G';

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
 if (myToken != null) {
        await saveTokenLocally(myToken);
      }
    print(message);
    print(status);
    print(myToken);
    print(employee_name);
    print(employee_contactno );
    print(employee_cnic);
    
    // Create a map with user data if needed
    final Map<String, String> userData = {
      'userId': jsonResponse['token'],
      'desiredLongitude': '67.086944917954',
      'desiredLatitude': '24.87009900430556',
      'radius': '100',
    };

    // Save user data locally if needed
    // await saveUserDataLocally(userData);
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message!),
      ),
    );
    // Navigate to the next page with user data
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LandingPage(userData: userData),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message!),
      ),
    );
  }
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
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 238, 129, 5)!,
                Color.fromARGB(255, 184, 82, 167)!,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.only(top: 100, bottom: 30),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/ii.png',
                      width: 450,
                      height: 200,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Ismail Industries HCM",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded( // Wrap the Column with Expanded
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      InputField(icon: Icons.person, hintText: "UserName", controller: userNameController),
                      SizedBox(height: 10),
                      InputField(icon: Icons.lock, hintText: "Password", isPassword: true, controller: passwordController),
                      SizedBox(height: 10),
                     // InputField(icon: Icons.link, hintText: "Host Link", controller: hostlinkController),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          login(context);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green[600],
                          onPrimary: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 15),
                          elevation: 5,
                        ),
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[600]),
          SizedBox(width: 10),
          Expanded(
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
        ],
      ),
    );
  }
}






// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// import 'landing_page.dart';

// class LoginApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: LoginPage(),
//     );
//   }
// }

// class LoginPage extends StatelessWidget {
//   final TextEditingController idController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController hostLinkController = TextEditingController();

//   void handleLoginButtonPress(BuildContext context) async {
//     final apiUrl = 'YOUR_API_URL_HERE'; // Replace with your API URL

//     // Create a map with the data to send to the API
//     final data = {
//       'id': idController.text,
//       'password': passwordController.text,
//       'hostLink': hostLinkController.text,
//     };

//     final response = await http.post(Uri.parse(apiUrl), body: data);

//     if (response.statusCode == 200) {
//       // Handle the successful API response
//       print('Login successful');
//       // Navigate to the next page if needed
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => LandingPage()),
//       );
//     } else {
//       // Handle the API error
//       print('Login failed');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Color.fromARGB(255, 238, 129, 5)!,
//               Color.fromARGB(255, 184, 82, 167)!,
//             ],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: EdgeInsets.only(top: 100, bottom: 30),
//               child: Column(
//                 children: [
//                   Image.asset(
//                     '/images/ii.jpg', // Replace with your image path
//                     width: 180,
//                     height: 180,
//                     //color: Colors.white,
//                   ),
//                   SizedBox(height: 10),
//                   Text(
//                     "Ismail Industries HCM",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//               child: Column(
//                 children: [
//                   InputField(
//                     icon: Icons.person,
//                     hintText: "ID",
//                     controller: idController,
//                   ),
//                   SizedBox(height: 10),
//                   InputField(
//                     icon: Icons.lock,
//                     hintText: "Password",
//                     isPassword: true,
//                     controller: passwordController,
//                   ),
//                   SizedBox(height: 10),
//                   InputField(
//                     icon: Icons.link,
//                     hintText: "Host Link",
//                     controller: hostLinkController,
//                   ),
//                   SizedBox(height: 30),
//                   ElevatedButton(
//                     onPressed: () {
//                       // Call the function to handle login button press
//                       handleLoginButtonPress(context);
//                     },
//                     style: ElevatedButton.styleFrom(
//                       primary: Colors.green[600], // Set the background color
//                       onPrimary: Colors.white, // Set the text color
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10), // Set button corner radius
//                       ),
//                       padding: EdgeInsets.symmetric(vertical: 15), // Set vertical padding
//                       elevation: 5, // Add shadow to the button
//                     ),
//                     child: Text(
//                       "Login",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class InputField extends StatelessWidget {
//   final IconData icon;
//   final String hintText;
//   final bool isPassword;
//   final TextEditingController controller;

//   InputField({required this.icon, required this.hintText, this.isPassword = false, required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: Colors.green[600]),
//           SizedBox(width: 10),
//           Expanded(
//             child: TextField(
//               obscureText: isPassword,
//               controller: controller,
//               style: TextStyle(color: Colors.black),
//               decoration: InputDecoration(
//                 hintText: hintText,
//                 hintStyle: TextStyle(color: Colors.black),
//                 border: InputBorder.none,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
