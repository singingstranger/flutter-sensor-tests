import 'dart:math';

class ProtocolStats{
  double latestValue = 0;
  List<double> values = [];
  List<double> latencies = [];

  int messageCount = 0;
  DateTime startTime = DateTime.now();

  DateTime? lastTimeStamp;

  double get updateRate {
    final seconds = DateTime.now().difference(startTime).inMilliseconds/1000;
    return seconds > 0 ? messageCount/seconds : 0;
  }

  double get avgLatency{
    if (latencies.isEmpty) return 0;
    final total = latencies.reduce((a,b) => a+b);
    return total / latencies.length;
  }

  double get jitter{
    final n = latencies.length;
    if (n<2) return 0;
    final avg = avgLatency;
    final variance = latencies.map((l) => pow(l-avg, 2)).reduce((a,b) => a+b)/n;
    return sqrt(variance);
  }
}