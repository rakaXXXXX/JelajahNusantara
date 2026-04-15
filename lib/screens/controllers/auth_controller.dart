import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_screen.dart';
import '../services/auth_services.dart';
import '../widgets/bottom_navbar.dart';
import '../models/user_model.dart';

class AuthController {
  static Future<String> register(
    BuildContext context,
    String name,
    String username,
    String password,
  ) async {
    final result = await AuthServices.register(name, username, password);
    final responseData = jsonDecode(result.body);

    if (result.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return responseData['message'] ?? "Registrasi Berhasil";
    } else {
      if (result.statusCode == 400) {
        final firstError = responseData['errors'][0];
        return (firstError['message'] ?? "Terjadi Kesalahan");
      } else {
        return (responseData['message'] ?? "Terjadi Kesalahan");
      }
    }
  }

  static Future<String> login(
    BuildContext context,
    String username,
    String password,
  ) async {
    final result = await AuthServices.login(username, password);
    final responseData = jsonDecode(result.body);

    if (result.statusCode == 200) {
      final token = responseData['token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavbar()),
      );
      return responseData['message'] ?? "Login Berhasil";
    } else {
      if (result.statusCode == 400) {
        final firstError = responseData['errors'][0];
        return (firstError['message'] ?? "Terjadi Kesalahan");
      }
      return (responseData['messagge'] ?? 'Login Gagal');
    }
  }

  static Future<User> getProfile() async {
    final result = await AuthServices.getProfile();
    final responseData = jsonDecode(result.body);

    if (result.statusCode == 200) {
      final data = responseData['data'];
      return User.fromJson(data);
    } else {
      throw (responseData['message'] ?? 'Gagal Memuat data User');
    }
  }

  static Future<String> Logout(BuildContext context) async {
    final result = await AuthServices.Logout();
    final responseData = jsonDecode(result.body);

    if (result.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return responseData['message'] ?? "Logout berhasil";
    } else {
      return (responseData['message'] ?? "Terjadi kesalahan");
    }
  }

  static Future<String> updateProfile({
    required String name,
    File? imageFile,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      var request = http.MultipartRequest(
        "POST",
        Uri.parse("https://api-pariwisata.rakryan.id/auth"),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.fields['name'] = name;

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('photo', imageFile.path),
        );
      }

      final response = await request.send();
      final resBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return "Profil berhasil diperbarui";
      } else {
        return "Gagal update profil: $resBody";
      }
    } catch (e) {
      return "Error: $e";
    }
  }
}
