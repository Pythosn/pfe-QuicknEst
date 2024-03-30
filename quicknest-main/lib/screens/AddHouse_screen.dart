import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myfirstprojct/screens/map.dart';

class AddHousePage extends StatefulWidget {
  final String userId;

  const AddHousePage({required this.userId});

  @override
  _AddHousePageState createState() => _AddHousePageState();
}

class _AddHousePageState extends State<AddHousePage> {
  final List<File> _images = [];
  double _latitude = 0.0;
  double _longitude = 0.0;
  String? _selectedTechnology;
  String? _selectedRooms;
  String? _selectedFloor;
  bool _showLocationInfo = false;

  final List<String> _technologyOptions = ['furnished', 'Semi-furnished', 'Unfurnished'];
  final List<String> _roomOptions = ['1', '2', '3', '4', '5'];
  final List<String> _floorOptions = ['1', '2', '3', '4', '5'];

  final TextEditingController _priceController = TextEditingController();

  void _updateLocation(double latitude, double longitude) {
    setState(() {
      _latitude = latitude;
      _longitude = longitude;
      _showLocationInfo = true;
    });
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    List<XFile>? pickedFiles = await picker.pickMultiImage();

    // ignore: unnecessary_null_comparison
    if (pickedFiles != null) {
      setState(() {
        _images.addAll(pickedFiles.map((file) => File(file.path)).toList());
      });
    }
  }

  Future<void> _submitData() async {
    if (_selectedRooms != null &&
        _selectedFloor != null &&
        _selectedTechnology != null &&
        _priceController.text.isNotEmpty &&
        _images.isNotEmpty &&
        _isNumeric(_priceController.text)) { // Validate if price is numeric
      List<String> imageUrls = await _uploadImages(_images);
      int numberOfRooms = int.parse(_selectedRooms!);
      int floor = int.parse(_selectedFloor!);
      String technology = _selectedTechnology!;
      String price = _priceController.text;

      await addHouseToFirestore(
          numberOfRooms, floor, technology, price, imageUrls, _latitude, _longitude, widget.userId);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('House added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

    } else {
      print('Please fill in all fields correctly and add at least one image.');
    }
  }

  // Function to check if a string is numeric
  bool _isNumeric(String value) {
    // ignore: unnecessary_null_comparison
    if (value == null) {
      return false;
    }
    return double.tryParse(value) != null;
  }

  Future<List<String>> _uploadImages(List<File> images) async {
    List<String> imageUrls = [];

    for (File image in images) {
      String imageName = DateTime.now().millisecondsSinceEpoch.toString();
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('images')
          .child('$imageName.jpg');

      try {
        await ref.putFile(image);
        String imageUrl = await ref.getDownloadURL();
        imageUrls.add(imageUrl);
      } catch (e) {
        print('Error uploading image: $e');
      }
    }

    return imageUrls;
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final inputHeight = 64.0; // Adjust this value as needed

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add House'),
        backgroundColor: const Color(0xFFA4DAEC),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == _images.length) {
                    return GestureDetector(
                      onTap: _getImage,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Container(
                          width: 180,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.add,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Container(
                        width: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(8.0),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: FileImage(_images[index]),
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 10.0),

            if (_showLocationInfo)
              Text('Latitude: $_latitude\nLongitude: $_longitude'),
            const SizedBox(height: 10.0),
            DropdownButtonFormField<String>(
              value: _selectedRooms,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRooms = newValue;
                });
              },
              items: _roomOptions
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Number of rooms',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 13.0, horizontal: 16.0),
              ),
            ),
            const SizedBox(height: 10.0),
            DropdownButtonFormField<String>(
              value: _selectedFloor,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFloor = newValue;
                });
              },
              items: _floorOptions
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Floor',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 13.0, horizontal: 16.0),
              ),
            ),
            const SizedBox(height: 10.0),
            DropdownButtonFormField<String>(
              value: _selectedTechnology,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTechnology = newValue;
                });
              },
              items: _technologyOptions
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Furnished',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 13.0, horizontal: 16.0),
              ),
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number, // Set keyboard type to numeric
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 13.0, horizontal: 16.0),
              ),
            ),
            const SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapScreen(
                      onLocationSelected: _updateLocation,
                    ),
                  ),
                );
                // Check if coordinates were received from the "MapScreen" page
                if (result != null &&
                    result.containsKey('latitude') &&
                    result.containsKey('longitude')) {
                  setState(() {
                    _latitude = result['latitude'];
                    _longitude = result['longitude'];
                    _showLocationInfo = true;
                  });
                }
              },
              child: const Text('Map'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.black,
                padding: const EdgeInsets.all(0),
                minimumSize: const Size(double.infinity, 45),
              ),
            ),
            const SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () {
                _submitData();
              },
              child: const Text('Submit'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.black,
                padding: const EdgeInsets.all(0),
                minimumSize: const Size(double.infinity, 45),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addHouseToFirestore(
    int numberOfRooms,
    int floor,
    String technology,
    String price,
    List<String> imageUrls,
    double latitude,
    double longitude,
    String userId,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('houses').add({
        'userId': userId,
        'numberOfRooms': numberOfRooms,
        'floor': floor,
        'technology': technology,
        'price': price,
        'imageUrls': imageUrls,
        'dateAdded': FieldValue.serverTimestamp(),
        'latitude': latitude,
        'longitude': longitude,
      });
      print('House added to Firestore');
    } catch (e) {
      print('Error adding house to Firestore: $e');
    }
  }
}
