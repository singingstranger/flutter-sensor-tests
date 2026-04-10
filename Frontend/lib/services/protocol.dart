import 'package:sensorsim_app/models/sensor_data.dart';

abstract class ProtocolService{
  Stream<SensorData> sensorStream();
  Future<void> sendCommand(bool running, double speed);
  void dispose();
}