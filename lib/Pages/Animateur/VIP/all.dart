import 'package:flutter/material.dart';
import 'package:mediapro/Pages/Animateur/VIP/card.dart';
import 'package:mediapro/Pages/Animateur/VIP/détaille.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<Map<String, dynamic>>> fetchAnimateurs() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final response = await http.get(Uri.parse(
        'https://back-end-of-mediapro-1.onrender.com/animateurvip/getAll'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map<Map<String, dynamic>>((item) {
        final storedLikes = prefs.getInt('animator_${item['_id']}_likes');

        return {
          '_id': item['_id']?.toString() ?? '',
          'nom': item['nom']?.toString() ?? '',
          'prenom': item['prenom']?.toString() ?? '',
          'name': '${item['prenom'] ?? ''} ${item['nom'] ?? ''}'.trim(),
          'email': item['email']?.toString() ?? '',
          'numero': item['numero']?.toString() ?? '',
          'sex': item['sex']?.toString() ?? 'Non spécifié',
          'niveau': item['niveau']?.toString() ?? '',
          'wilaya': item['wilaya']?.toString() ?? 'Inconnue',
          'adresse': item['adresse']?.toString() ?? '',
          'numero_carte': item['numero_carte']?.toString() ?? '',
          'available': item['available'] ?? false,
          'photo_profil': item['photo_profil'] != null
              ? 'https://back-end-of-mediapro-1.onrender.com/uploads/animateurVip/${item['photo_profil']}'
              : 'assets/images/animateur.jpg',
          'video_presentatif': item['video_presentatif']?.toString() ?? '',
          'ratings_count': (item['ratings'] as List?)?.length ?? 0,
          'ratings': item['ratings'] ?? [],
          'averageRating': (item['averageRating'] as num?)?.toDouble() ?? 0.0,
          'event_count': (item['event'] as num?)?.toInt() ?? 0,
          'likes': storedLikes ?? (item['nbrLike'] as num?)?.toInt() ?? 0,
          'category': item['type']?.toString() ?? 'Toutes',
          '__v': (item['__v'] as num?)?.toInt() ?? 0,
        };
      }).toList();
    }
    throw Exception('HTTP Status ${response.statusCode}');
  } catch (e) {
    print('Error fetchAnimateurs: $e');
    return [];
  }
}

class AnimateurVip extends StatefulWidget {
  const AnimateurVip({super.key});

  @override
  State<AnimateurVip> createState() => _AnimateurState();
}

class _AnimateurState extends State<AnimateurVip> {
  List<Map<String, dynamic>> animateurs = [];

  Future<void> initializeData() async {
    try {
      final results = await fetchAnimateurs();
      setState(() {
        animateurs = results;
      });
    } catch (e) {
      print("Initialization error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur de chargement des données')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 150.0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 212, 175, 55).withOpacity(0.6),
                const Color.fromARGB(255, 250, 250, 94).withOpacity(0.6),
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
                const EdgeInsets.symmetric(horizontal: 0.0, vertical: 50.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 20),
                    const Text(
                      'Animateur VIP',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Bouton de retour pour la zone cliquable
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: animateurs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : AnimateurList(animateurs),
    );
  }
}

class AnimateurList extends StatelessWidget {
  final List<Map<String, dynamic>> animateurs;

  const AnimateurList(this.animateurs, {super.key});

  void navigateToDetail(BuildContext context, Map<String, dynamic> animateur) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnimateurDetaille(animateur: animateur),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: animateurs.length,
      itemBuilder: (context, index) {
        final animateur = animateurs[index];
        return Column(
          children: [
            GestureDetector(
              onTap: () => navigateToDetail(context, animateur),
              child: Center(
                child: SizedBox(
                  width: 320,
                  child: AnimateurCardVip(
                    name: animateur['name'] ?? 'Nom inconnu',
                    photoUrl: animateur['photo_profil'] ??
                        'assets/images/animateur.jpg',
                    rating: animateur['averageRating'] as double? ?? 0.0,
                    location: animateur['wilaya'] ?? 'Inconnue',
                    events: animateur['event_count'] as int? ?? 0,
                    likes: animateur['likes'] as int? ?? 0,
                    id: animateur['id'] ?? '',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}
