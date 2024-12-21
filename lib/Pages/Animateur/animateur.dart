import 'package:flutter/material.dart';
import 'package:mediapro/Bottom/Component/card.dart';
import 'package:mediapro/Pages/Animateur/detaille.dart';

class Animateur extends StatefulWidget {
  const Animateur({super.key});

  @override
  State<Animateur> createState() => _AnimateurState();
}

class _AnimateurState extends State<Animateur> {
  // Liste des animateurs
  List<Map<String, dynamic>> animateurs = [
    {
      'name': 'Anes Mahammedi',
      'photoUrl': 'assets/images/animateur.jpg',
      'rating': 5,
      'location': 'Nàama',
      'distance': 150, // Distance fictive
      'events': 150, // Distance fictive
      'likes': 150, // Distance fictive
    },
    {
      'name': 'Mounir Hadjadji',
      'photoUrl': 'assets/images/animateur.jpg',
      'rating': 4,
      'location': 'Oran',
      'distance': 100, // Distance fictive
      'events': 150, // Distance fictive
      'likes': 150, // Distance fictive
    },
    {
      'name': 'Salah Mahammedi',
      'photoUrl': 'assets/images/animateur.jpg',
      'rating': 5,
      'location': 'Alger',
      'distance': 200, // Distance fictive
      'events': 150, // Distance fictive
      'likes': 150, // Distance fictive
    },
  ];

  // Critère de tri par défaut
  String sortCriteria = "ranking";

  // Méthode pour trier les animateurs
  void sortAnimateurs() {
    setState(() {
      if (sortCriteria == "ranking") {
        animateurs.sort((a, b) => b['rating'].compareTo(a['rating']));
      } else if (sortCriteria == "distance") {
        animateurs.sort((a, b) => a['distance'].compareTo(b['distance']));
      }
      // Affichage de la liste triée pour le débogage
      print("Liste des animateurs après tri : $animateurs");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(250.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            height: 250, // Hauteur exacte
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFD4A9FF).withOpacity(0.6),
                  Color(0xFF80D1FF).withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () {
                          Navigator.pop(context); // Retour à la page précédente
                        },
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.sort, color: Colors.black),
                        onSelected: (value) {
                          setState(() {
                            sortCriteria = value;
                            print(
                                "Critère de tri sélectionné : $sortCriteria"); // Affichage pour débogage
                            sortAnimateurs();
                          });
                        },
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem(
                            value: "ranking",
                            child: const Text("Trier par ranking"),
                          ),
                          PopupMenuItem(
                            value: "distance",
                            child: const Text("Trier par distance"),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Rechercher un animateur...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ChoiceChip(
                          label: const Text('Toutes'),
                          selected: false,
                          onSelected: (bool selected) {},
                        ),
                        const SizedBox(width: 10),
                        ChoiceChip(
                          label: const Text('Sport'),
                          selected: true,
                          onSelected: (bool selected) {},
                        ),
                        const SizedBox(width: 10),
                        ChoiceChip(
                          label: const Text('Culture'),
                          selected: false,
                          onSelected: (bool selected) {},
                        ),
                        const SizedBox(width: 10),
                        ChoiceChip(
                          label: const Text('Nothing'),
                          selected: false,
                          onSelected: (bool selected) {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: animateurs.length,
        itemBuilder: (context, index) {
          final animateur = animateurs[index];
          return Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => AnimateurDetaille(
                          animateur: animateur), // Passez les arguments ici
                    ),
                  );
                },
                child: Center(
                  child: SizedBox(
                    width: 320,
                    child: AnimateurCard(
                      name: animateur['name'],
                      photoUrl: animateur['photoUrl'],
                      rating: animateur['rating'],
                      location: animateur['location'],
                      events: animateur['events'],
                      likes: animateur['likes'],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}
