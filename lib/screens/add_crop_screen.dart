import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Muhiim waa tan
import '../services/api_service.dart';
import '../models/crop_model.dart';

class AddCropScreen extends StatefulWidget {
  @override
  _AddCropScreenState createState() => _AddCropScreenState();
}

class _AddCropScreenState extends State<AddCropScreen> {
  final ApiService service = ApiService();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _statusController = TextEditingController();

  int? _currentUserId; // Halkan ayaa lagu kaydinayaa ID-ga la soo akhriyey
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserIdFromPrefs(); // Markaba soo akhri ID-ga qofka
  }

  // 1. Shaqadan waxay xogta ka soo akhrinaysaa SharedPreferences
  _loadUserIdFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // Hubi in 'user_id' uu yahay magaca aad u bixisay markii aad Login-ka samaynaysay
      _currentUserId = prefs.getInt('user_id');
    });
  }

  _save() async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("Error: User ID lama helin. Fadlan dib u Login dheh.")),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final crop = Crop(
        name: _nameController.text.trim(),
        status: _statusController.text.trim(),
        userId:
            _currentUserId, // Si toos ah ayuu u qaadanayaa ID-ga database-ka
      );

      bool ok = await service.addCrop(crop);

      setState(() => _isLoading = false);

      if (ok) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Dalagga waa la kaydiyey"),
              backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error: Save failed"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text("Add New Crop"), backgroundColor: Colors.green),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Muuji User ID-ga qofka (Optional/ReadOnly)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.green),
                    SizedBox(width: 10),
                    Text("User ID: ${_currentUserId ?? 'Loading...'}",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Crop Name",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.eco),
                ),
                validator: (v) => v!.isEmpty ? "Gali magaca dalagga" : null,
              ),
              SizedBox(height: 15),

              TextFormField(
                controller: _statusController,
                decoration: InputDecoration(
                  labelText: "Status (e.g. Healthy)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info_outline),
                ),
                validator: (v) => v!.isEmpty ? "Gali xaaladda dalagga" : null,
              ),

              SizedBox(height: 30),

              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 55),
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: _save,
                      child: Text("SAVE CROP",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
