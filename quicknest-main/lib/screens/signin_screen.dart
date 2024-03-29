import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myfirstprojct/screens/forget_password.dart';
import 'package:myfirstprojct/screens/signup_screen.dart';
import 'package:myfirstprojct/screens/home_screen.dart'; // Import the home page

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formSignInKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 120, left: 60),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0),
              ),
            ),
            child: Form(
              key: _formSignInKey,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 25),
                    const Text(
                      'Welcome back!',
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF73BBD9),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Image.asset(
                      'assets/Images/QN.jpg',
                      height: 100,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      height: 45,
                      width: 250,
                      child: TextFormField(
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter Email',
                          hintStyle: TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black12,
                            ),
                            borderRadius: BorderRadius.zero,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      height: 45,
                      width: 250,
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        obscuringCharacter: '*',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter Password',
                          hintStyle: TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black12,
                            ),
                            borderRadius: BorderRadius.zero,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formSignInKey.currentState!.validate()) {
                          CollectionReference collRef =
                              FirebaseFirestore.instance.collection('users');

                          QuerySnapshot querySnapshot = await collRef
                              .where('Email',
                                  isEqualTo: emailController.text)
                              .where('Password',
                                  isEqualTo: passwordController.text)
                              .get();

                          if (querySnapshot.docs.isNotEmpty) {
                            String documentId = querySnapshot.docs[0].id;
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(
                                  documentId: documentId,
                                  userId: documentId
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Invalid email or password. Please try again.'),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF73BBD9),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 90),
                      ),
                      child: const Text(
                        "Log in",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForgotPasswordPage()),
                        );
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Color(0xFF73BBD9),
                        ),
                      ),
                    ),
                    const SizedBox(height: 1),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const SignUpScreen(userId: '')),
                        );
                      },
                      child: const Text(
                        'sign up',
                        style: TextStyle(
                          color: Color(0xFF73BBD9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
