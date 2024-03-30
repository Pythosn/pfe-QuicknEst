import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:myfirstprojct/screens/AddHouse_screen.dart';
import 'package:myfirstprojct/screens/Fav_screen.dart';
import 'package:myfirstprojct/screens/Profile_screen.dart';

class HomePage extends StatefulWidget {
  final String documentId;
  final String userId;

  const HomePage({Key? key, required this.documentId, required this.userId}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _favoriteItems = [];
  late Stream<QuerySnapshot> _currentStream;
  // ignore: unused_field
  late TextEditingController _searchController;
  TextEditingController _priceController = TextEditingController();
  String _searchValue = '';

  @override
  void initState() {
    super.initState();
    _currentStream = FirebaseFirestore.instance.collection('houses').snapshots();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: _currentStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Find Your',
                              style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 1),
                            const Text(
                              'Perfect Home',
                              style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              'Discover the best home for you',
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    _updateStream('dateAdded');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('  recent  '),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _updateStream('popular', 'favorites');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('  popular '),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _updateStream('price', 'houses');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('bestseller'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                          bool isFavorite = _favoriteItems.contains(data);
                          if (_searchValue.isNotEmpty &&
                              data['price'] != null &&
                              data['price'].toString() != _searchValue) {
                            return SizedBox();
                          }
                          return _buildCard(data, isFavorite, index);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 164, 218, 236),
        unselectedItemColor: const Color.fromARGB(255, 247, 248, 249),
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 20.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                hintText: 'Search for houses by price',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              onSubmitted: (value) {
                _handleSearch();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleSearch() {
    setState(() {
      _searchValue = _priceController.text.trim();
    });
  }

  void _searchByPriceOnSubmit(String price) {
    int parsedPrice = int.tryParse(price) ?? 0;

    setState(() {
      _currentStream = FirebaseFirestore.instance
          .collection('houses')
          .where('price', isEqualTo: parsedPrice)
          .snapshots();
    });
  }

  void _updateStream(String orderByField, [String? collectionName]) {
    if (collectionName == null) {
      setState(() {
        _currentStream = FirebaseFirestore.instance.collection('houses').orderBy(orderByField, descending: true).snapshots();
      });
    } else if (collectionName == 'favorites' && orderByField == 'popular') {
      setState(() {
        _currentStream = FirebaseFirestore.instance.collection(collectionName).snapshots();
      });
    } else if (collectionName == 'houses' && orderByField == 'bestseller') {
      setState(() {
        _currentStream = FirebaseFirestore.instance.collection(collectionName).orderBy('price', descending: true).snapshots();
      });
    } else {
      setState(() {
        _currentStream = FirebaseFirestore.instance.collection(collectionName).orderBy(orderByField, descending: false).snapshots();
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddHousePage(userId:widget.userId),
        ),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FavoritesPage(),
        ),
      );
    } else if (index == 3) {
       Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(userId: widget.userId),
        ),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Widget _buildCard(Map<String, dynamic> data, bool isFavorite, int index) {
    return Container(
      margin: const EdgeInsets.all(10),
      width: 350,
      child: FavoriteCard(
        data: data,
        isFavorite: isFavorite,
        index: index,
        addToFavorites: _addToFavorites,
      ),
    );
  }

  void _addToFavorites(Map<String, dynamic> data, bool isFavorite, int index) {
    setState(() {
      if (isFavorite) {
        _favoriteItems.remove(data);
      } else {
        _favoriteItems.add(data);
      }
    });

    if (!isFavorite) {
      FirebaseFirestore.instance.collection('favorites').add(data);
    }
  }
}

class FavoriteCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isFavorite;
  final int index;
  final Function(Map<String, dynamic> data, bool isFavorite, int index) addToFavorites;

  const FavoriteCard({Key? key, required this.data, required this.isFavorite, required this.index, required this.addToFavorites}) : super(key: key);

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
                        addToFavorites(data, isFavorite, index); // Add or remove from favorites
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

void main() {
  runApp(MaterialApp(
    home: HomePage(documentId: 'documentId', userId: 'userId'),
  ));
}
