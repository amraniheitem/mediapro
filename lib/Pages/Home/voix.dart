import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mediapro/Bottom/Component/voice.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  late Future<List<VoixModel>> futureVoix;
  String? selectedLanguage;

  @override
  void initState() {
    super.initState();
    futureVoix = fetchVoix();
  }

  Future<List<VoixModel>> fetchVoix() async {
    final response = await http.get(
        Uri.parse('https://back-end-of-mediapro-1.onrender.com/voix/getAll'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<VoixModel> voices = (data['data'] as List)
          .map((json) => VoixModel.fromJson(json))
          .toList();

      // Simulation des langues pour chaque voix (à retirer quand l'API fournira les langues)
      final List<String> languages = ['Français', 'Anglais', 'Arabe'];
      for (int i = 0; i < voices.length; i++) {
        voices[i] = voices[i].copyWith(langue: languages[i % 3]);
      }

      return voices;
    } else {
      throw Exception('Échec du chargement des données');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choisissez une langue :',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildLanguageButton('Français')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildLanguageButton('Anglais')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildLanguageButton('Arabe')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildToutesButton()),
                  ],
                ),
                const SizedBox(height: 20),
                _buildLanguageDisplay(),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 350,
              child: FutureBuilder<List<VoixModel>>(
                future: futureVoix,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final filteredVoices = selectedLanguage == null
                        ? snapshot.data!
                        : snapshot.data!
                            .where((voix) =>
                                voix.langue != null &&
                                voix.langue == selectedLanguage)
                            .toList();

                    return ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final voix in filteredVoices)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Center(
                              child: SizedBox(
                                width: 300,
                                child: VoiceOverProfile(voix: voix),
                              ),
                            ),
                          ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('${snapshot.error}'));
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageButton(String language) {
    return ElevatedButton(
      onPressed: () => setState(() => selectedLanguage = language),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            selectedLanguage == language ? Colors.blue : Colors.white,
        minimumSize: const Size(double.infinity, 48),
      ),
      child: Text(language),
    );
  }

  Widget _buildToutesButton() {
    return ElevatedButton(
      onPressed: () => setState(() => selectedLanguage = null),
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedLanguage == null ? Colors.blue : Colors.white,
        minimumSize: const Size(double.infinity, 48),
      ),
      child: const Text('Toutes'),
    );
  }

  Widget _buildLanguageDisplay() {
    return Center(
      child: Text(
        selectedLanguage == null
            ? 'Français ou Anglais ou Arabe'
            : selectedLanguage!,
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}

class VoixModel {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final int numero;
  final String sex;
  final String? niveau;
  final String wilaya;
  final String? adresse;
  final int? numeroCarte;
  final String? langue;
  final bool? available;
  final String photoProfil;
  final String? videoPresentatif;
  final int? videoFa;
  final int nbrLike;
  final double averageRating;
  final int? ranking;
  final String? description;
  final List<dynamic> ratings;

  VoixModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.numero,
    required this.sex,
    this.niveau,
    required this.wilaya,
    this.adresse,
    this.numeroCarte,
    this.langue,
    this.available,
    required this.photoProfil,
    this.videoPresentatif,
    this.videoFa,
    this.description,
    required this.nbrLike,
    required this.averageRating,
    this.ranking,
    required this.ratings,
  });

  factory VoixModel.fromJson(Map<String, dynamic> json) {
    return VoixModel(
      id: json['_id'] ?? '',
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      email: json['email'] ?? '',
      numero: json['numero'] ?? 0,
      sex: json['sex'] ?? '',
      niveau: json['niveau'],
      wilaya: json['wilaya'] ?? '',
      adresse: json['adresse'],
      numeroCarte: json['numero_carte'],
      langue: json['langue'],
      available: json['available'],
      photoProfil: json['photo_profil'] ?? '',
      videoPresentatif: json['video_presentatif'],
      videoFa: json['video_fa'],
      description: json['description'],
      nbrLike: json['nbrLike'] ?? 0,
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      ranking: json['ranking'],
      ratings: json['ratings'] ?? [],
    );
  }

  VoixModel copyWith({
    String? langue,
  }) {
    return VoixModel(
      id: id,
      nom: nom,
      prenom: prenom,
      email: email,
      numero: numero,
      sex: sex,
      niveau: niveau,
      wilaya: wilaya,
      adresse: adresse,
      numeroCarte: numeroCarte,
      langue: langue ?? this.langue,
      available: available,
      photoProfil: photoProfil,
      videoPresentatif: videoPresentatif,
      videoFa: videoFa,
      description: description,
      nbrLike: nbrLike,
      averageRating: averageRating,
      ranking: ranking,
      ratings: ratings,
    );
  }
}
