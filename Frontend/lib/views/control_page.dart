import 'package:flutter/material.dart';
import '../viewmodels/control_viewmodel.dart';

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
              ],
            ),
          );
        },
      ),
    );
  }
}