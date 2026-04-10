import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'protocol.dart';
import 'package:sensorsim_app/models/sensor_data.dart';

class WebSocketService implements ProtocolService {
  final String url;
  late WebSocketChannel channel;

  late final Stream<SensorData> _stream;

  WebSocketService(this.url) {
    channel = WebSocketChannel.connect(Uri.parse(url));

    _stream = channel.stream
        .asBroadcastStream()
        .map((message) {
          try {
            final data = jsonDecode(message);
            final value = data["value"].toDouble();

            return SensorData(
              value: value,
              timestamp: DateTime.now().millisecondsSinceEpoch.toDouble(),
            );
          } catch (e) {
            print("WebSocket parse error: $e");

            // ⚠️ Fallback (avoid returning invalid type)
            return SensorData(
              value: 0,
              timestamp: DateTime.now().millisecondsSinceEpoch.toDouble(),
            );
          }
        });
  }

  @override
  Stream<SensorData> sensorStream() => _stream;

  @override
  Future<void> sendCommand(bool running, double speed) async {
    channel.sink.add(jsonEncode({
      "running": running,
      "speed": speed
    }));
  }

  @override
  void dispose() {
    channel.sink.close();
  }
}