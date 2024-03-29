import 'package:firebase_core/firebase_core.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myfirstprojct/screens/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyC9BoeAr5A7SI53d_sOLWvTyGIomtrDpKw', 
      appId: '1:511407589225:android:bb5e33f0179ef150ef1ff8', 
      messagingSenderId: '511407589225', 
      projectId: 'prfe-d9086',
      storageBucket: 'prfe-d9086.appspot.com'
      )
    );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QuickNest',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:const WelcomeScreen(),
    );
  }
}
