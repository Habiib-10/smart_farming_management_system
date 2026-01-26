import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/crop_model.dart';

class EditCropScreen extends StatefulWidget {
  final Crop crop;
  EditCropScreen({required this.crop});

  @override
  _EditCropScreenState createState() => _EditCropScreenState();
}

class _EditCropScreenState extends State<EditCropScreen> {
  late TextEditingController _nameController;
  late TextEditingController _statusController;
  final _apiService = ApiService();
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.crop.name);
    _statusController = TextEditingController(text: widget.crop.status);
  }

  void _updateCrop() async {
    if (_nameController.text.isEmpty || _statusController.text.isEmpty) return;
    
    setState(() => _isUpdating = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? currentUserId = prefs.getInt('user_id');

      final updatedCrop = Crop(
        id: widget.crop.id,
        name: _nameController.text.trim(),
        status: _statusController.text.trim(),
        userId: currentUserId ?? widget.crop.userId,
      );

      bool success = await _apiService.updateCrop(widget.crop.id!, updatedCrop);

      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Waa la cusboonaysiiyey!"), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ma suuragalin cusboonaysiinta!")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cillad ayaa dhacday!")));
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.green[700]!;
    return Scaffold(
      appBar: AppBar(title: Text("Edit Crop"), backgroundColor: primaryColor),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildTextField(_nameController, "Crop Name", Icons.grass),
            SizedBox(height: 15),
            _buildTextField(_statusController, "Status", Icons.info_outline),
            SizedBox(height: 30),
            _isUpdating ? CircularProgressIndicator() : ElevatedButton(
              onPressed: _updateCrop,
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: Size(double.infinity, 55)),
              child: Text("Cusboonaysii", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}