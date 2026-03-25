import 'package:flutter/material.dart';
import '../viewmodels/control_viewmodel.dart';
import '../models/protocol_type.dart';
import 'package:fl_chart/fl_chart.dart';

class ControlPage extends StatelessWidget {
  final ControlViewModel viewModel;

  const ControlPage({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Industrial Control")),
      body: AnimatedBuilder(
        animation: viewModel,
        builder: (context, _) {
          final state = viewModel.state;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              
              children: [
                DropdownButton<ProtocolType>(
                  value: viewModel.protocol,
                  onChanged: (value) {
                    if (value != null) {
                      viewModel.setProtocol(value);
                    }
                  },

                  items: const [
                    DropdownMenuItem(
                      value: ProtocolType.http,
                      child: Text("HTTP (Polling)"),
                    ),
                    DropdownMenuItem(
                      value: ProtocolType.websocket,
                      child: Text("WebSocket (Real-time)"),
                    ),
                    DropdownMenuItem(
                      value: ProtocolType.mqtt,
                      child: Text("MQTT (Coming Soon)"),
                    ),
                  ],
                ), 
                Text(
                  "Protocol: ${viewModel.protocol.name.toUpperCase()}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  state.sensorValue.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 50),
                ),

                SwitchListTile(
                  title: const Text("Machine Running"),
                  value: state.running,
                  onChanged: viewModel.toggleRunning,
                ),

                Text("Speed: ${state.speed.toStringAsFixed(2)}"),

                Slider(
                  value: state.speed,
                  min: 0,
                  max: 5,
                  onChanged: viewModel.updateSpeed,
                ),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData( 
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(
                            viewModel.history.length,
                            (i) => FlSpot(i.toDouble(), viewModel.history[i]),
                            ),
                            isCurved: true,
                            dotData: FlDotData(show:false),
                        ),
                      ],
                    ),
                  ),

                ),
              ],
            ),
          );
        },
      ),
    );
  }
}