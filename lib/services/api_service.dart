import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/crop_model.dart';

class ApiService {
  // HUBI: Haddii aad Android Emulator isticmaalayso, localhost u baddel 10.0.2.2
  final String baseUrl = "http://localhost:5000/api";

  // --- HELITAANKA TOKEN-KA ---
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // --- REGISTER ---
  Future<Map<String, dynamic>> register(
      String name, String email, String password, String role) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "role": role,
        }),
      );

      if (res.body.isNotEmpty) return jsonDecode(res.body);
      return {"success": false, "message": "Server-ku ma soo jawaabin"};
    } catch (e) {
      return {"success": false, "message": "Cilad ayaa dhacday: $e"};
    }
  }

  // --- LOGIN ---
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      final data = jsonDecode(res.body);

      // Kaydi Token-ka iyo User ID-ga markuu Login guulaysto
      if (res.statusCode == 200 && data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        // Hubi in API-gaagu soo celiyo 'id'
        if (data['user'] != null && data['user']['id'] != null) {
          await prefs.setInt('user_id', data['user']['id']);
        }
      }
      return data;
    } catch (e) {
      return {"success": false, "message": "Login-ku ma suurtagalin: $e"};
    }
  }

  // --- ADD CROP (SAVE) ---
  Future<bool> addCrop(Crop crop) async {
    try {
      final token = await _getToken();
      final res = await http.post(
        Uri.parse('$baseUrl/crops'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode(crop.toJson()), // Waxay diraysaa user_id, name, status
      );
      return res.statusCode == 201 || res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- GET CROPS (LIST) ---
  Future<List<Crop>> getCrops() async {
    try {
      final token = await _getToken();
      final res = await http.get(
        Uri.parse('$baseUrl/crops'),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        List data = jsonDecode(res.body);
        return data.map((e) => Crop.fromJson(e)).toList();
      }
    } catch (e) {
      print("Cilad markii Crops-ka la keenayay: $e");
    }
    return [];
  }

  // --- UPDATE CROP ---
  Future<bool> updateCrop(int id, Crop crop) async {
    try {
      final token = await _getToken();
      final res = await http.put(
        Uri.parse('$baseUrl/crops/$id'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode(crop.toJson()),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- DELETE CROP ---
  Future<bool> deleteCrop(int id) async {
    try {
      final token = await _getToken();
      final res = await http.delete(
        Uri.parse('$baseUrl/crops/$id'),
        headers: {"Authorization": "Bearer $token"},
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Wax walba tirtir (Token & UserID)
  }
}
