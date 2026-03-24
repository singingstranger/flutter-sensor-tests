import 'dart:async';
import 'package:flutter/material.dart';
import '../models/machine_state.dart';
import '../services/protocol.dart';

class ControlViewModel extends ChangeNotifier {
  final ProtocolService service;

  MachineState _state = MachineState(
    sensorValue: 0,
    running: false,
    speed: 1.0,
  );

  MachineState get state => _state;

  Timer? _timer;

  ControlViewModel(this.service) {
    startPolling();
  }

  void startPolling() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) async {
      final value = await service.getSensorValue();

      _state = _state.copyWith(sensorValue: value);
      notifyListeners();
    });
  }

  Future<void> toggleRunning(bool value) async {
    _state = _state.copyWith(running: value);
    notifyListeners();

    await service.sendCommand(_state.running, _state.speed);
  }

  Future<void> updateSpeed(double value) async {
    _state = _state.copyWith(speed: value);
    notifyListeners();

    await service.sendCommand(_state.running, _state.speed);
  }

  @override
  void dispose() {
    _timer?.cancel();
    service.dispose();
    super.dispose();
  }
}