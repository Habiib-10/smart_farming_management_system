import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _notifications = true;
  String _selectedLang = "Somali";

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDark') ?? false;
      _selectedLang = prefs.getString('lang') ?? "Somali";
    });
  }

  _toggleDarkMode(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => _isDarkMode = value);
    await prefs.setBool('isDark', value);
    // Halkan waxaad u baahan tahay Provider ama GetX si uu theme-ku u isbeddelo
  }

  _changeLanguage() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(title: Text("Somali"), onTap: () => _updateLang("Somali")),
          ListTile(title: Text("English"), onTap: () => _updateLang("English")),
        ],
      ),
    );
  }

  _updateLang(String lang) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => _selectedLang = lang);
    await prefs.setString('lang', lang);
    Navigator.pop(context);
  }

  _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Tirtir xogta user-ka
    Navigator.pushReplacementNamed(context, '/'); // U gudub Login Screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings"), backgroundColor: Colors.green),
      body: ListView(
        children: [
          ListTile(
            title: Text("Muuqaalka App-ka (Dark Mode)"),
            trailing: Switch(value: _isDarkMode, onChanged: _toggleDarkMode),
          ),
          ListTile(
            title: Text("Ogeysiisyada (Notifications)"),
            trailing: Switch(
                value: _notifications,
                onChanged: (v) => setState(() => _notifications = v)),
          ),
          ListTile(
            title: Text("Luuqadda (Language)"),
            subtitle: Text(_selectedLang),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _changeLanguage,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text("Ka bax (Logout)", style: TextStyle(color: Colors.red)),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
