import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  // Role Variables - Farmer iyo Admin
  String _selectedRole = 'Farmer';
  final List<String> _roles = ['Farmer', 'Admin'];
  bool _isLoading = false;

  void _register() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showSnackBar("Fadlan buuxi meelaha banaan!", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _selectedRole,
      );

      // Waxaan u handle-gareynay si uusan 'null' u soo tuurin
      if (response != null && response['success'] == true) {
        _showSnackBar("Account-ka si guul leh baa loo abuuray!", Colors.green.shade700);
        if (mounted) Navigator.pop(context);
      } else {
        String errorMsg = response?['message'] ?? "Email-kan horay ayaa loo isticmaalay";
        _showSnackBar("Cilad: $errorMsg", Colors.redAccent);
      }
    } catch (e) {
      _showSnackBar("Server-ka lama heli karo. Hubi in Node.js uu shaqaynayo!", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent, 
        leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: Colors.green), onPressed: () => Navigator.pop(context))),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            Icon(Icons.person_add_alt_1_rounded, size: 80, color: Colors.green),
            SizedBox(height: 10),
            Text("ABUUR ACCOUNT", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green.shade900)),
            SizedBox(height: 30),
            _buildField(_nameController, "Magacaaga", Icons.person),
            SizedBox(height: 15),
            _buildField(_emailController, "Email", Icons.email),
            SizedBox(height: 15),
            
            // Dropdown Farmer/Admin
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: InputDecoration(
                labelText: "Doorkaaga (Role)",
                prefixIcon: Icon(Icons.shield, color: Colors.green),
                filled: true, fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
              items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (val) => setState(() => _selectedRole = val!),
            ),
            
            SizedBox(height: 15),
            _buildField(_passwordController, "Password", Icons.lock, isPass: true),
            SizedBox(height: 30),
            
            _isLoading ? CircularProgressIndicator() : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700, 
                minimumSize: Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: _register,
              child: Text("REGISTER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {bool isPass = false}) {
    return TextField(
      controller: ctrl,
      obscureText: isPass,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green),
        filled: true, fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}