import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class MachineState {
  final double sensorValue;
  final bool running;
  final double speed;

  MachineState({
    required this.sensorValue,
    required this.running,
    required this.speed,
  });

  MachineState copyWith({
    double? sensorValue,
    bool? running,
    double? speed,
  }) {
    return MachineState(
      sensorValue: sensorValue ?? this.sensorValue,
      running: running ?? this.running,
      speed: speed ?? this.speed,
    );
  }
}