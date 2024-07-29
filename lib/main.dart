import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'HomeScreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false, // Remove debug banner
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  Future<Map<String, dynamic>?> _authenticateUser(String username, String password) async {
    try {
      final client = await _getAuthClient();

      final sheetsApi = sheets.SheetsApi(client);
      final spreadsheetId = '1IpPPYOf63DoVNZ0F0_3q0b8ACGjbG8dLscH4yxGk-5U';
      final range = 'Login!A:D'; // Adjust the range as per your Google Sheet structure

      final response = await sheetsApi.spreadsheets.values.get(spreadsheetId, range);

      if (response.values == null) {
        return null; // No data found in the sheet
      }

      for (var row in response.values!.skip(1)) { // Skip header row
        if (row.length >= 4 && row[1] == username && row[2] == password) {
          return {
            'username': row[1],
            'role': row[3], // Assuming role is in the 4th column (D)
          };
        }
      }

      return null; // Username and password not found in the sheet
    } catch (e) {
      print('Error authenticating user: $e');
      return null;
    }
  }

  Future<AutoRefreshingAuthClient> _getAuthClient() async {
    final credentials = await _loadServiceAccountCredentials();
    final accountCredentials = ServiceAccountCredentials.fromJson(credentials);
    final scopes = [sheets.SheetsApi.spreadsheetsReadonlyScope];

    return clientViaServiceAccount(accountCredentials, scopes);
  }

  Future<Map<String, dynamic>> _loadServiceAccountCredentials() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/androidfastrack-aa32e2e5db9c.json');

    if (!await file.exists()) {
      final data = await rootBundle.loadString('assets/androidfastrack-aa32e2e5db9c.json');
      await file.writeAsString(data);
    }

    final credentials = await file.readAsString();
    return json.decode(credentials);
  }

  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Username and password cannot be empty';
      });
      return;
    }

    final user = await _authenticateUser(username, password);

    if (user != null) {
      // Navigate to HomeScreen with role
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(role: user['role']),
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'Invalid username or password';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/background_image.jpg", // Replace with your background image path
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16.0), // Margin around the card
                padding: EdgeInsets.all(16.0), // Padding inside the card
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.cyanAccent, width: 8), // Adjust border width here
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/small_logo.jpg", // Replace with your logo image path
                      width: 150, // Adjust the width as needed
                      height: 150, // Adjust the height as needed
                    ),
                    SizedBox(height: 20), // Adjust spacing as needed
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "Asset QR Scanner Utility",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 20), // Adjust spacing as needed
                    Container(
                      width: 300, // Adjust width as needed
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red, width: 8), // Adjust border width here
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Login Form",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: TextField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                hintText: "Username",
                                prefixIcon: Icon(Icons.person),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: TextField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                hintText: "Password",
                                prefixIcon: Icon(Icons.lock),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                              ),
                              obscureText: true,
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _login,
                            child: Text("Login"),
                          ),
                          if (_errorMessage != null)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
