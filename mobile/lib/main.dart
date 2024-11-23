import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<dynamic> sensorData = [];
  bool isLoading = true;

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.102:5000/get_data'));
      if (response.statusCode == 200) {
        setState(() {
          sensorData = json.decode(response.body);
          // Sort data by timestamp (assuming 'timestamp' is a field in the data)
          sensorData.sort((a, b) {
            DateTime timestampA = DateTime.parse(a['timestamp']);
            DateTime timestampB = DateTime.parse(b['timestamp']);
            return timestampB.compareTo(timestampA); // Sort in descending order
          });
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white, // Mengubah warna latar belakang di sini
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView( // Added SingleChildScrollView to handle overflow
                child: Padding(
                  padding: const EdgeInsets.all(23.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 32.0, bottom: 32.0),
                        child: Text(
                          'Hari ini',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        child: Container(
                          height: 215,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            image: DecorationImage(
                              image: AssetImage('assets/Bg.png'), // Pastikan path benar
                              fit: BoxFit.cover, // Agar gambar menutupi seluruh kontainer
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 116.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start, // Menyusun teks ke kiri
                                children: [
                                  Text(
                                    '${sensorData.isNotEmpty ? sensorData[0]['temperature'] : '-'}',
                                    style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 151,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/humi.png'),
                                    Text(
                                      'Kelembapan',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF13397E),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${sensorData.isNotEmpty ? sensorData[0]['humidity'] : '-'}',
                                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              height: 151,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/gas.png'),
                                    Text(
                                      'Gas',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF13397E),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${sensorData.isNotEmpty ? sensorData[0]['gas'] : '-'}',
                                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Container(
                        height: 282,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 39, bottom: 39),
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: true),
                              titlesData: FlTitlesData(
                                leftTitles: SideTitles(showTitles: true),
                                bottomTitles: SideTitles(showTitles: false),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border.all(color: Colors.grey),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: sensorData.asMap().entries.map((entry) {
                                    final index = entry.key.toDouble();
                                    final gasValue = double.tryParse(entry.value['gas']?.toString() ?? '0') ?? 0.0;
                                    return FlSpot(index, gasValue);
                                  }).toList(),
                                  isCurved: true,
                                  colors: [Colors.blue],
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  belowBarData: BarAreaData(show: false),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 57),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DetailPage(sensorData: sensorData)),
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Color(0xFF13397E)),
                          minimumSize: MaterialStateProperty.all(Size(double.infinity, 57)),
                        ),
                        child: Text(
                          'Lihat Rincian',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final List<dynamic> sensorData;

  DetailPage({required this.sensorData});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(),
        body: SingleChildScrollView( // Added SingleChildScrollView to handle overflow
          child: Column(
            children: [
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('Suhu', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF13397E))),
                    Text('Kelembapan', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF13397E))),
                    Text('Gas', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF13397E))),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true, // Prevent overflow
                itemCount: sensorData.length,
                itemBuilder: (context, index) {
                  final item = sensorData[index];
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(item['temperature'] ?? '-'),
                        Text(item['humidity'] ?? '-'),
                        Text(item['gas'] ?? '-'),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
