import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediapro/Bottom/bottombar.dart';

class AboutMediaPro extends StatelessWidget {
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
            'À Propos de Media Pro',
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
              backgroundImage: AssetImage('assets/images/logo_mediapro.jpg'),
              backgroundColor: Colors.transparent,
            ),
            SizedBox(height: 20),
            _buildInfoCard(
              'Présentation de Media Pro',
              'Media Pro est une plateforme innovante qui connecte les animateurs et les commentateurs audio avec les organisateurs d\'événements et les institutions médiatiques. Notre mission est de faciliter la recherche d\'opportunités professionnelles dans le domaine de l\'animation et du commentaire audio.',
            ),
            SizedBox(height: 15),
            _buildInfoCard(
              'Fonctionnement de l\'Application',
              '1. Créez votre profil professionnel avec vos compétences et réalisations\n'
                  '2. Recherchez des animateurs ou commentateurs par spécialisation et localisation\n'
                  '3. Réservez des services et gérez les paiements en toute sécurité\n'
                  '4. Évaluez les prestations pour maintenir un environnement professionnel',
            ),
            SizedBox(height: 15),
            _buildInfoCard(
              'Services Proposés',
              '✅ Profils professionnels pour animateurs et commentateurs\n'
                  '✅ Recherche avancée par compétences et localisation\n'
                  '✅ Système de réservation et paiement sécurisé\n'
                  '✅ Évaluations et badges de qualité\n'
                  '✅ Formation et développement des compétences\n'
                  '✅ Boutique d\'équipements professionnels\n'
                  '✅ Conseil par des experts du secteur',
            ),
            SizedBox(height: 15),
            _buildInfoCard(
              'Valeur Ajoutée',
              '🌟 Première plateforme algérienne spécialisée dans l\'animation et le commentaire audio\n'
                  '🌟 Environnement professionnel et sécurisé\n'
                  '🌟 Développement continu des compétences\n'
                  '🌟 Accès à du matériel professionnel à prix compétitifs\n'
                  '🌟 Support technique et conseils d\'experts',
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => BottomNavbar(),
                  ),
                );
              },
              child: Text('Commencer à utiliser Media Pro'),
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

  Widget _buildInfoCard(String title, String content) {
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
