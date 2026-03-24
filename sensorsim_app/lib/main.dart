import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ControlPage(),
    );
  }
}

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  double sensorValue = 0;
  bool running = false;
  double speed = 1.0;

  Timer? timer;

  final String baseUrl = "http://localhost:8000"; 

  @override
  void initState() {
    super.initState();
    startPolling();
  }

  void startPolling() {
    timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      fetchSensor();
    });
  }

  Future<void> fetchSensor() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/sensor"));
      final data = jsonDecode(response.body);
      setState(() {
        sensorValue = data["value"].toDouble();
      });
    } catch (e) {
      print("Error fetching sensor: $e");
    }
  }

  Future<void> sendCommand() async {
    try {
      await http.post(
        Uri.parse("$baseUrl/command"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "running": running,
          "speed": speed,
        }),
      );
    } catch (e) {
      print("Error sending command: $e");
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Industrial Control")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Sensor Value",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              sensorValue.toStringAsFixed(2),
              style: const TextStyle(fontSize: 40),
            ),

            const SizedBox(height: 30),

            SwitchListTile(
              title: const Text("Machine Running"),
              value: running,
              onChanged: (val) {
                setState(() => running = val);
                sendCommand();
              },
            ),

            const SizedBox(height: 20),

            Text("Speed: ${speed.toStringAsFixed(2)}"),

            Slider(
              value: speed,
              min: 0,
              max: 5,
              divisions: 50,
              onChanged: (val) {
                setState(() => speed = val);
                sendCommand();
              },
            ),
          ],
        ),
      ),
    );
  }
}