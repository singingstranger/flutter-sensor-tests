import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'protocol.dart';
import 'package:sensorsim_app/models/sensor_data.dart';

class MqttService implements ProtocolService {
  late MqttServerClient client;

  final StreamController<SensorData> _controller =
      StreamController<SensorData>.broadcast();

  MqttService() {
    client = MqttServerClient('localhost', '');
    _connect();
  }

  Future<void> _connect() async {
    try {
      client = MqttServerClient('127.0.0.1', 'flutter_client');

      client.logging(on: true);
      client.keepAlivePeriod = 20;

      client.onConnected = () => print("MQTT connected");
      client.onDisconnected = () => print("MQTT disconnected");

      // ✅ CONNECT FIRST
      await client.connect();

      client.subscribe('sensor/value', MqttQos.atMostOnce);

      client.updates!.listen((events) {
        final payload = events[0].payload as MqttPublishMessage;

        final message =
            MqttPublishPayload.bytesToStringAsString(
                payload.payload.message);

        final data = jsonDecode(message);

        final value = data["value"].toDouble();

        _controller.add(
          SensorData(
            value: value,
            timestamp: DateTime.now().millisecondsSinceEpoch.toDouble(),
          ),
        );
      });
    } catch (e) {
      print("MQTT connection failed: $e");
      client.disconnect();
    }
  }

  @override
  Stream<SensorData> sensorStream() => _controller.stream;

  @override
  Future<void> sendCommand(bool running, double speed) async {
    final payload = jsonEncode({
      "running": running,
      "speed": speed,
    });

    final builder = MqttClientPayloadBuilder();
    builder.addString(payload);

    client.publishMessage(
      "machine/command",
      MqttQos.atMostOnce,
      builder.payload!,
    );
  }

  @override
  void dispose() {
    client.disconnect();
    _controller.close();
  }
}