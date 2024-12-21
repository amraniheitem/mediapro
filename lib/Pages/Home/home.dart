// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:mediapro/Bottom/Component/animateur1.dart';
import 'package:mediapro/Bottom/Component/voice.dart';
import 'package:mediapro/Pages/Animateur/animateur.dart';
import 'package:mediapro/Pages/Home/product.dart';
import 'package:mediapro/pages/home/conseille.dart';
import 'package:mediapro/pages/home/guide.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _New1State();
}

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

class _New1State extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 25),
            Text(
              'Les Offers et les promos :',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 20),
            Column(
              children: [
                SizedBox(
                  height: 180,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/promo');
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image.asset(
                            'assets/images/promo2.jpg',
                            width: 280,
                            height: 173,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/promo');
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image.asset(
                            'assets/images/promo2.jpg',
                            width: 280,
                            height: 173,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Les Animateurs :',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => const Animateur(),
                      ),
                    );
                  },
                  child: Text(
                    'Voir toutes',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 131, 22, 143),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              height: 230,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: animateurs
                    .length, // Nombre d'éléments dans la liste animateurs
                itemBuilder: (context, index) {
                  var animateur = animateurs[
                      index]; // Accès à l'animateur à l'index spécifié
                  return Center(
                    child: SizedBox(
                      width: 200,
                      child: UserProfile(
                        name: animateur['name'],
                        photoUrl: animateur['photoUrl'],
                        rating: animateur['rating'],
                        location: animateur['location'],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Choisissez une langue :',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Français'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Anglais'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Espagnol'),
                ),
              ],
            ),
            SizedBox(height: 20),

            Container(
              height: 350,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Center(
                    child: SizedBox(
                      width: 300,
                      child: VoiceOverProfile(
                        name: 'Anes Mahammedi',
                        photoUrl: 'assets/images/voix.jpg',
                        rating: 5.0,
                        language: 'English',
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Center(
                    child: SizedBox(
                      width: 300,
                      child: VoiceOverProfile(
                        name: 'Mounir Hadjadji',
                        photoUrl: 'assets/images/voix.jpg',
                        rating: 3.4,
                        language: 'English',
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Center(
                    child: SizedBox(
                      width: 300,
                      child: VoiceOverProfile(
                        name: 'Abdelkader Derbale',
                        photoUrl: 'assets/images/voix.jpg',
                        rating: 5.0,
                        language: 'English',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Produits et Conseilles :',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Trois containers en ligne
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Premier Container avec l'icône Produit
                GestureDetector(
                  onTap: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => const HomeProduct(),
                      ),
                    );
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFD4A9FF), Color(0xFF80D1FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart, // Icône Produit
                            color: Colors.white,
                            size: 60,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Produit',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 248, 248, 248),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Deuxième Container avec l'icône Conseil
                GestureDetector(
                  onTap: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => const Conseille(),
                      ),
                    );
                    ;
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFD4A9FF), Color(0xFF80D1FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lightbulb_outline, // Icône Conseil
                            color: Colors.white,
                            size: 60,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Conseille',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 248, 248, 248),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => const Guide(),
                      ),
                    );
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFD4A9FF), Color(0xFF80D1FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.map, // Icône Guide
                            color: Colors.white,
                            size: 60,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Guide',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 248, 248, 248),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
