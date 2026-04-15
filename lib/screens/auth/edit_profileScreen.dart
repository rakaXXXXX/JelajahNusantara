import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/bottom_navbar.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController usernameController = TextEditingController();
  File? selectedImage;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  /// 🔹 Load data dari SharedPreferences
  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    usernameController.text = prefs.getString("username") ?? "";

    String? imagePath = prefs.getString("profile_image");

    if (imagePath != null && File(imagePath).existsSync()) {
      selectedImage = File(imagePath);
    }

    setState(() => loading = false);
  }

  /// 🔹 Ambil gambar dari gallery
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final temp = File(picked.path);

      // Simpan ke folder aplikasi
      final appDir = await path_provider.getApplicationDocumentsDirectory();
      final fileName = picked.name;
      final savedImage = await temp.copy('${appDir.path}/$fileName');

      setState(() {
        selectedImage = savedImage;
      });
    }
  }

  /// 🔹 Simpan profil ke SharedPreferences
  Future<void> saveProfile() async {
    final prefs = await SharedPreferences.getInstance();

    // simpan ke key "username" agar konsisten dengan HomeScreen
    await prefs.setString("username", usernameController.text);

    if (selectedImage != null) {
      await prefs.setString("profile_image", selectedImage!.path);
    }

    // Kembalikan true agar caller tahu untuk refresh data (pakai .then on Navigator)
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BottomNavbar()),
    ).then((shouldRefresh) {
      if (shouldRefresh == true) loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: const Color(0XFFD1A824),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: selectedImage != null
                    ? FileImage(selectedImage!)
                    : const AssetImage("assets/images/profile.png")
                          as ImageProvider,
                child: const Align(
                  alignment: Alignment.bottomRight,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.camera_alt, size: 18),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Username (sebelumnya 'name')
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0XFFD1A824),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Simpan Perubahan",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
