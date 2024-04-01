import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myfirstprojct/screens/home_screen.dart'; // Import the FavoriteCard widget from the home screen

class UserPublicationsPage extends StatelessWidget {
  final String userId;

  const UserPublicationsPage({required this.userId});

  Future<void> _updatePublication(BuildContext context, String publicationId, bool reserved) async {
    try {
      // Check if the 'reserved' field exists in Firestore for this publication
      var publicationRef = FirebaseFirestore.instance.collection('houses').doc(publicationId);
      var publicationDoc = await publicationRef.get();

      if (!publicationDoc.exists || !publicationDoc.data()!.containsKey('reserved')) {
        // If 'reserved' field doesn't exist, add it to Firestore
        await publicationRef.update({
          'reserved': reserved, // Update the 'reserved' field in Firestore
        });
      } else {
        // If 'reserved' field already exists, simply update it
        await publicationRef.update({
          'reserved': reserved, // Update the 'reserved' field in Firestore
        });
      }
    } catch (e) {
      print('Error updating publication: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Publications'),
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
                  // Show a confirmation dialog before updating the publication as reserved
                  bool confirmReserved = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Confirmation"),
                        content: Text("Mark this publication as reserved?"),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false); // Return false if user cancels
                            },
                            child: Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true); // Return true if user confirms
                            },
                            child: Text("Reserve"),
                          ),
                        ],
                      );
                    },
                  );

                  // If the user confirms reservation, update the publication in Firestore
                  if (confirmReserved == true) {
                    await _updatePublication(context, publication.id, true);
                  }
                },
                child: FavoriteCard(
                  data: publication.data() as Map<String, dynamic>,
                  isFavorite: true, // Assuming all user's publications are favorites
                  index: index,
                  addToFavorites: (data, isFavorite, index) {},
                   // Pass a dummy TextEditingController
                ),
              );
            },
          );
        },
     ),
);
}
}
