import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:myfirstprojct/screens/AddHouse_screen.dart';
import 'package:myfirstprojct/screens/Fav_screen.dart';
import 'package:myfirstprojct/screens/Profile_screen.dart';

class HomePage extends StatefulWidget {
//Variables membres: 
  final String documentId;
  final String userId;

  const HomePage({Key? key, required this.documentId, required this.userId}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _favoriteItems = [];
  late Stream<QuerySnapshot> _currentStream;//flux de données :Firestore 
  late TextEditingController _searchController;//Un contrôleur de texte 
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;
  int _minPrice = 0;
  int _maxPrice = 0;
  bool _isSearchExpanded = false;//est un booléen qui indique si la barre de recherche de la page d'accueil est actuellement étendue ou non.
  bool adsFound = false;//Un booléen indiquant si des annonces ont été trouvées dans les résultats de recherche.

  TextEditingController _priceController = TextEditingController();
  String _searchValue = '';
  TextEditingController _commentController = TextEditingController(); // Declare _commentController here

  @override
  void initState() {
    super.initState();//pratique courante dans Flutter pour garantir que l'état du widget est correctement initialisé.
    _currentStream = FirebaseFirestore.instance.collection('houses').snapshots();//permettra de récupérer en temps réel les mises à jour de la base de données Firestore pour cette collection.
    _searchController = TextEditingController();// controleur qui gérer la saisie de texte 
    _minPriceController = TextEditingController();
    _maxPriceController = TextEditingController();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _commentController.dispose(); // Dispose _commentController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(// le widget racine de la page
      body: StreamBuilder(
        stream: _currentStream,//il écoute le flux _currentStream 
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }//animation de chargement

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }//generer error si  il n'ya pas de connexion

//interface d'acceuil
          return Column(//seule colonne verticale
            children: [
              _buildSearchBar(),
              Expanded(
                child: SingleChildScrollView(//scrolling
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,//contrôle l'alignement des éléments enfants
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
                            Row(//child
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
                      ListView.builder(//bar de recherche
                        shrinkWrap: true,//emballer
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
//fin daccueil
        },



      ),
//barre de navigation      
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[//separation des icones
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
        currentIndex: _selectedIndex,//pages
        selectedItemColor: const Color.fromARGB(255, 164, 218, 236),
        unselectedItemColor: const Color.fromARGB(255, 247, 248, 249),
        onTap: _onItemTapped,
      ),

//fin de la barr

    );
  }
Widget _buildSearchBar() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20.0, 50, 20.0, 20.0),
    child: _isSearchExpanded
        ? Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minPriceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    hintText: 'min price',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5), // Espace entre le champ de saisie du prix minimum et le bouton "OK"
              Expanded(
                child: TextField(
                  controller: _maxPriceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    hintText: 'max price',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5), // Espace entre le champ de saisie du prix maximum et le bouton "OK"
              ElevatedButton(
                onPressed: () {
                  _handleSearchByPrice();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Couleur de fond noire
                  foregroundColor: Colors.white, // Texte blanc à l'intérieur
                ),
                child: Text('OK'),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearchExpanded = false;
                  });
                },
                icon: Icon(Icons.close),
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _isSearchExpanded = true;
                    });
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearchExpanded = true;
                  });
                },
                icon: Icon(Icons.search),
              ),
            ],
          ),
  );
}



void _handleSearchByPrice() {
  setState(() {
    String minPriceText = _minPriceController.text.trim();
    String maxPriceText = _maxPriceController.text.trim();

    // Convertir les prix en entiers pour la comparaison
    int minPrice = int.tryParse(minPriceText) ?? 0;
    int maxPrice = int.tryParse(maxPriceText) ?? 0;

    // Utiliser les entiers pour les comparaisons avec Firestore
    _currentStream = FirebaseFirestore.instance
        .collection('houses')
        .where('price', isGreaterThanOrEqualTo: minPrice.toString())
        .where('price', isLessThanOrEqualTo: maxPrice.toString())
        .snapshots();

    _isSearchExpanded = false; // Réinitialiser l'état de la barre de recherche

    // Effacer les valeurs des champs de prix et de recherche
    _minPriceController.clear();
    _maxPriceController.clear();
    _searchController.clear();

    // Afficher un message si aucune annonce n'est trouvée dans la plage de prix spécifiée
    _currentStream.listen((snapshot) {
      adsFound = snapshot.docs.any((doc) {
        var price = int.tryParse(doc['price']) ?? 0;
        return price >= minPrice && price <= maxPrice;
      });

      if (!adsFound) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Aucune annonce avec ce prix n\'a été trouvée.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
});
});
}


  void _handleSearch() {
  setState(() {
    _searchValue = _searchController.text.trim();
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
          builder: (context) => FavoritesPage(userId: widget.userId),
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
    bool isReserved = data['reserved'] ?? false; // Check if the publication is reserved
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
  if (data['imageUrls'] != null && data['imageUrls'].isNotEmpty)
    Stack(
      alignment: Alignment.topRight, // Align items to the top right corner
      children: [
        Image.network(
          data['imageUrls'][0],
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
        ),
        if (isReserved) // Show the "Res" badge if the publication is reserved
          Container(
            margin: const EdgeInsets.only(top: 10, right: 10),
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              color: Colors.red, // Change color to red
              shape: BoxShape.circle, // Make it a circle
            ),
            child: const Text(
              'Res',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white, // Change text color to white
              ),
            ),
          ),
      ],
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
