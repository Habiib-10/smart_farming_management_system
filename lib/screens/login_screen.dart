import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool isLoading = false;
  bool _obscurePassword = true;

  void _handleLogin() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      _showError("Fadlan geli Email-ka iyo Password-ka");
      return;
    }

    setState(() => isLoading = true);
    try {
      final res = await _apiService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      // HUBINTA LOGIN-KA
      if (res != null && (res['success'] == true || res.containsKey('token'))) {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        // --- QAYBTA CUSUB: KAYDINTA XOGTA BUUXDA ---
        var user = res['user'];

        // 1. Kaydi User ID (Muhiim u ah Add Crop)
        if (user['id'] != null) {
          await prefs.setInt('user_id', int.parse(user['id'].toString()));
        }

        // 2. Kaydi Magaca
        await prefs.setString('name', user['name'] ?? "User");

        // 3. Kaydi Email-ka
        await prefs.setString(
            'email', user['email'] ?? emailController.text.trim());

        // 4. Kaydi Doorka (Role-ka) - Halkan ayaa lagu daray
        await prefs.setString('role', user['role'] ?? "Farmer");

        if (mounted) {
          // U gudub Dashboard-ka
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } else {
        _showError(res?['message'] ?? "Email ama Password khaldan!");
      }
    } catch (e) {
      _showError("Cilad: Xidhiidhka server-ka waa go'an yahay!");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // --- UI-GA SNACKBAR-KA ---
  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(Icons.error_outline, color: Colors.white),
          SizedBox(width: 10),
          Expanded(child: Text(msg)),
        ]),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.green.shade700;

    return Scaffold(
      backgroundColor: Color(0xFFF8FAF8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              children: [
                // LOGO SECTION
                _buildLogo(primaryColor),
                SizedBox(height: 24),
                Text("Smart Farming",
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.green.shade900)),
                Text("Maamul dalagyadaada si fudud",
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                SizedBox(height: 48),

                // INPUT FIELDS
                _buildTextField(emailController, "Email Address",
                    Icons.alternate_email_rounded),
                SizedBox(height: 18),
                _buildTextField(
                    passwordController, "Password", Icons.vpn_key_rounded,
                    isPass: true),

                SizedBox(height: 24),

                // LOGIN BUTTON
                isLoading
                    ? CircularProgressIndicator(color: primaryColor)
                    : _buildLoginButton(primaryColor),

                SizedBox(height: 32),

                // FOOTER
                _buildFooter(primaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(Color color) {
    return Hero(
      tag: 'logo',
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Colors.green.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5)
            ]),
        child: Icon(Icons.eco_rounded, size: 70, color: color),
      ),
    );
  }

  Widget _buildLoginButton(Color color) {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: color.withOpacity(0.3), blurRadius: 12, offset: Offset(0, 6))
      ]),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        onPressed: _handleLogin,
        icon: Icon(Icons.login_rounded),
        label: Text("LOG IN",
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController ctrl, String label, IconData icon,
      {bool isPass = false}) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: Offset(0, 4))
          ]),
      child: TextField(
        controller: ctrl,
        obscureText: isPass ? _obscurePassword : false,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.green.shade600),
          suffixIcon: isPass
              ? IconButton(
                  icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                )
              : null,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _buildFooter(Color color) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text("Ma haysatid Account?"),
      TextButton(
        onPressed: () => Navigator.pushNamed(context, '/register'),
        child: Text("Is-diiwaangeli",
            style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ),
    ]);
  }
}
