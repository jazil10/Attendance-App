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
import 'checkin_popup.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  double desiredLatitude = 24.870069823579037;
  double desiredLongitude = 67.08703074076158;
  Position? currentPosition;
  DateTime? checkInTime;
  DateTime? checkOutTime;
  bool isCheckInDisabled = false;
  bool isCheckOutDisabled = true; // Initialize checkout button as disabled

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
        desiredLatitude,
        desiredLongitude,
      );

      setState(() {
        currentPosition = newPosition;
        checkInTime = DateTime.now();
        desiredLatitude = 24.870069823579037;
        desiredLongitude = 67.08703074076158;
        isCheckInDisabled = true;
        isCheckOutDisabled = false; // Enable checkout button after check-in
      });

      CheckInPopup.showPopup(context, distanceInMeters);
    } else {
      Fluttertoast.showToast(
        msg: "Location permission is required to perform CheckIn.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  Future<void> checkOut() async {
    if (isCheckOutDisabled) {
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
        desiredLatitude,
        desiredLongitude,
      );

      setState(() {
        currentPosition = newPosition;
        checkOutTime = DateTime.now();
        desiredLatitude = 24.870069823579037;
        desiredLongitude = 67.08703074076158;
        isCheckOutDisabled = true; // Disable checkout button after checkout
      });

      CheckOutPopup.showPopup(context, distanceInMeters);

      // Show Checkout Popup or perform other checkout actions
    } else {
      Fluttertoast.showToast(
        msg: "Location permission is required to perform CheckOut.",
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
                if (currentPosition != null)
                  Text(
                    "Current Latitude: ${currentPosition!.latitude.toStringAsFixed(6)}",
                    style: TextStyle(fontSize: 18),
                  ),
                if (currentPosition != null)
                  Text(
                    "Current Longitude: ${currentPosition!.longitude.toStringAsFixed(6)}",
                    style: TextStyle(fontSize: 18),
                  ),
                if (checkInTime != null)
                  Text(
                    "Check-In Time: ${checkInTime!.toString()}",
                    style: TextStyle(fontSize: 18),
                  ),
                SizedBox(height: 10),
                Text(
                  "Desired Latitude: ${desiredLatitude.toStringAsFixed(6)}",
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  "Desired Longitude: ${desiredLongitude.toStringAsFixed(6)}",
                  style: TextStyle(fontSize: 18),
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
