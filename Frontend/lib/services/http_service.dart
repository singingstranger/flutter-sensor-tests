import 'dart:convert';
import 'package:http/http.dart' as http;
import 'protocol.dart';
import 'package:sensorsim_app/models/sensor_data.dart';

class HttpService implements ProtocolService {
  final String baseUrl;

  HttpService(this.baseUrl);

  @override
  Stream<SensorData> sensorStream() async*{
    while(true){
      final value = await getSensorValue();
      yield SensorData(
        value: value, 
        timestamp: DateTime.now().millisecondsSinceEpoch.toDouble(),);
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
  @override
  Future<double> getSensorValue() async {
    final res = await http.get(Uri.parse("$baseUrl/sensor"));
    final data = jsonDecode(res.body);
    return data["value"].toDouble();
  }

  @override
  Future<void> sendCommand(bool running, double speed) async {
    await http.post(
      Uri.parse("$baseUrl/command"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "running": running,
        "speed": speed,
      }),
    );
  }

  @override
  void dispose() {}
}