import 'package:flutter/material.dart';

class Parametre extends StatefulWidget {
  final String userId;
  final Function(Map<String, dynamic>) onUpdateUserInformation;

  const Parametre({Key? key, required this.userId, required this.onUpdateUserInformation}) : super(key: key);

  @override
  _ParametreState createState() => _ParametreState();
}

class _ParametreState extends State<Parametre> {
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            color: const Color.fromARGB(255, 164, 218, 236),
            child: const Text(
              'The information added will be visible to everyone who views the profile.',
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          const SizedBox(height: 20.0),
          TextField(
            controller: _firstNameController,
            decoration: InputDecoration(labelText: 'First_name'),
          ),
          TextField(
            controller: _lastNameController,
            decoration: InputDecoration(labelText: 'Last_name'),
          ),
          TextField(
            controller: _userNameController,
            decoration: InputDecoration(labelText: 'User_name'),
          ),
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(labelText: 'Phone'),
          ),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Password'),
          ),
          ElevatedButton(
            onPressed: () {
              _updateUserInfo();
            },
            child: const Text('Finished'),
          ),
        ],
      ),
    );
  }

  void _updateUserInfo() {
    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    String userName = _userNameController.text.trim();
    String phone = _phoneController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    Map<String, dynamic> updatedUserInfo = {
      'first_name': firstName,
      'last_name': lastName,
      'user_name': userName,
      'phone': phone,
      'Email': email,
      'Password': password,
    };

    widget.onUpdateUserInformation(updatedUserInfo);
    Navigator.pop(context);
  }
}
