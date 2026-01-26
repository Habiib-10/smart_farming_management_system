import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/crop_model.dart';
import 'add_crop_screen.dart';
import 'edit_crop_screen.dart';
import 'analytics_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService service = ApiService();
  TextEditingController _searchController = TextEditingController();
  Future<List<Crop>>? _cropsFuture;
  List<Crop> _allCrops = [];
  List<Crop> _filteredCrops = [];

  String userName = "Farmer";
  String userEmail = "user@farm.so";

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Soo akhri xogta qofka Login-ka ah
    _refreshData();
    _searchController.addListener(_onSearchChanged);
  }

  // 1. Refresh Data
  void _refreshData() {
    setState(() {
      _cropsFuture = service.getCrops();
    });
  }

  // 2. Load User Data (Xogta Profile-ka iyo Dashboard-ka isku xira)
  _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? "Farmer";
      userEmail = prefs.getString('email') ?? "farmer@smartfarm.so";
    });
  }

  // 3. Logout Function
  void _handleLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Tirtir xogta la kaydiyey markuu qofku baxo
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  // 4. Delete Function
  void _confirmDelete(Crop crop) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Ma tirtirtaa?"),
        content: Text("Ma hubtaa inaad tirtirto ${crop.name}?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              if (crop.id != null) {
                bool deleted = await service.deleteCrop(crop.id!);
                Navigator.pop(context);
                if (deleted) {
                  _refreshData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Waa la tirtiray"),
                        backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _onSearchChanged() {
    setState(() {
      _filteredCrops = _allCrops
          .where((crop) => crop.name
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Colors.green.shade700;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF121212) : Color(0xFFF8FAF8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        title: Text("SMART FARM",
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
      ),
      drawer: _buildDrawer(primaryColor, isDark),
      body: RefreshIndicator(
        onRefresh: () async => _refreshData(),
        child: FutureBuilder<List<Crop>>(
          future: _cropsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(color: primaryColor));
            }
            if (snapshot.hasError)
              return Center(child: Text("Cillad ayaa dhacday!"));

            _allCrops = snapshot.data ?? [];
            List<Crop> displayList =
                _searchController.text.isEmpty ? _allCrops : _filteredCrops;

            return ListView(
              padding: EdgeInsets.all(20),
              children: [
                _buildHeader(userName, primaryColor),
                SizedBox(height: 20),
                _buildSearchBar(isDark),
                SizedBox(height: 25),
                Text("Dalagyadaada",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                if (displayList.isEmpty)
                  Center(
                      child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text("Wax xog ah lama helin.")))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: displayList.length,
                    itemBuilder: (context, index) => _buildCropCard(
                        displayList[index], isDark, primaryColor),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
              context, MaterialPageRoute(builder: (c) => AddCropScreen()));
          if (result == true) _refreshData();
        },
        backgroundColor: primaryColor,
        label: Text("ADD CROP", style: TextStyle(color: Colors.white)),
        icon: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Sidebar (Drawer) - Isku xirka Profile-ka iyo Dashboard-ka
  Widget _buildDrawer(Color color, bool isDark) {
    return Drawer(
      child: Column(children: [
        UserAccountsDrawerHeader(
          decoration: BoxDecoration(color: color),
          accountName:
              Text(userName, style: TextStyle(fontWeight: FontWeight.bold)),
          accountEmail: Text(userEmail),
          currentAccountPicture: GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context, MaterialPageRoute(builder: (c) => ProfileScreen()));
            },
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: color, size: 40),
            ),
          ),
        ),
        _drawerItem(Icons.dashboard, "Dashboard", () => Navigator.pop(context)),
        _drawerItem(Icons.analytics, "Analytics", () {
          Navigator.pop(context);
          Navigator.push(
              context, MaterialPageRoute(builder: (c) => AnalyticsScreen()));
        }),
        _drawerItem(Icons.person, "Profile", () {
          Navigator.pop(context);
          Navigator.push(
              context, MaterialPageRoute(builder: (c) => ProfileScreen()));
        }),
        _drawerItem(Icons.settings, "Settings", () {
          Navigator.pop(context);
          Navigator.push(
              context, MaterialPageRoute(builder: (c) => SettingsScreen()));
        }),
        Spacer(),
        Divider(),
        _drawerItem(Icons.logout, "Logout", _handleLogout,
            textColor: Colors.red),
        SizedBox(height: 20),
      ]),
    );
  }

  // Qaybaha kale (Cards, Header, SearchBar) waa sidoodii hore...
  Widget _drawerItem(IconData icon, String title, VoidCallback onTap,
      {Color? textColor}) {
    return ListTile(
        leading: Icon(icon, color: textColor),
        title: Text(title, style: TextStyle(color: textColor)),
        onTap: onTap);
  }

  Widget _buildHeader(String name, Color color) {
    return Container(
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(colors: [color, color.withOpacity(0.8)])),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Maalin wanaagsan,",
            style: TextStyle(color: Colors.white70, fontSize: 16)),
        SizedBox(height: 5),
        Text(name,
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Raadi dalag...",
          prefixIcon: Icon(Icons.search),
          filled: true,
          fillColor: isDark ? Colors.grey.shade800 : Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildCropCard(Crop crop, bool isDark, Color primaryColor) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
            backgroundColor: primaryColor.withOpacity(0.1),
            child: Icon(Icons.eco, color: primaryColor)),
        title: Text(crop.name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle:
            Text(crop.status, style: TextStyle(color: Colors.green.shade600)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () async {
                  final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (c) => EditCropScreen(crop: crop)));
                  if (result == true) _refreshData();
                }),
            IconButton(
                icon: Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => _confirmDelete(crop)),
          ],
        ),
      ),
    );
  }
}
