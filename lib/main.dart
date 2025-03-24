import 'package:flutter/material.dart';
import 'package:schedule_generator_with_gemini/screens/home/home_screen.dart';
import 'package:device_preview/device_preview.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    DevicePreview(
      enabled: true,
      builder:(context) => const MainApp(),
      )
    );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      home: HomeScreen()
    );
  }
}
