// animateur_vip_page.dart
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mediapro/Bottom/Component/animateur1.dart';

class AnimateurVipPage extends StatefulWidget {
  const AnimateurVipPage({super.key});

  @override
  State<AnimateurVipPage> createState() => _AnimateurVipPageState();
}

class _AnimateurVipPageState extends State<AnimateurVipPage> {
  List<dynamic> randomAnimateurs = [];

  @override
  void initState() {
    super.initState();
    fetchAnimateurs();
  }

  Future<void> fetchAnimateurs() async {
    final url = Uri.parse(
        "https://back-end-of-mediapro-1.onrender.com/animateurvip/getAll");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        data.shuffle(Random());
        setState(() {
          randomAnimateurs = data.take(3).toList();
        });
      } else {
        print("Erreur serveur : ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur de connexion : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: randomAnimateurs.length,
        itemBuilder: (context, index) {
          final animateur = randomAnimateurs[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: 200,
              child: UserProfile(
                name: "${animateur['prenom']} ${animateur['nom']}",
                events: animateur['event'] ?? 0,
                photoUrl: animateur['photo_profil'] != null
                    ? "https://back-end-of-mediapro-1.onrender.com/uploads/animateurVip/${animateur['photo_profil']}"
                    : "assets/images/animateur.jpg",
                rating: (animateur['averageRating'] ?? 0).round(),
                location: animateur['wilaya'] ?? '',
                likes: animateur['nbrLike'] ?? 0,
                numero: animateur['numero'] ?? 0,
                id: animateur['_id'],
              ),
            ),
          );
        },
      ),
    );
  }
}
