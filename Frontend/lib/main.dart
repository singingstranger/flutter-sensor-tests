import 'package:flutter/material.dart';
import 'services/http_service.dart';
import 'viewmodels/control_viewmodel.dart';
import 'views/control_page.dart';

void main() {
  final service = HttpService("http://127.0.0.1:8000");
  final viewModel = ControlViewModel(service);

  runApp(SensorTestApp(viewModel));
}

class SensorTestApp extends StatelessWidget {
  final ControlViewModel viewModel;

  const SensorTestApp(this.viewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ControlPage(viewModel: viewModel),
    );
  }
}