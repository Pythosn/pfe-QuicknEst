import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _emailSent = false;

  Future<void> _sendResetEmail() async {
    final String email = _emailController.text;
    final String apiUrl = 'https://your-backend-server.com/reset-password';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode({'email': email}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _emailSent = true;
        });
      } else {
        // Handle error response from backend
        print('Error: ${response.body}');
      }
    } catch (e) {
      // Handle network or server errors
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Enter your email',
              ),
            ),
            SizedBox(height: 20.0),
            _emailSent
                ? Text(
                    'Reset email sent. Please check your inbox.',
                    style: TextStyle(color: Colors.green),
                  )
                : SizedBox(),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _sendResetEmail,
              child: Text('Send Reset Email'),
            ),
          ],
        ),
      ),
    );
  }
}
