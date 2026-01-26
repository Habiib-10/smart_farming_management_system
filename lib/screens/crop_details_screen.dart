
import 'package:flutter/material.dart';
import '../models/crop_model.dart';

class CropDetailsScreen extends StatelessWidget {
  final Crop crop;

  CropDetailsScreen({required this.crop});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(crop.name.toUpperCase()),
        backgroundColor: isDark ? Colors.black : Colors.green[800],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image or Icon
            Center(
              child: Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.eco_rounded, size: 80, color: Colors.green),
              ),
            ),
            SizedBox(height: 30),
            
            _buildDetailTile("Crop Name", crop.name, Icons.label, isDark),
            _buildDetailTile("Health Status", crop.status, Icons.health_and_safety, isDark),
            
            // Example of extra data that might be in your Crop model
            _buildDetailTile("Planted Date", "January 10, 2026", Icons.calendar_today, isDark),
            _buildDetailTile("Expected Harvest", "March 20, 2026", Icons.agriculture, isDark),
            
            SizedBox(height: 30),
            Text("Growth Progress", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            LinearProgressIndicator(
              value: 0.6, // Example 60%
              backgroundColor: Colors.grey[300],
              color: Colors.green,
              minHeight: 10,
            ),
            SizedBox(height: 5),
            Text("60% reached maturity", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(String label, String value, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
            ],
          )
        ],
      ),
    );
  }
}