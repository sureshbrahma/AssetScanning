import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ScannerFragment.dart';
import 'UserManagementScreen.dart';

class HomeScreen extends StatefulWidget {
  final String role;

  const HomeScreen({Key? key, required this.role}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // Get the screen size
    var screenSize = MediaQuery.of(context).size;
    var isMobile = screenSize.width < 600;

    return Scaffold(
        body: Stack(
        children: [
        // Background image
        Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
        image: DecorationImage(
        image: AssetImage('assets/background_image.jpg'),
    fit: BoxFit.cover,
    ),
    ),
    ),

    // Title text
    Positioned(
    top: 50,
    left: 10,
    right: 10,
    child: Container(
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
    color: Colors.black.withOpacity(0.5),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.red, width: isMobile ? 4 : 8), // Adjust border width
    ),
    child: Text(
    'Asset QR Scanner Utility',
    style: TextStyle(
    color: Colors.white,
    fontSize: isMobile ? 20 : 24, // Adjust font size
    fontWeight: FontWeight.bold,
    ),
      textAlign: TextAlign.center,
    ),
    ),
    ),

          // Form container
          Positioned(
            top: 150,
            left: 16,
            right: 16,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.pinkAccent.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.cyanAccent, width: isMobile ? 4 : 8), // Adjust border width
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Open QR Scanner button
                  ElevatedButton(
                    onPressed: () => openScanner(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: isMobile ? 24 : 32), // Adjust padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Open QR Scanner',
                      style: TextStyle(fontSize: isMobile ? 16 : 18), // Adjust font size
                    ),
                  ),
                  SizedBox(height: 16),

                  // User Management button (conditionally shown)
                  if (widget.role.toLowerCase() == 'admin')
                    ElevatedButton(
                      onPressed: () => openUserManagement(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: isMobile ? 24 : 32), // Adjust padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'User Management',
                        style: TextStyle(fontSize: isMobile ? 16 : 18), // Adjust font size
                      ),
                    ),
                  SizedBox(height: 16),

                  // Exit button
                  ElevatedButton(
                    onPressed: exitApplication,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: isMobile ? 24 : 32), // Adjust padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Exit',
                      style: TextStyle(fontSize: isMobile ? 16 : 18), // Adjust font size
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

  void openScanner(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScannerScreen(),
      ),
    );
  }

  void openUserManagement(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserManagementScreen(),
      ),
    );
  }

  void exitApplication() {
    if (Platform.isAndroid || Platform.isIOS) {
      SystemNavigator.pop(); // Use this for mobile platforms
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      exit(0); // Use this for desktop platforms
    }
  }
}

