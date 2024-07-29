import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:path_provider/path_provider.dart';

class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<List<Object>> users = [];
  final String spreadsheetId = '1IpPPYOf63DoVNZ0F0_3q0b8ACGjbG8dLscH4yxGk-5U';
  final String range = 'Login!A:D'; // Adjusted range to include all four columns

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final client = await _getAuthClient();
    final sheetsApi = sheets.SheetsApi(client);

    final response = await sheetsApi.spreadsheets.values.get(spreadsheetId, range);

    setState(() {
      users = response.values!
          .map((row) => row.map((cell) => cell as Object).toList())
          .toList();
    });
  }

  Future<AutoRefreshingAuthClient> _getAuthClient() async {
    final credentials = await _loadServiceAccountCredentials();
    final accountCredentials = ServiceAccountCredentials.fromJson(credentials);
    final scopes = [sheets.SheetsApi.spreadsheetsScope];

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

  Future<void> _addUser(String username, String password, String role) async {
    if (username.isEmpty || password.isEmpty) {
      _showErrorMessage('Username and password cannot be empty!');
      return;
    }

    final client = await _getAuthClient();
    final sheetsApi = sheets.SheetsApi(client);

    // Calculate new ID
    int newId = users.isEmpty ? 1 : int.parse(users.last[0] as String) + 1;
    final newUser = [newId.toString(), username, password, role];

    users.add(newUser);
    await sheetsApi.spreadsheets.values.append(
      sheets.ValueRange(values: [newUser]),
      spreadsheetId,
      range,
      valueInputOption: 'RAW',
    );

    setState(() {});
    _showSuccessMessage('User added successfully!');
  }

  Future<void> _editUser(int index, String newUsername, String newPassword, String newRole) async {
    if (newUsername.isEmpty || newPassword.isEmpty) {
      _showErrorMessage('Username and password cannot be empty!');
      return;
    }

    final client = await _getAuthClient();
    final sheetsApi = sheets.SheetsApi(client);

    users[index][1] = newUsername;
    users[index][2] = newPassword;
    users[index][3] = newRole;

    await sheetsApi.spreadsheets.values.update(
      sheets.ValueRange(values: users.map((e) => e.map((e) => e.toString()).toList()).toList()),
      spreadsheetId,
      range,
      valueInputOption: 'RAW',
    );

    setState(() {});
    _showSuccessMessage('User edited successfully!');
  }

  Future<void> _removeUser(int index) async {
    if (index < 0 || index >= users.length) {
      _showErrorMessage('Invalid index');
      return;
    }

    final client = await _getAuthClient();
    final sheetsApi = sheets.SheetsApi(client);

    users.removeAt(index);

    await sheetsApi.spreadsheets.values.clear(
      sheets.ClearValuesRequest(),
      spreadsheetId,
      range,
    );

    await sheetsApi.spreadsheets.values.append(
      sheets.ValueRange(values: users),
      spreadsheetId,
      range,
      valueInputOption: 'RAW',
    );

    setState(() {});
    _showSuccessMessage('User deleted successfully!');
  }

  void _showAddUserDialog() {
    TextEditingController _usernameController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();
    String _selectedRole = 'User';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Get screen size
            var screenSize = MediaQuery.of(context).size;
            var dialogWidth = screenSize.width * 0.8; // Adjust width as needed
            var dialogHeight = screenSize.height * 0.6; // Adjust height as needed

            return AlertDialog(
              title: Text('Add User'),
              content: Container(
                width: dialogWidth,
                height: dialogHeight,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(hintText: "Username"),
                      ),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(hintText: "Password"),
                        obscureText: true,
                      ),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        items: ['Admin', 'User'].map((String role) {
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Text(role),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedRole = newValue!;
                          });
                        },
                        decoration: InputDecoration(hintText: "Role"),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    _addUser(
                      _usernameController.text,
                      _passwordController.text,
                      _selectedRole,
                    );
                    Navigator.of(context).pop();
                  },
                  child: Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditUserDialog(int index) {
    TextEditingController _usernameController =
    TextEditingController(text: users[index][1] as String);
    TextEditingController _passwordController =
    TextEditingController(text: users[index][2] as String);
    TextEditingController _roleController =
    TextEditingController(text: users[index][3] as String);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(hintText: "Username"),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(hintText: "Password"),
                obscureText: true,
              ),
              TextField(
                controller: _roleController,
                decoration: InputDecoration(hintText: "Role"),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _editUser(
                  index,
                  _usernameController.text,
                  _passwordController.text,
                  _roleController.text,
                );
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          if (index == 0) return Container(); // Skip header row
          return Card(
            margin: EdgeInsets.all(8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 5,
            child: ListTile(
              contentPadding: EdgeInsets.all(10.0),
              title: Text(
                users[index][1] as String,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Password: ${users[index][2]}'),
                  Text('Role: ${users[index][3]}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.orange),
                    onPressed: () {
                      _showEditUserDialog(index);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _removeUser(index);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUserDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
