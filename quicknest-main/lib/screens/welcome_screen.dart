import 'package:flutter/material.dart';
//import 'package:myfirstprojct/screens/first_page.dart';
import 'package:myfirstprojct/screens/signin_screen.dart';
//import 'package:p/custom_scaffold.dart.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiknest',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Background Image
          Image.asset(
            'assets/Images/1d6748a0-9692-4b62-aeea-5eb5bb3adc86.jpg',
            fit: BoxFit.cover,
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
              
                Image.asset(
                  'assets/Images/QuickNESTapp-fococlipping-standard.png',
                  width: 120, 
                ),
                const SizedBox(width: 20), 
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  
                    const Text(
                      'Q u i k n E s t',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 17, 17, 17), 
                      ),
                    ),
                    const SizedBox(height: 5),
                   ElevatedButton(
                      onPressed: () {
                      
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignInScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF73BBD9), 
                        padding: const EdgeInsets.symmetric(horizontal: 50), 
                      ),
                      child: const Text(
                        "Let's start", 
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black), 
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        ),
        );
        }
}
