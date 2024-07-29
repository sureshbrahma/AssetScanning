import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import 'package:path_provider/path_provider.dart';

class ScannerScreen extends StatefulWidget {
  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  String _scanResult = '';
  String _errorMessage = '';

  sheets.SheetsApi? sheetsApi;

  @override
  void initState() {
    super.initState();
    initializeSheetsApi();
  }

  Future<void> initializeSheetsApi() async {
    final client = await _getAuthClient();
    sheetsApi = sheets.SheetsApi(client);
  }

  Future<void> startBarcodeScan() async {
    try {
      final scanResult = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.QR,
      );

      if (scanResult != '-1') {
        setState(() {
          _scanResult = scanResult;
        });
        await checkQRCodeInGoogleSheets(scanResult);
      }
    } catch (e) {
      setState(() {
        _scanResult = 'Failed to get scan result.';
        _errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> checkQRCodeInGoogleSheets(String qrCodeContent) async {
    try {
      final spreadsheetId = '1IpPPYOf63DoVNZ0F0_3q0b8ACGjbG8dLscH4yxGk-5U';
      final range = 'Qrdetails!A:E'; // Range to include columns A to E

      final response = await sheetsApi!.spreadsheets.values.get(spreadsheetId, range);

      if (response.values == null) {
        setState(() {
          _errorMessage = 'No data found in Google Sheets.';
        });
        return;
      }

      final cleanedQRCodeContent = qrCodeContent.replaceAll(RegExp(r'\s+'), '');
      bool found = false;
      for (var row in response.values!.skip(1)) {
        if (row.isNotEmpty) {
          final cellContent = row[1].toString().replaceAll(RegExp(r'\s+'), ''); // Compare with column B (index 1)
          if (cellContent == cleanedQRCodeContent) {
            found = true;

            // Check if column C (index 2) is not empty
            if (row.length > 2 && row[2].toString().isNotEmpty) {
              setState(() {
                _errorMessage = 'This QR Code belongs to our Database\nThe Edited Text is ${row[2]}';
              });
            } else {
              setState(() {
                _errorMessage = 'This QR Code belongs to our Database';
              });
            }

            // Update columns D (index 3) and E (index 4)
            final rowIndex = response.values!.indexOf(row) + 1;
            final updateRange = 'Qrdetails!D$rowIndex:E$rowIndex';
            final updateValues = [
              ['OK', DateTime.now().toIso8601String()]
            ];
            final updateBody = sheets.ValueRange(range: updateRange, majorDimension: 'ROWS', values: updateValues);
            await sheetsApi!.spreadsheets.values.update(updateBody, spreadsheetId, updateRange,
                valueInputOption: 'USER_ENTERED');

            break;
          }
        }
      }

      if (!found) {
        setState(() {
          _errorMessage = 'This QR Code does not belong to our Database';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error checking QR code in Google Sheets: $e';
      });
    }
  }

  Future<AutoRefreshingAuthClient> _getAuthClient() async {
    final credentials = await _loadServiceAccountCredentials();
    final scopes = [
      sheets.SheetsApi.spreadsheetsReadonlyScope,
      sheets.SheetsApi.spreadsheetsScope, // Include write scope
    ];
    final client = await clientViaServiceAccount(credentials, scopes);
    return client;
  }

  Future<ServiceAccountCredentials> _loadServiceAccountCredentials() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/androidfastrack-aa32e2e5db9c.json');

    if (!await file.exists()) {
      final data = await rootBundle.loadString('assets/androidfastrack-aa32e2e5db9c.json');
      await file.writeAsString(data);
    }

    final credentials = await file.readAsString();
    return ServiceAccountCredentials.fromJson(json.decode(credentials));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Scanner'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text('Scan Result: $_scanResult'),
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          Container(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: startBarcodeScan,
              child: Text('Start QR Code Scan'),
            ),
          ),
        ],
      ),
    );
  }
}
