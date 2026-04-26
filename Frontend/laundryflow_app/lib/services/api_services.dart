import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // =====================================
  // CONFIG
  // =====================================
  static const String baseUrl =
      'http://10.0.2.2:5000/api';

  static const String _tokenKey =
      'auth_token';

  static const String _userKey =
      'auth_user';

  static String? _token;

  static Map<String, dynamic>?
      _currentUser;

  static Map<String, dynamic>?
      get currentUser =>
          _currentUser;

  static bool get isAuthenticated =>
      _token != null &&
      _currentUser != null;

  // =====================================
  // SESSION
  // =====================================

  static Future<void>
      restoreSession() async {
    final prefs =
        await SharedPreferences
            .getInstance();

    _token =
        prefs.getString(_tokenKey);

    final userJson =
        prefs.getString(_userKey);

    if (userJson != null) {
      _currentUser =
          Map<String, dynamic>.from(
        jsonDecode(userJson),
      );
    }
  }

  static Future<void>
      _persistSession() async {
    final prefs =
        await SharedPreferences
            .getInstance();

    if (_token != null) {
      await prefs.setString(
        _tokenKey,
        _token!,
      );
    }

    if (_currentUser != null) {
      await prefs.setString(
        _userKey,
        jsonEncode(_currentUser),
      );
    }
  }

  static Future<void> logout() async {
    _token = null;
    _currentUser = null;

    final prefs =
        await SharedPreferences
            .getInstance();

    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  static Future<String?>
      getToken() async {
    if (_token != null) {
      return _token;
    }

    final prefs =
        await SharedPreferences
            .getInstance();

    _token =
        prefs.getString(_tokenKey);

    return _token;
  }

  // =====================================
  // HEADERS
  // =====================================

  static Map<String, String> _headers({
    bool authenticated = false,
  }) {
    final headers = {
      'Content-Type':
          'application/json',
    };

    if (authenticated &&
        _token != null) {
      headers['Authorization'] =
          'Bearer $_token';
    }

    return headers;
  }

  // =====================================
  // ERROR HANDLING
  // =====================================

  static Exception _buildError(
    http.Response response,
  ) {
    try {
      final body =
          jsonDecode(response.body);

      final message =
          body['message'] ??
              body['error'] ??
              'Request failed';

      return Exception(
        message.toString(),
      );
    } catch (_) {
      return Exception(
        'Request failed (${response.statusCode})',
      );
    }
  }

  // =====================================
  // AUTH
  // =====================================

  static Future<Map<String, dynamic>>
      login({
    required String email,
    required String password,
  }) async {
    final response =
        await http.post(
      Uri.parse(
        '$baseUrl/auth/login',
      ),
      headers: _headers(),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode !=
        200) {
      throw _buildError(
          response);
    }

    final data =
        Map<String, dynamic>.from(
      jsonDecode(response.body),
    );

    _token = data['token'];

    _currentUser = {
      "id": data['id'],
      "email": data['email'],
      "role": data['role'],
    };

    await _persistSession();

    return _currentUser!;
  }

  static Future<Map<String, dynamic>>
      register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response =
        await http.post(
      Uri.parse(
        '$baseUrl/auth/register',
      ),
      headers: _headers(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode !=
            200 &&
        response.statusCode !=
            201) {
      throw _buildError(
          response);
    }

    final data =
        Map<String, dynamic>.from(
      jsonDecode(response.body),
    );

    _token = data['token'];

    _currentUser = {
      "id": data['id'],
      "email": data['email'],
      "role": data['role'],
    };

    await _persistSession();

    return _currentUser!;
  }

  // =====================================
  // BOOKINGS
  // =====================================

  static Future<dynamic>
      createBooking(
    double weight,
    String batchId,
  ) async {
    final token =
        await getToken();

    if (token == null) {
      throw Exception(
        "User not logged in",
      );
    }

    _token = token;

    final response =
        await http.post(
      Uri.parse(
        '$baseUrl/bookings',
      ),
      headers: _headers(
        authenticated: true,
      ),
      body: jsonEncode({
        'weight': weight,
        'batchId': batchId,
      }),
    );

    if (response.statusCode !=
            200 &&
        response.statusCode !=
            201) {
      throw _buildError(
          response);
    }

    return jsonDecode(
      response.body,
    );
  }

  static Future<List<dynamic>>
      getMyBookings() async {
    final token =
        await getToken();

    if (token == null) {
      throw Exception(
        "Not logged in",
      );
    }

    _token = token;

    final response =
        await http.get(
      Uri.parse(
        '$baseUrl/bookings/my',
      ),
      headers: _headers(
        authenticated: true,
      ),
    );

    if (response.statusCode !=
        200) {
      throw _buildError(
          response);
    }

    return jsonDecode(
      response.body,
    );
  }

  static Future<List<dynamic>>
      getBatches() async {
    final token =
        await getToken();

    if (token == null) {
      throw Exception(
        "Not logged in",
      );
    }

    _token = token;

    final response =
        await http.get(
      Uri.parse(
        '$baseUrl/batches',
      ),
      headers: _headers(
        authenticated: true,
      ),
    );

    if (response.statusCode !=
        200) {
      throw _buildError(
          response);
    }

    return jsonDecode(
      response.body,
    );
  }

  // =====================================
  // WALLET
  // =====================================

  static Future<Map<String, dynamic>>
      getWalletBalance() async {
    final token =
        await getToken();

    if (token == null) {
      throw Exception(
        "Not logged in",
      );
    }

    _token = token;

    final response =
        await http.get(
      Uri.parse(
        '$baseUrl/wallet/balance',
      ),
      headers: _headers(
        authenticated: true,
      ),
    );

    if (response.statusCode !=
        200) {
      throw _buildError(
          response);
    }

    return Map<String, dynamic>.from(
      jsonDecode(
        response.body,
      ),
    );
  }

  static Future<void>
      topUpWallet(
    double amount,
  ) async {
    final token =
        await getToken();

    if (token == null) {
      throw Exception(
        "Not logged in",
      );
    }

    _token = token;

    final response =
        await http.post(
      Uri.parse(
        '$baseUrl/wallet/topup',
      ),
      headers: _headers(
        authenticated: true,
      ),
      body: jsonEncode({
        "amount": amount,
      }),
    );

    if (response.statusCode !=
            200 &&
        response.statusCode !=
            201) {
      throw _buildError(
          response);
    }
  }

  static Future<List<dynamic>>
      getWalletHistory() async {
    final token =
        await getToken();

    if (token == null) {
      throw Exception(
        "Not logged in",
      );
    }

    _token = token;

    final response =
        await http.get(
      Uri.parse(
        '$baseUrl/wallet/history',
      ),
      headers: _headers(
        authenticated: true,
      ),
    );

    if (response.statusCode !=
        200) {
      throw _buildError(
          response);
    }

    return jsonDecode(
      response.body,
    );
  }
}