import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:project3d/dashboard/dashboard.dart';
import 'package:project3d/home/home.dart';
import 'package:project3d/splash/splash.dart';
void main() async {
  // Load environment variables from the .env file
  await dotenv.load(fileName: ".env");
  // This is needed to use the isolate feature of model_viewer_plus
   WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
      // theme: ThemeData(),
      //  DashboardScreen(),
      // Scaffold(
      //   appBar: AppBar(title: const Text('ModelViewer mini')),
      //   body: const ModelViewer(
      //     src: 'http://res.cloudinary.com/dqkhcdxag/raw/upload/v1755069795/models/59840b1404ddee79d56f47ee94a5e1c8_xsocnn'
      //     // 'assets/crt_tv.glb'
      //     , // a 3D model of a CRT TV
      //     alt: 'A 3D model of an astronaut',
      //     ar: true,
      //     autoRotate: true,
      //     cameraControls: true,
      //   ),
      // ),
    );
  }
}
