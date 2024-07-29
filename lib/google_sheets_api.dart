import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';

class GoogleSheetsApi {
  static const _scopes = [SheetsApi.spreadsheetsReadonlyScope];
  final String _spreadsheetId;
  final String _range;
  final SheetsApi _sheetsApi;

  GoogleSheetsApi(this._spreadsheetId, this._range, this._sheetsApi);

  static Future<GoogleSheetsApi> create(
      String spreadsheetId, String range) async {
    final serviceAccountJson = await rootBundle.loadString('assets/androidfastrack-aa32e2e5db9c.json');
    final credentials = ServiceAccountCredentials.fromJson(
        json.decode(serviceAccountJson));
    final authClient = await clientViaServiceAccount(credentials, _scopes);
    final sheetsApi = SheetsApi(authClient);
    return GoogleSheetsApi(spreadsheetId, range, sheetsApi);
  }

  Future<List<String>> fetchData() async {
    final response = await _sheetsApi.spreadsheets.values.get(
      _spreadsheetId,
      _range,
    );
    final values = response.values;
    if (values == null || values.isEmpty) {
      return [];
    }
    return values.map((row) => row.first.toString()).toList();
  }
}
