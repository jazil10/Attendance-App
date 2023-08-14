import 'package:hcm/leave_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'app_bar.dart';
import 'positioned_button.dart';
import 'user_drawer.dart';
import 'right_drawer.dart';
import 'footer.dart';
import 'square_button.dart';
import 'checkin_popup.dart'; // Import the checkin_popup.dart file

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<void> checkIn() async {
    print("CheckIn button tapped.");

    // Request location permission
    PermissionStatus permission = await Permission.location.request();

    if (permission.isGranted) {
      Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
//24.870069823579037, 67.08703074076158
      // Replace with the desired latitude and longitude for the location
      double desiredLatitude = 24.870069823579037;
      double desiredLongitude = 67.08703074076158;
      double distanceInMeters = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        desiredLatitude,
        desiredLongitude,
      );

      print("Distance to location: $distanceInMeters meters");

      CheckInPopup.showPopup(context, distanceInMeters);
    } else {
      print("Location permission denied.");
      // You can show a dialog or toast indicating that location permission is required.
      // For example, you can use the FlutterToast package to show a toast message.
      Fluttertoast.showToast(
        msg: "Location permission is required to perform CheckIn.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: buildAppBar(_scaffoldKey, context),
      body: Center(
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
                      onTap: checkIn,
                    ),
                    PositionedButton(
                      position: 1,
                      buttonText: 'Checkout',
                      onTap: () {
                        // Implement Checkout button functionality
                      },
                    ),
                    PositionedButton(
                      position: 2,
                      buttonText: 'idk',
                      onTap: () {
                        // Implement idk button functionality
                      },
                    ),
                    PositionedButton(
                      position: 3,
                      buttonText: 'again idk',
                      onTap: () {
                        // Implement again idk button functionality
                      },
                    ),
                  ],
                ),
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
      drawer: buildUserDrawer(context),
      endDrawer: buildRightDrawer(context),
      bottomNavigationBar: buildFooter(),
    );
  }
}
