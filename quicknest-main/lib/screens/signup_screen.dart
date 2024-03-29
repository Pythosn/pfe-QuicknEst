
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myfirstprojct/screens/home_screen.dart';
import 'package:myfirstprojct/widgets/custom_scaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key, required String userId});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  DateTime? _selectedDate;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  
  Widget buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required Function(String?) validator,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return SizedBox(
      height: 45,
      child: TextFormField(
        controller: controller,
        validator: (value) => validator(value),
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.black26,
          ),
          suffixIcon: suffixIcon,
          border: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black12,
            ),
            borderRadius: BorderRadius.zero,
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black12,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildTextFormField(
              controller: firstNameController,
              label: 'First Name',
              hint: 'Enter First Name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter first name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            buildTextFormField(
              controller: lastNameController,
              label: 'Last Name',
              hint: 'Enter Last Name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter last name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            buildTextFormField(
              controller: userNameController,
              label: 'User Name',
              hint: 'Enter User Name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter user name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 45,
              child: TextFormField(
                controller: TextEditingController(
                  text: _selectedDate != null
                      ? DateFormat('dd-MM-yyyy').format(_selectedDate!)
                      : '',
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  hintText: 'Select Date of Birth',
                  suffixIcon: Icon(Icons.calendar_today),
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
            const SizedBox(height: 20),
            buildTextFormField(
              controller: phoneNumberController,
              label: 'Phone Number',
              hint: 'Enter Phone Number',
              validator: (value) {
                if (value == null || value.length != 10) {
                  return 'Invalid phone number. Must be 10 digits.';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            buildTextFormField(
              controller: emailController,
              label: 'Email',
              hint: 'Enter Email',
              validator: (value) {
                if (value == null || value.isEmpty || !value.toLowerCase().endsWith('@gmail.com')) {
                  return 'Invalid email format. Must end with @gmail.com.';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            buildTextFormField(
              controller: passwordController,
              label: 'Password',
              hint: 'Enter Password',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter password';
                }
                return null;
              },
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
            
                if (!firstNameController.text.trim().startsWith(RegExp(r'[a-zA-Z]'))) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid first name. Must start with a letter.'),
                    ),
                  );
                  return;
                }

               
                if (!lastNameController.text.trim().startsWith(RegExp(r'[a-zA-Z]'))) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid last name. Must start with a letter.'),
                    ),
                  );
                  return;
                }

        
                if (phoneNumberController.text.trim().length != 10) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid phone number. Must be 10 digits.'),
                    ),
                  );
                  return;
                }


                if (!emailController.text.trim().toLowerCase().endsWith('@gmail.com')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid email format. Must end with @gmail.com.'),
                    ),
                  );
                  return;
                }

           
                CollectionReference collRef = FirebaseFirestore.instance.collection('users');
                await collRef.add({
                  'first_name': firstNameController.text,
                  'last_name': lastNameController.text,
                  'user_name': userNameController.text,
                  'date': _selectedDate != null ? DateFormat('dd-MM-yyyy').format(_selectedDate!) : '',
                  'phone': phoneNumberController.text,
                  'Email': emailController.text,
                  'Password': passwordController.text,
                });


               Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomePage(documentId: '', userId: '',),
                    ),
                  );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF73BBD9),
                padding: const EdgeInsets.symmetric(horizontal: 90),
              ),
              child: const Text(
                "Sign up",
                style: TextStyle(
                  color: Colors.black,


                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
