import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Waxaan ku bilabaynaa "Loading..." si uusan error u bixin inta xogta la keenayo
  String name = "Loading...";
  String email = "Loading...";
  String role = "User";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Tani waa qaybta ugu muhiimsan: Ka aqri xogta qofka Login-ka ah
  _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // Hubi inay magacyadani la mid yihiin kuwa aad ku kaydisay Login-ka
      name = prefs.getString('name') ?? "Farmer";
      email = prefs.getString('email') ?? "user@smartfarm.so";
      role = prefs.getString('role') ?? "Muxaadaro";
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.green.shade700;

    return Scaffold(
      backgroundColor: Color(0xFFF8FAF8),
      appBar: AppBar(
        title: Text("Profile-kaaga",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(primaryColor),
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildProfileTile(Icons.person_outline, "Magaca Buuxa", name),
                  _buildProfileTile(
                      Icons.email_outlined, "Email Address", email),
                  _buildProfileTile(
                      Icons.verified_user_outlined, "Doorkaaga (Role)", role),
                  _buildProfileTile(
                      Icons.language, "Luuqadda App-ka", "Somali"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Header-ka Profile-ka
  Widget _buildHeader(Color color) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 60, color: color),
          ),
          SizedBox(height: 15),
          Text(name,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          Text(email, style: TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildProfileTile(IconData icon, String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green.shade700),
          SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
