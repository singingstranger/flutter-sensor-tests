import 'dart:async';
import 'package:flutter/material.dart';
import '../models/machine_state.dart';
import '../models/protocol_type.dart';
import '../models/protocol_stats.dart';
import '../services/http_service.dart';
import '../services/websocket_service.dart';
import '../services/protocol.dart';
import '../services/mqtt_service.dart';
class ControlViewModel extends ChangeNotifier {
  List<double> _history = [];
  List<double> get history => _history;

  final Map<ProtocolType, ProtocolService> _services = {};
  final Map<ProtocolType, ProtocolStats> _stats = {};

  Map<ProtocolType, ProtocolStats> get stats => _stats;

  ProtocolType _protocol = ProtocolType.http;
  ProtocolType get protocol => _protocol;

  ProtocolService? _service;

  MachineState _state = MachineState(
    sensorValue: 0,
    running: false,
    speed: 1.0,
  );

  MachineState get state => _state;

  StreamSubscription? _subscription;

  ControlViewModel() {
    _initService();
    startListening();
  }

  void _initService() {
    if(_services.isNotEmpty) return;
    _services[ProtocolType.http] =
        HttpService("http://127.0.0.1:8000");

    _services[ProtocolType.websocket] =
        WebSocketService("ws://127.0.0.1:8000/ws");

    _services[ProtocolType.mqtt] =
        MqttService();

    for (final entry in _services.entries) {
      _stats[entry.key] = ProtocolStats();

      entry.value.sensorStream().listen((data) {
        final stats = _stats[entry.key]!;

        final now = DateTime.now().millisecondsSinceEpoch / 1000;
        final latency = now - data.timestamp;

        stats.latestValue = data.value;
        stats.values.add(data.value);
        stats.latencies.add(latency);

        if (stats.values.length > 50) {
          stats.values.removeAt(0);
          stats.latencies.removeAt(0);
        }

        stats.messageCount++;

        notifyListeners();
      });
    }
    _service = _services[_protocol];
  }

  void startListening() {
    _subscription?.cancel();

    if (_service == null){
      return;
    }
    _subscription = _service!.sensorStream().listen((data) {
      _state = _state.copyWith(sensorValue: data.value);
      _history.add(data.value);
      if (_history.length > 50){
        _history.removeAt(0);
      }
      notifyListeners();
    });
  }

  Future<void> toggleRunning(bool value) async {
    _state = _state.copyWith(running: value);
    notifyListeners();

    if (!state.running) {
    _subscription?.pause();
    } 
    else {
      _subscription?.resume();
    }

    await _service!.sendCommand(_state.running, _state.speed);
  }

  Future<void> updateSpeed(double value) async {
    _state = _state.copyWith(speed: value);
    notifyListeners();

    await _service!.sendCommand(_state.running, _state.speed);
  }

  void setProtocol(ProtocolType type) {
    _subscription?.cancel();
    _service?.dispose();

    _protocol = type;
    _service = _services[_protocol];
    startListening();

    notifyListeners();
  }
  
  @override
  void dispose() {
    _subscription?.cancel();
    _service?.dispose();
    super.dispose();
  }
}

