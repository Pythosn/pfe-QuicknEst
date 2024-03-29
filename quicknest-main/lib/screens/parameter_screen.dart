import 'package:flutter/material.dart';

class parametre extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () {
              // Action à effectuer lors de l'appui sur le bouton 'X'
              Navigator.of(context).pop();
            },
          ),
          title: const Text(
            'Terminé',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.black),
              onPressed: () {
                // Action à effectuer lors de l'appui sur le bouton 'Terminé'
                // Sauvegarde des modifications
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Message d'avertissement
              Container(
                padding: const EdgeInsets.all(12.0),
                color: const Color.fromARGB(255, 164, 218, 236),
                child: const Text(
                  'Les informations ajoutées seront visibles par tous ceux qui consultent le profil.',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
              const SizedBox(height: 20.0),
              // Section photo de profil
              const CircleAvatar(
                radius: 50.0,
                backgroundColor: Colors.grey,
                child: Text(
                  'U', // Initial de l'utilisateur
                  style: TextStyle(fontSize: 40.0),
                ),
              ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () {
                  // Action à effectuer lors de l'appui sur le bouton 'Modifier'
                  // Permet de modifier la photo de profil
                },
                child: const Text('Modifier'),
              ),
              const SizedBox(height: 20.0),
              // Champs textuels
              const TextField(
                decoration: InputDecoration(labelText: 'Nom'),
                // Gérer l'état du champ textuel et la sauvegarde des modifications
              ),
              const TextField(
                decoration: InputDecoration(labelText: 'À propos'),
                // Gérer l'état du champ textuel et la sauvegarde des modifications
              ),
              const TextField(
                decoration: InputDecoration(labelText: 'Site Web'),
                // Gérer l'état du champ textuel et la sauvegarde des modifications
              ),
              const TextField(
                decoration: InputDecoration(labelText: 'Pronoms'),
                // Gérer l'état du champ textuel et la sauvegarde des modifications
              ),
              const TextField(
                decoration: InputDecoration(labelText: 'Nom d\'utilisateur'),
                // Gérer l'état du champ textuel et la sauvegarde des modifications
              ),
            ],
          ),
        ),
      ),
    );
  }
}
