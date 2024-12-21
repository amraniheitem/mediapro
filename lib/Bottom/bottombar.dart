// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:mediapro/Pages/Animateur/animateur.dart';
import 'package:mediapro/Pages/Animateur/animateur.dart';
import 'package:mediapro/Pages/Home/home.dart';
import 'package:mediapro/Pages/Home/notification.dart';
import 'package:mediapro/Pages/User/user.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({super.key});

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  int _selectedIndex = 0;

  // List of widgets to display based on the selected index
  final List<Widget> _widgetOptions = [
    Home(),
    Animateur(),
    User(),
  ];

  // Handle bottom navigation bar item tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions[_selectedIndex], // Display the selected page
      appBar: (_selectedIndex == 0)
          ? AppBar(
              title: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    Color(0xFFB993D6),
                    Color(0xFF8CA6DB)
                  ], // Dégradé de titre
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  'Mediapro', // Nom de l'application
                  style: GoogleFonts.lobster(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              actions: [
                // Icône de notifications
                IconButton(
                  icon: const Icon(Icons.notifications),
                  iconSize: 30,
                  onPressed: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => NotificationPage(),
                      ),
                    );
                  },
                ),
                // Avatar utilisateur
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context,
                          '/profile'); // Navigation vers la route '/profile'
                    },
                    child: CircleAvatar(
                      backgroundImage:
                          AssetImage('assets/images/animateur.jpg'),
                      radius: 20, // Taille du cercle
                    ),
                  ),
                ),
              ],
              backgroundColor: Colors.transparent, // Fond transparent
              elevation: 0,
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: 'Animateur',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Utilisateur',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Color.fromARGB(255, 199, 68, 255),
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
