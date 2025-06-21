import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediapro/Pages/User/editprofile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String nom = '';
  String prenom = '';
  String wilaya = '';
  String email = '';
  String numero = '';
  String profession = '';
  String description = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // CORRECTION : Utiliser les mêmes clés qu'avec les accents
    setState(() {
      nom = prefs.getString('nom') ?? 'Non défini';
      prenom = prefs.getString('prénom') ?? 'Non défini'; // Clé avec accent
      wilaya = prefs.getString('wilaya') ?? 'Non défini';
      email = prefs.getString('email') ?? 'Non défini';
      numero = prefs.getString('numéro') ?? 'Non défini'; // Clé avec accent
      profession = prefs.getString('profession') ?? 'Utilisateur simple';
    });

    // Ajoutez ce debug pour vérifier
    print('Données récupérées:');
    print('Prénom: $prenom');
    print('Téléphone: $numero');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFB993D6), Color(0xFF8CA6DB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            'Mon Profil',
            style: GoogleFonts.lobster(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/images/profile.jpg'),
            ),
            SizedBox(height: 20),
            _buildProfileItem('Nom complet', '$prenom $nom'),
            SizedBox(height: 15),
            _buildProfileItem('Email', email),
            SizedBox(height: 15),
            _buildProfileItem('Téléphone', numero),
            SizedBox(height: 15),
            _buildProfileItem('Profession', profession),
            SizedBox(height: 15),
            _buildProfileItem('Wilaya', wilaya),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfile()),
              ),
              child: Text('Modifier le profil'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8CA6DB),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(String title, String value,
      {bool isDescription = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: Colors.black87,
            ),
            maxLines: isDescription ? null : 1,
            overflow: isDescription ? null : TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
