import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import '../models/crop_model.dart';

class AnalyticsScreen extends StatefulWidget {
  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final ApiService service = ApiService();

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Colors.green.shade700;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF121212) : Color(0xFFF8FAF8),
      appBar: AppBar(
        title: Text("Farm Analytics", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: FutureBuilder<List<Crop>>(
        future: service.getCrops(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryColor));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No data available for analytics"));
          }

          List<Crop> crops = snapshot.data!;
          
          // Data Calculation
          int healthy = crops.where((c) => c.status.toLowerCase() == "healthy").length;
          int dry = crops.where((c) => c.status.toLowerCase() == "dry").length;
          int alert = crops.length - (healthy + dry);

          return SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCards(crops.length, healthy, isDark),
                SizedBox(height: 25),
                Text("Crop Health Distribution", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                _buildPieChart(healthy, dry, alert, isDark),
                SizedBox(height: 30),
                Text("Growth Statistics", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                _buildBarChart(healthy, dry, alert, primaryColor, isDark),
                SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(int total, int healthy, bool isDark) {
    return Row(
      children: [
        _infoTile("Total Crops", total.toString(), Colors.blue, isDark),
        SizedBox(width: 15),
        _infoTile("Efficiency", "${((healthy / total) * 100).toStringAsFixed(0)}%", Colors.green, isDark),
      ],
    );
  }

  Widget _infoTile(String label, String value, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(int healthy, int dry, int alert, bool isDark) {
    return Container(
      height: 250,
      margin: EdgeInsets.symmetric(vertical: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: PieChart(
        PieChartData(
          sectionsSpace: 5,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(value: healthy.toDouble(), color: Colors.green, title: 'Healthy', radius: 50, titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            PieChartSectionData(value: dry.toDouble(), color: Colors.orange, title: 'Dry', radius: 50, titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            PieChartSectionData(value: alert.toDouble(), color: Colors.redAccent, title: 'Alert', radius: 50, titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(int healthy, int dry, int alert, Color primary, bool isDark) {
    return Container(
      height: 250,
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(show: true, topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))),
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: healthy.toDouble(), color: Colors.green, width: 20)]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: dry.toDouble(), color: Colors.orange, width: 20)]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: alert.toDouble(), color: Colors.redAccent, width: 20)]),
          ],
        ),
      ),
    );
  }
}