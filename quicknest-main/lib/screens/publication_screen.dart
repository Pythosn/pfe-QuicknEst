import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myfirstprojct/screens/home_screen.dart'; // Import the FavoriteCard widget from the home screen

class UserPublicationsPage extends StatelessWidget {
  final String userId;

  const UserPublicationsPage({required this.userId});

  Future<void> _deletePublication(BuildContext context, String publicationId) async {
    // Show a confirmation dialog before deleting the publication
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmation"),
          content: Text("Are you sure you want to delete this publication?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false to indicate cancellation
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true to indicate confirmation
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );

    // If the user confirms deletion, delete the publication from Firestore
    if (confirmDelete == true) {
      try {
        await FirebaseFirestore.instance.collection('houses').doc(publicationId).delete();
      } catch (e) {
        print('Error deleting publication: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Publications'),
        backgroundColor: const Color(0xFFA4DAEC),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('houses').where('userId', isEqualTo: userId).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              var publication = snapshot.data!.docs[index];
              return GestureDetector(
                onTap: () async {
                  // Delete the publication when tapped
                  await _deletePublication(context, publication.id);
                },
                child: FavoriteCard(
                  data: publication.data() as Map<String, dynamic>,
                  isFavorite: true, // Assuming all user's publications are favorites
                  index: index,
                  addToFavorites: (data, isFavorite, index) {}, // Placeholder function, not used in this context
                ),
              );
            },
          );
        },
      ),
    );
  }
}
