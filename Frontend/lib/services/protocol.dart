abstract class ProtocolService{
  Future<double> getSensorValue();
  Future<void> sendCommand(bool running, double speed);
  void dispose();
}