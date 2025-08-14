
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:project3d/dashboard/dashboard.dart';
import 'package:project3d/home/home.dart';
import 'package:project3d/splash/splash.dart';
// import 'dart:html' as html;
import 'dart:js_interop' ;
import 'dart:ui_web' as ui;


@JS() // Bind to the global JavaScript scope
external Document get document;

@JS()
@staticInterop
class Document {}

extension DocumentExtension on Document {
  external Element createElement(String tag);
  external Element? getElementById(String id);
  external Element get body;
}

@JS()
@staticInterop
class Element {}

extension ElementExtension on Element {
  external set src(String url);
  external set type(String type);
  external void setAttribute(String name, String value);
  // external void appendChild(Element element);
  external Element appendChild(Element element);
}

void injectModelViewerScript() {
 
   final scriptUrl = dotenv.env['MODEL_VIEWER_SCRIPT_URL'];
   

  // Create script element and set attributes
  final script = document.createElement('script');
  script.type = 'module';
  script.src = scriptUrl??'';
  // Append to document body
  document.body.appendChild(script);
}
void main() async {
  
  await dotenv.load(fileName: ".env");
  
   WidgetsFlutterBinding.ensureInitialized();
 injectModelViewerScript();

  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home:
     
       SplashScreen(),
      debugShowCheckedModeBanner: false,
     
    );
  }
}
