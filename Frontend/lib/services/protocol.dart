abstract class ProtocolService{
  Stream<double> sensorStream();
  Future<void> sendCommand(bool running, double speed);
  void dispose();
}