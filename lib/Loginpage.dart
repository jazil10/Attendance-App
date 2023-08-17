import 'package:flutter/material.dart';

import 'landing_page.dart';


class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}



class LoginPage extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 238, 129, 5)!, Color.fromARGB(255, 184, 82, 167)!],
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
                  '/images/ii.jpg', // Replace with your image path
                  width: 180,
                  height: 180,
                  //color: Colors.white,
                ),
                  SizedBox(height: 10),
                  Text(
                    "Ismail Industries HCM",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  InputField(icon: Icons.person, hintText: "ID"),
                  SizedBox(height: 10),
                  InputField(icon: Icons.lock, hintText: "Password", isPassword: true),
                  SizedBox(height: 10),
                  InputField(icon: Icons.link, hintText: "Host Link"),
                  SizedBox(height: 30),
                  ElevatedButton(
  onPressed: () {
    // Handle login button press
    Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LandingPage()),
            );
  },
  style: ElevatedButton.styleFrom(
    primary: Colors.green[600], // Set the background color
    onPrimary: Colors.white, // Set the text color
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10), // Set button corner radius
    ),
    padding: EdgeInsets.symmetric(vertical: 15), // Set vertical padding
    elevation: 5, // Add shadow to the button
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
          ],
        ),
      ),
    );
  }
}

class InputField extends StatelessWidget {
  final IconData icon;
  final String hintText;
  final bool isPassword;

  InputField({required this.icon, required this.hintText, this.isPassword = false});

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
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: hintText, hintStyle: TextStyle(color: Colors.black),
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
