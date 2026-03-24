import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'protocol.dart';

class WebSocketService implements ProtocolService {
  final String url;
  late WebSocketChannel channel;

  late final Stream<double> _stream;

  WebSocketService(this.url) {
    channel = WebSocketChannel.connect(Uri.parse(url));

    _stream = channel.stream
        .asBroadcastStream()
        .map((message) {
          try {
            final data = jsonDecode(message);
            return data["value"].toDouble();
          } catch (e) {
        print("WebSocket parse error: $e");
        return 0;
      }
    });
  }

  @override
  Stream<double> sensorStream() => _stream;

  @override
  Future<double> getSensorValue() async {
    // Not really used for WebSockets anymore
    return 0;
  }

  @override
  Future<void> sendCommand(bool running, double speed) async {
    // Will implement later (bidirectional WS)
  }

  @override
  void dispose() {
    channel.sink.close();
  }
}