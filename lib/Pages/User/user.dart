// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediapro/Pages/User/about.dart';
import 'package:mediapro/Pages/User/probleme.dart';
import 'package:mediapro/Pages/User/profile.dart';
import 'package:mediapro/Pages/User/team.dart';

class User extends StatefulWidget {
  const User({super.key});

  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  String _selectedLanguage = 'Français';
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          // Sélecteur de langue

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              DropdownButton<String>(
                value: _selectedLanguage,
                icon: const Icon(Icons.language),
                items: <String>['Français', 'عربى'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLanguage = newValue!;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20), // Image de profil
          Center(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFB993D6), Color(0xFF8CA6DB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                'MediaPro',
                style: GoogleFonts.lobster(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/images/animateur.jpg'),
          ),
          SizedBox(height: 20),
          Center(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFB993D6), Color(0xFF8CA6DB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                'Amrani heitem',
                style: GoogleFonts.aBeeZee(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Center(
            child: Column(
              children: [
                menu_user(Icons.person, 'Profile', () {
                  // Action pour le profil
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => Profile(),
                    ),
                  );
                }),
                const SizedBox(height: 20), // Espace entre les options
                menu_user(Icons.group, 'Star event team', () {
                  // Action pour l'équipe star
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => Team(),
                    ),
                  );
                }),
                const SizedBox(height: 20), // Espace entre les options
                menu_user(Icons.report_problem, 'Signaler un problème', () {
                  // Action pour signaler un problème
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => Probleme(),
                    ),
                  );
                }),
                const SizedBox(height: 20), // Espace entre les options
                menu_user(Icons.info, 'À propos', () {
                  // Action pour à propos
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => About(),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.logout),
            label: const Text('Déconnecter'),
            style: ElevatedButton.styleFrom(
              iconColor: Colors.white, // Couleur de l'icône
              backgroundColor: Colors.redAccent, // Couleur de fond du bouton
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10), // Padding du bouton
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

Widget menu_user(IconData icon, String title, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white, // Couleur de fond pour l'option de menu
        borderRadius: BorderRadius.circular(10.0), // Border radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: 20, horizontal: 16), // Ajouter un padding horizontal
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Espace entre les éléments
          children: [
            Row(
              children: [
                const SizedBox(width: 10),
                Icon(icon, size: 30, color: Colors.blue),
                const SizedBox(width: 20),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            Icon(Icons.chevron_right,
                size: 30, color: Colors.blue), // Icône à droite
          ],
        ),
      ),
    ),
  );
}
