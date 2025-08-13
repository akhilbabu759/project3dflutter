
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
  // Define a fallback URL in case the .env variable is not set.
  // const fallbackUrl = 'https://unpkg.com/@google/model-viewer/dist/model-viewer.min.js';
  // Read the URL from the environment variables, using the fallback if it's null.
   final scriptUrl = dotenv.env['MODEL_VIEWER_SCRIPT_URL'];
    // ?? fallbackUrl;

  // Create script element and set attributes
  final script = document.createElement('script');
  script.type = 'module';
  script.src = scriptUrl??'';
  // Append to document body
  document.body.appendChild(script);
}
void main() async {
  // Load environment variables from the .env file
  await dotenv.load(fileName: ".env");
  // This is needed to use the isolate feature of model_viewer_plus
   WidgetsFlutterBinding.ensureInitialized();
 injectModelViewerScript();

  // Register the factory for embedding model-viewer in Flutter Web widget tree
  // ui.platformViewRegistry.registerViewFactory('model-viewer-html', (int viewId) {
  //   final modelViewer = document.createElement('model-viewer');
  //    modelViewer.setAttribute('id', 'model-viewer-1'); 
  //   modelViewer.setAttribute('src', 'https://res.cloudinary.com/dqkhcdxag/raw/upload/v1755067549/models/05f1a30704bb8cc120b13e7c469aafd2_llxsqj');
  //   modelViewer.setAttribute('alt', 'A 3D model');
  //   modelViewer.setAttribute('ar', '');
  //   modelViewer.setAttribute('camera-controls', '');
  //   modelViewer.setAttribute('auto-rotate', '');
  //   modelViewer.setAttribute('style', 'width: 100%; height: 100%; background-color: rgba(0, 0, 0, 0);');
  //   return modelViewer;
  // });
  //  ui.platformViewRegistry.registerViewFactory(
  //   'model-viewer-html',
  //   (int viewId) {
  //     final element = html.IFrameElement()
  //       ..width = '100%'
  //       ..height = '100%'
  //       ..style.border = 'none'
  //       ..srcdoc = '''
  //         <!DOCTYPE html>
  //         <html lang="en">
  //         <head>
  //           <script type="module" src="https://unpkg.com/@google/model-viewer/dist/model-viewer.min.js"></script>
  //           <style>
  //             html, body {
  //               margin: 0;
  //               height: 100%;
  //               background: transparent;
  //               overflow: hidden;
  //             }
  //             model-viewer {
  //               width: 100%;
  //               height: 100%;
  //               background-color: rgba(0, 0, 0, 0);
  //             }
  //           </style>
  //         </head>
  //         <body>
  //           <model-viewer 
  //             src="https://res.cloudinary.com/dqkhcdxag/raw/upload/v1755067549/models/05f1a30704bb8cc120b13e7c469aafd2_llxsqj" 
  //             alt="A 3D model"
  //             ar 
  //             auto-rotate 
  //             camera-controls>
  //           </model-viewer>
  //         </body>
  //         </html>
  //       ''';

  //     return element;
  //   },
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  //  void updateModelSrc(String newUrl) {
  //   final modelViewer = document.getElementById('model-viewer-1');
  //   if (modelViewer != null) {
  //     modelViewer.setAttribute('src', newUrl);
  //   }
  // }
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home:
      //  Scaffold(
      //   backgroundColor: Colors.black,
      //   body: Center(
      //     child: SizedBox(
      //       width: 600,
      //       height: 600,
      //       child: const HtmlElementView(viewType: 'model-viewer-html'),
      //     ),
      //   ),
      // ),
       SplashScreen(),
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
