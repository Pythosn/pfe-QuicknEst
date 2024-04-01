import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FavoriteCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isFavorite;
  final int index;
  final Function(Map<String, dynamic> data, bool isFavorite, int index) addToFavorites;
  final TextEditingController commentController; 
  final String userId; // Declare userId field

  const FavoriteCard({Key? key, required this.data, required this.isFavorite, required this.index, required this.addToFavorites, required this.commentController, required this.userId}) : super(key: key);

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (BuildContext ctx) {
                            return FractionallySizedBox(
                              heightFactor: 0.9,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Card(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (data['imageUrls'] != null && data['imageUrls'].isNotEmpty)
                                        SizedBox(
                                          height: 230,
                                          child: PageView.builder(
                                            itemCount: data['imageUrls'].length,
                                            itemBuilder: (context, index) {
                                              return Image.network(
                                                data['imageUrls'][index],
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          ),
                                        ),
                                      Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'House Details',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              'Price: \$${data['price']}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              'Floor: ${data['floor']}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              'Number of Rooms: ${data['numberOfRooms']}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              'Technology: ${data['technology']}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            const Text(
                                              'Comments:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            StreamBuilder(
                                              stream: FirebaseFirestore.instance.collection('comments').doc(data['id']).collection('comments').snapshots(),
                                              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                                if (snapshot.connectionState == ConnectionState.waiting) {
                                                  return CircularProgressIndicator();
                                                }
                                                if (snapshot.hasError) {
                                                  return Text('Error: ${snapshot.error}');
                                                }
                                                return ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount: snapshot.data!.docs.length,
                                                  itemBuilder: (BuildContext context, int index) {
                                                    var commentData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                                                    return ListTile(
                                                      title: Text(commentData['comment']),
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                            SizedBox(height: 10),
                                            TextField(
                                              decoration: InputDecoration(
                                                hintText: 'Add your comment here',
                                                suffixIcon: IconButton(
                                                  onPressed: () {
                                                    // Add comment to Firestore
                                                    FirebaseFirestore.instance.collection('comments').doc(data['id']).collection('comments').add({
                                                      'comment': commentController.text,
                                                    });
                                                    // Clear text field after comment added
                                                    commentController.clear();
                                                  },
                                                  icon: Icon(Icons.send),
                                                ),
                                              ),
                                              controller: commentController,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Container(
                                        height: 300,
                                        child: GoogleMap(
                                          initialCameraPosition: CameraPosition(
                                            target: LatLng(data['latitude'], data['longitude']),
                                            zoom: 15,
                                          ),
                                          markers: {
                                            Marker(
                                              markerId: MarkerId('house_marker'),
                                              position: LatLng(data['latitude'], data['longitude']),
                                              infoWindow: InfoWindow(title: 'House Location'),
                                            ),
                                          },
                                          onMapCreated: (GoogleMapController controller) {
                                            // Additional functionalities can be added here if needed
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.black, // foreground color
                      ),
                      child: const Text('View House'),
                    ),
                    IconButton(
                      onPressed: () {
                        addToFavorites(data, isFavorite, index); 
                      },
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
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