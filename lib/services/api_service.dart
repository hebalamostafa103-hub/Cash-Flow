import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "https://sig-english-minority-onto.trycloudflare.com/store_api";

  static Map<String, dynamic> _decodeBody(http.Response res) {
    try {
      final decoded = jsonDecode(res.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        "success": false,
        "message": "Invalid response format",
        "raw": res.body,
      };
    } catch (e) {
      return {
        "success": false,
        "message": "Invalid JSON response",
        "raw": res.body,
      };
    }
  }

 static Future<List<Map<String, dynamic>>> getClients() async {
  final prefs = await SharedPreferences.getInstance();

final userId = int.parse(
  prefs.getString("user_id") ?? "0",
);

  final res = await http.post(
    Uri.parse("$baseUrl/clients/list.php"),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
  "user_id": userId,
}),
  );

  final body = _decodeBody(res);

  if (body["success"] == true &&
      body["data"] is List) {
    return List<Map<String, dynamic>>.from(
      body["data"],
    );
  }

  throw Exception(
    body["message"] ??
        "Failed to load clients",
  );
}

  static Future<List<Map<String, dynamic>>> getInactiveClients({
  int days = 30,
}) async {

  final prefs = await SharedPreferences.getInstance();

  final userId = int.parse(
    prefs.getString("user_id") ?? "0",
  );

  final res = await http.post(
    Uri.parse("$baseUrl/clients/inactive.php"),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "user_id": userId,
      "days": days,
    }),
  );

  final body = _decodeBody(res);

  if (body["success"] == true &&
      body["data"] is List) {
    return List<Map<String, dynamic>>.from(
      body["data"],
    );
  }

  throw Exception(
    body["message"] ??
        "Failed to load inactive clients",
  );
}

static Future<bool> addClient({
  required String name,
  String phone = "",
}) async {

  final prefs = await SharedPreferences.getInstance();

  final userId = int.parse(
    prefs.getString("user_id") ?? "0",
  );

  final res = await http.post(
    Uri.parse("$baseUrl/clients/add.php"),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "user_id": userId,
      "name": name,
      "phone": phone,
    }),
  );

  final body = _decodeBody(res);

  print(body);

  return body["success"] == true;
}

  static Future<bool> updateClientActivity(int clientId) async {
    final res = await http.post(
      Uri.parse("$baseUrl/clients/update_activity.php"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "client_id": clientId,
      }),
    );

    final body = _decodeBody(res);
    return body["success"] == true;
  }

  static Future<List<Map<String, dynamic>>> getTransactions() async {

  final prefs = await SharedPreferences.getInstance();

  final userId = int.parse(
    prefs.getString("user_id") ?? "0",
  );

  final res = await http.post(
    Uri.parse("$baseUrl/transactions/list.php"),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "user_id": userId,
    }),
  );

  final body = _decodeBody(res);

  if (body["success"] == true &&
      body["data"] is List) {
    return List<Map<String, dynamic>>.from(
      body["data"],
    );
  }

  throw Exception(
    body["message"] ??
        "Failed to load transactions",
  );
}

static Future<bool> addTransaction({
  required String type,
  required String partyType,
  int? partyId,
  required String title,
  required double amount,
  String note = "",
}) async {

  final prefs = await SharedPreferences.getInstance();

  final userId = int.parse(
    prefs.getString("user_id") ?? "0",
  );

  final res = await http.post(
    Uri.parse("$baseUrl/transactions/add.php"),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "user_id": userId,
      "type": type,
      "party_type": partyType,
      "party_id": partyId,
      "title": title,
      "amount": amount,
      "note": note,
    }),
  );

  print("ADD TRANSACTION STATUS: ${res.statusCode}");
  print("ADD TRANSACTION BODY: ${res.body}");

  final body = _decodeBody(res);

  if (body["success"] == true) {
    return true;
  }

  throw Exception(
    body["message"] ?? "Failed to add transaction",
  );
}

 static Future<Map<String, dynamic>> getDashboardSummary() async {

  final prefs = await SharedPreferences.getInstance();

  final userId = int.parse(
    prefs.getString("user_id") ?? "0",
  );

  final res = await http.post(
    Uri.parse("$baseUrl/dashboard/summary.php"),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "user_id": userId,
    }),
  );

  final body = _decodeBody(res);

  if (body["success"] == true &&
      body["data"] is Map<String, dynamic>) {
    return Map<String, dynamic>.from(
      body["data"],
    );
  }

  throw Exception(
    body["message"] ??
        "Failed to load dashboard summary",
  );
}

  static Future<List<Map<String, dynamic>>> getNotifications() async {

  final prefs = await SharedPreferences.getInstance();

  final userId = int.parse(
    prefs.getString("user_id") ?? "0",
  );

  final res = await http.post(
    Uri.parse("$baseUrl/notifications/list.php"),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "user_id": userId,
    }),
  );

  final body = _decodeBody(res);

  if (body["success"] == true &&
      body["data"] is List) {
    return List<Map<String, dynamic>>.from(
      body["data"],
    );
  }

  throw Exception(
    body["message"] ??
        "Failed to load notifications",
  );
}
  static Future<bool> markNotificationAsRead(int id) async {
  final res = await http.post(
    Uri.parse("$baseUrl/notifications/mark_read.php"),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "id": id,
    }),
  );

  final body = _decodeBody(res);

  return body["success"] == true;
}
  static Future<Map<String, dynamic>> login({
  required String email,
  required String password,
}) async {
  final res = await http.post(
    Uri.parse("$baseUrl/auth/login.php"),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "email": email,
      "password": password,
    }),
  );

  final body = _decodeBody(res);

  if (body["success"] == true && body["data"] is Map<String, dynamic>) {
    return Map<String, dynamic>.from(body["data"]);
  }

  throw Exception(body["message"] ?? "فشل تسجيل الدخول");
}
static Future<Map<String, dynamic>> register({
  required String name,
  required String phone,
  required String email,
  required String password,
  String role = "assistant",
}) async {
  final res = await http.post(
    Uri.parse("$baseUrl/auth/register.php"),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "name": name,
      "phone": phone,
      "email": email,
      "password": password,
      "role": role,
    }),
  );

  final body = _decodeBody(res);

  if (body["success"] == true) {
  return Map<String, dynamic>.from(body);
}

throw Exception(body["message"] ?? "فشل إنشاء الحساب");
}
static Future<Map<String, dynamic>> verifyOtp({
  required int userId,
  required String code,
}) async {
  final res = await http.post(
    Uri.parse("$baseUrl/auth/verify_otp.php"),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "user_id": userId,
      "code": code,
    }),
  );

  final body = _decodeBody(res);

  if (body["success"] == true) {
    return Map<String, dynamic>.from(body);
  }

  throw Exception(body["message"] ?? "فشل التحقق من الكود");
}

static Future<Map<String, dynamic>> resendOtp({
  required int userId,
}) async {
  final res = await http.post(
    Uri.parse("$baseUrl/auth/resend_otp.php"),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "user_id": userId,
    }),
  );

  final body = _decodeBody(res);

  if (body["success"] == true) {
    return Map<String, dynamic>.from(body);
  }

  throw Exception(body["message"] ?? "فشل إرسال كود جديد");

}
static Future<List<Map<String, dynamic>>> getSuppliers() async {
  final prefs = await SharedPreferences.getInstance();

  final userId = int.parse(
    prefs.getString("user_id") ?? "0",
  );

  final res = await http.post(
    Uri.parse("$baseUrl/suppliers/list.php"),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "user_id": userId,
    }),
  );

  final body = _decodeBody(res);

  if (body["success"] == true &&
      body["data"] is List) {
    return List<Map<String, dynamic>>.from(
      body["data"],
    );
  }

  throw Exception(
    body["message"] ??
        "Failed to load suppliers",
  );
}
static Future<bool> addSupplier({
  required String name,
  String phone = "",
}) async {
  final prefs = await SharedPreferences.getInstance();

  final userId = int.parse(
    prefs.getString("user_id") ?? "0",
  );

  final res = await http.post(
    Uri.parse("$baseUrl/suppliers/add.php"),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "user_id": userId,
      "name": name,
      "phone": phone,
    }),
  );

  final body = _decodeBody(res);

  return body["success"] == true;
}

}