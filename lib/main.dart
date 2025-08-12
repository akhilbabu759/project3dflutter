import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
void main()  {
   WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('ModelViewer mini')),
        body: const ModelViewer(
          src: 'assets/crt_tv.glb',
          alt: 'A 3D model of an astronaut',
          ar: true,
          autoRotate: true,
          cameraControls: true,
        ),
      ),
    );
  }
}
