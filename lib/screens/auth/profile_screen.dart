import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:jelajah_nusantara/screens/auth/edit_profileScreen.dart';
import 'package:jelajah_nusantara/screens/controllers/auth_controller.dart';
import '../controllers/artikel_controllers.dart';
import '../widgets/grid_artikel.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<User> _futureUser;

  @override
  void initState() {
    super.initState();
    _futureUser = AuthController.getProfile();
  }

  Widget build(BuildContext context) {
    var children = [
      CircleAvatar(
        radius: 50,
        backgroundImage: const AssetImage('assets/images/profile.png'),
      ),
      SizedBox(height: 5),
      FutureBuilder(
        future: _futureUser,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final user = snapshot.data!;
            return Column(
              children: [
                Text(
                  user.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(user.name, style: TextStyle(color: Colors.white)),
              ],
            );
          }
        },
      ),
      SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditProfileScreen()),
              );
              if (updated == true) {
                setState(() {
                  _futureUser = AuthController.getProfile();
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0XFFD1A824),
              minimumSize: Size(115, 60),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.edit, color: Colors.white, size: 20),
                Text(
                  "Edit Profile",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          ElevatedButton(
            onPressed: () async {
              final message = await AuthController.Logout(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(message)));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0XFFD1A824),
              minimumSize: Size(115, 60),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.edit, color: Colors.white, size: 20),
                Text(
                  "Logout",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    ];
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height / 3,
                decoration: const BoxDecoration(
                  color: Color(0XFFD1A824),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: children,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Postingan Terbaru",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    FutureBuilder(
                      future: ArtikelControllers.getMyArtikel(1, 4),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                        } else {
                          final artikelList = snapshot.data ?? [];
                          return GridArtikelPopuler(artikelList: artikelList);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
