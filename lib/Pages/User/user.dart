// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediapro/Login/login.dart';
import 'package:mediapro/Pages/User/about.dart';
import 'package:mediapro/Pages/User/probleme.dart';
import 'package:mediapro/Pages/User/profile.dart';
import 'package:mediapro/Pages/User/team.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User extends StatefulWidget {
  const User({super.key});

  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  String _selectedLanguage = 'Français';
  bool _isLoggedIn = false; // Nouvel état pour suivre l'authentification

  // Données utilisateur à afficher
  String nom = '';
  String prenom = '';
  String wilaya = '';
  String email = '';
  String numero = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nom = prefs.getString('nom') ?? '';
      prenom = prefs.getString('prénom') ?? '';
      wilaya = prefs.getString('wilaya') ?? '';
      email = prefs.getString('email') ?? '';
      numero = prefs.getString('numéro') ?? '';

      // Mettre à jour l'état d'authentification
      _isLoggedIn = email.isNotEmpty; // Vérifie si l'email existe
    });
  }

  // Méthode pour gérer la déconnexion
  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Supprime toutes les données
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Déconnexion réussie")),
      );
      setState(() {
        _isLoggedIn = false; // Mettre à jour l'état d'authentification
      });
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Login()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e")),
      );
    }
  }

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
          const SizedBox(height: 20),

          // Logo
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

          // Avatar
          const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/images/profile.jpg'),
          ),
          const SizedBox(height: 20),

          // Nom utilisateur
          Center(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFB993D6), Color(0xFF8CA6DB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                '$prenom $nom',
                style: GoogleFonts.aBeeZee(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          const SizedBox(height: 30),

          // Menu utilisateur
          Center(
            child: Column(
              children: [
                menu_user(Icons.person, 'Profile', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Profile()),
                  );
                }),
                const SizedBox(height: 20),
                menu_user(Icons.group, 'Star event team', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Team()),
                  );
                }),
                const SizedBox(height: 20),
                menu_user(Icons.report_problem, 'Signaler un problème', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Probleme()),
                  );
                }),
                const SizedBox(height: 20),
                menu_user(Icons.info, 'À propos', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboutMediaPro()),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // MODIFICATION ICI : Bouton conditionnel
          if (_isLoggedIn)
            // Bouton de déconnexion (rouge) si authentifié
            ElevatedButton.icon(
              onPressed: _logout,
              icon: Icon(Icons.logout),
              label: Text('Déconnecter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                textStyle: TextStyle(fontSize: 16),
                foregroundColor: Colors.white,
              ),
            )
          else
            // Bouton de connexion (bleu) si non authentifié
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
              icon: Icon(Icons.login),
              label: Text('Se connecter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Couleur bleue
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                textStyle: TextStyle(fontSize: 16),
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}

// Widget Menu réutilisable
Widget menu_user(IconData icon, String title, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 30, color: Colors.blue),
                SizedBox(width: 20),
                Text(title,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              ],
            ),
            Icon(Icons.chevron_right, size: 30, color: Colors.blue),
          ],
        ),
      ),
    ),
  );
}
