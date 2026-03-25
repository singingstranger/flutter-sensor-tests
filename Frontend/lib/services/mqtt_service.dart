import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'protocol.dart';

class MqttService implements ProtocolService {
  late MqttServerClient client;

  final StreamController<double> _controller =
      StreamController<double>.broadcast();

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

    
    client.subscribe('sensor/value', MqttQos.atMostOnce);

    client.updates!.listen((events) {
      final payload = events[0].payload as MqttPublishMessage;

      final message =
          MqttPublishPayload.bytesToStringAsString(
              payload.payload.message);

      final data = jsonDecode(message);

      _controller.add(data["value"].toDouble());
    });
    } catch (e) {
      print("MQTT connection failed: $e");
      client.disconnect();
    }
  }

  @override
  Stream<double> sensorStream() => _controller.stream;

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