import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jelajah_nusantara/screens/services/artikel_services.dart';
import 'package:jelajah_nusantara/screens/widgets/bottom_navbar.dart';
import '../models/artikel_model.dart';

class ArtikelControllers {
  static Future<List<Artikel>> getArtikel(int page, int limit) async {
    final result = await ArtikelServices.getArtikel(page, limit);

    if (result.statusCode == 200) {
      final data = jsonDecode(result.body)['data'] as List<dynamic>?;
      return data?.map((item) => Artikel.formJson(item)).toList() ?? [];
    } else {
      throw Exception('Gagal Memuat Data Artikel');
    }
  }

  static Future<List<Artikel>> getMyArtikel(int page, int limit) async {
    final result = await ArtikelServices.getMyArtikel(page, limit);

    if (result.statusCode == 200) {
      final data = jsonDecode(result.body)['data'] as List<dynamic>?;
      return data?.map((item) => Artikel.formJson(item)).toList() ?? [];
    } else if (result.statusCode == 404) {
      throw Exception('Kamu Belum Punya Artikel');
    } else {
      throw ('Gagal memuat data');
    }
  }

  static Future<String> createArtikel(
    File image,
    String title,
    String description,
    BuildContext context,
  ) async {
    final result = await ArtikelServices.createArtikel(
      image,
      title,
      description,
    );
    final response = await http.Response.fromStream(result);
    final objectResponse = jsonDecode(response.body);

    if (response.statusCode == 201) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavbar()),
      );
      return objectResponse['message'] ?? "Tambah data berhasil";
    } else if (response.statusCode == 400) {
      final firstError = objectResponse['errors'][0];
      return (firstError['message'] ?? "Terjadi Kesalahan");
    } else {
      return (objectResponse['message'] ?? "Terjadi Kesalahan");
    }
  }

  static Future<String> updateArtikel({
    required String? id,
    File? image,
    String? title,
    String? description,
    required BuildContext context,
  }) async {
    final result = await ArtikelServices.updateArtikel(
      id: id,
      image: image,
      title: title,
      description: description,
    );
    final response = await http.Response.fromStream(result);
    final objectResponse = jsonDecode(response.body);

    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavbar()),
      );
      return objectResponse['message'] ?? "update data berhasil";
    } else if (response.statusCode == 400) {
      final firstError = objectResponse['errors']?[0];
      return firstError?['message'] ?? "Terjadi Kesalahan";
    } else {
      return objectResponse['message'] ?? "Terjadi Kesalahan";
    }
  }

  static Future<String> deleteArtikel(String id, BuildContext context) async {
    final result = await ArtikelServices.deleteArtikel(id);
    final responseData = jsonDecode(result.body);

    if (result.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavbar()),
      );
      return responseData['message'] ?? "Delete data berhasil";
    } else {
      return (responseData['message'] ?? "Terjadi Kesalahan");
    }
  }
}
