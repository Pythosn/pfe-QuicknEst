import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myfirstprojct/screens/parameter_screen.dart';
import 'package:myfirstprojct/screens/publication_screen.dart';
import 'package:myfirstprojct/screens/signin_screen.dart'; // Import the login page

class ProfileScreen extends StatelessWidget {
  final String userId;

  const ProfileScreen({Key? key, required this.userId}) : super(key: key);

  Future<DocumentSnapshot<Map<String, dynamic>>> _getUserData() async {
    if (userId.isNotEmpty) { // Add a null or empty check for userId
      DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      return userData;
    } else {
      throw Exception("userId is empty or null");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFFA4DAEC),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('quicknest-main/assets/Images/Pastel blue homescreen.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/profile_image.png'),
              ),
              const SizedBox(height: 10),
              FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: _getUserData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    // Retrieve the user's first name and last name from snapshot.data
                    String firstName = snapshot.data!.get('first_name');
                    String lastName = snapshot.data!.get('last_name');
                    String username = snapshot.data!.get('user_name');
                    return Column(
                      children: [
                        Text(
                          '$firstName $lastName',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '$username',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 30),
              _buildMenuOption('Mes Publications', Icons.article, context: context),
              const SizedBox(height: 20),
              _buildMenuOption('Paramètres du compte', Icons.settings, context: context),
              const SizedBox(height: 20),
              _buildMenuOption('Politique de confidentialité', Icons.privacy_tip, context: context),
              const SizedBox(height: 20),
              _buildMenuOption('Déconnexion', Icons.logout, isLogout: true, context: context),
              const SizedBox(height: 400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuOption(String title, IconData icon, {bool isLogout = false, required BuildContext context}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        leading: Icon(
          icon,
          color: const Color.fromARGB(255, 0, 0, 0),
        ),
        onTap: () {
          if (isLogout) {
            _showLogoutDialog(context);
          } else {
            if (title == 'Mes Publications') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserPublicationsPage(userId: userId)), // Pass userId to UserPublicationsPage
              );
            } else {
              _showSettingsBottomSheet(context);
            }
          }
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Déconnexion"),
          content: const Text("Êtes-vous sûr de vouloir vous déconnecter ?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Non"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                );
              },
              child: const Text("Oui"),
            ),
          ],
        );
      },
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.only(top: 100.0),
          child: parametre(), // Use your Parameter widget
        );
      },
    );
  }
}
