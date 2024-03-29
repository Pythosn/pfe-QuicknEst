import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
        backgroundColor: const Color(0xFFA4DAEC),
      ),
      body: _buildFavoritesList(),
    );
  }

  Widget _buildFavoritesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('favorites').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No favorites yet.'));
        }

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return FavoriteCard(
              data: data,
              onDelete: () {
                _deleteFavorite(document.reference);
              },
            );
          }).toList(),
        );
      },
    );
  }

  void _deleteFavorite(DocumentReference reference) {
    reference.delete();
    setState(() {});
  }
}

class FavoriteCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onDelete;

  const FavoriteCard({Key? key, required this.data, required this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data['imageUrls'] != null && data['imageUrls'].isNotEmpty)
            Image.network(
              data['imageUrls'][0],
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'House',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Implement the code to view the details of the publication
                      },
                      child: const Text('View House'),
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: Icon(Icons.favorite_border), // Utilisation de l'icône de cœur brisé
                      color: Colors.red,
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
