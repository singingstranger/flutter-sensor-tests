import 'dart:async';
import 'package:flutter/material.dart';
import '../models/machine_state.dart';
import '../models/protocol_type.dart';
import '../services/http_service.dart';
import '../services/websocket_service.dart';
import '../services/protocol.dart';
class ControlViewModel extends ChangeNotifier {
  List<double> _history = [];
  List<double> get history => _history;

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
    switch (_protocol) {
      case ProtocolType.http:
        _service = HttpService("http://127.0.0.1:8000");
        break;
      case ProtocolType.websocket:
        _service = WebSocketService("ws://127.0.0.1:8000/ws");
        break;
      case ProtocolType.mqtt:
        //implement mqtt later
        break;
    }
  }

  void startListening() {
    _subscription?.cancel();

    _subscription = _service!.sensorStream().listen((value) {
      _state = _state.copyWith(sensorValue: value);
      _history.add(value);
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
    _initService();
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