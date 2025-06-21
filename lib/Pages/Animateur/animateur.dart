// ignore_for_file: prefer_const_constructors, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:mediapro/Bottom/Component/card.dart';
import 'package:mediapro/Bottom/bottombar.dart';
import 'package:mediapro/Pages/Animateur/detaille.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<Map<String, dynamic>>> fetchAnimateurs() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final response = await http.get(Uri.parse(
        'https://back-end-of-mediapro-1.onrender.com/animateur/getAll'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map<Map<String, dynamic>>((item) {
        final storedLikes = prefs.getInt('animator_${item['_id']}_likes');

        return {
          'id': item['_id']?.toString() ?? '',
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
          'photo_profil':
              item['photo_profil']?.toString() ?? 'assets/images/animateur.jpg',
          'video_presentatif': item['video_presentatif']?.toString() ?? '',
          'ratings_count': (item['ratings'] as List?)?.length ?? 0,
          'ratings': item['ratings'] ?? [],
          'averageRating': double.parse(
              ((item['averageRating'] as num?)?.toDouble() ?? 0.0)
                  .toStringAsFixed(2) // Format à 2 décimales
              ),
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

Future<List<Map<String, dynamic>>> fetchCategories() async {
  try {
    final response = await http.get(
        Uri.parse('https://back-end-of-mediapro-1.onrender.com/category/list'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map<Map<String, dynamic>>((item) {
        return {
          'id': item['_id']?.toString() ?? '',
          'name': item['name']?.toString() ?? 'Unknown',
        };
      }).toList();
    }
    throw Exception('HTTP Status ${response.statusCode}');
  } catch (e) {
    print('Error fetchCategories: $e');
    return [];
  }
}

class Animateur extends StatefulWidget {
  const Animateur({super.key});

  @override
  State<Animateur> createState() => _AnimateurState();
}

class _AnimateurState extends State<Animateur> {
  List<Map<String, dynamic>> animateurs = [];
  List<Map<String, dynamic>> categories = [];
  String selectedCategory = "Toutes";
  String sortCriteria = "averageRating";
  String searchQuery = '';

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query.toLowerCase().trim();
    });
  }

  void sortAnimateurs() {
    setState(() {
      animateurs.sort((a, b) {
        final aVal = a[sortCriteria] as double? ?? 0.0;
        final bVal = b[sortCriteria] as double? ?? 0.0;
        return bVal.compareTo(aVal);
      });
    });
  }

  List<Map<String, dynamic>> getFilteredAnimateurs() {
    return animateurs.where((anim) {
      // Filtre par catégorie
      final categoryMatch =
          selectedCategory == "Toutes" || anim['category'] == selectedCategory;

      // Filtre par recherche
      final name = anim['nom']?.toString().toLowerCase() ?? '';
      final prenom = anim['prenom']?.toString().toLowerCase() ?? '';
      final searchMatch = searchQuery.isEmpty ||
          name.contains(searchQuery) ||
          prenom.contains(searchQuery);

      return categoryMatch && searchMatch;
    }).toList();
  }

  Future<void> initializeData() async {
    try {
      final results = await Future.wait([
        fetchAnimateurs(),
        fetchCategories(),
      ]);

      setState(() {
        animateurs = results[0];
        categories = [
          {'id': 'all', 'name': 'Toutes'},
          ...results[1].where((c) => c['name'] != null),
        ];
      });
    } catch (e) {
      print("Initialization error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement des données')),
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
    final filteredAnimateurs = getFilteredAnimateurs();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 250.0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFD4A9FF).withOpacity(0.6),
                const Color(0xFF80D1FF).withOpacity(0.6),
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
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 25.0),
            child: Column(
              children: [
                AppBarHeader(),
                SizedBox(height: 10),
                SearchField(
                  onChanged: updateSearchQuery, // Ajouté
                ),
                SizedBox(height: 18),
                CategoryChips(
                  categories: categories,
                  selectedCategory: selectedCategory,
                  onSelected: (category) =>
                      setState(() => selectedCategory = category),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: animateurs.isEmpty
          ? Center(child: CircularProgressIndicator())
          : AnimateurList(animateurs: filteredAnimateurs),
    );
  }
}

class AppBarHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BottomNavbar()),
          ),
        ),
        SortingMenu(),
      ],
    );
  }
}

class SortingMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.sort, color: Colors.black),
      onSelected: (value) {
        final state = context.findAncestorStateOfType<_AnimateurState>();
        state?.sortCriteria = value;
        state?.sortAnimateurs();
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: "averageRating", child: Text("Trier par note")),
        PopupMenuItem(value: "likes", child: Text("Trier par distances")),
      ],
    );
  }
}

class SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const SearchField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Rechercher un animateur...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }
}

class CategoryChips extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final String selectedCategory;
  final Function(String) onSelected;

  const CategoryChips({
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final name = category['name']?.toString() ?? '';
          return Padding(
            padding: EdgeInsets.only(right: 10.0),
            child: ChoiceChip(
              label: Text(name.isNotEmpty ? name : 'Inconnu'),
              selected: selectedCategory == name,
              onSelected: (selected) => onSelected(name),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class AnimateurList extends StatelessWidget {
  final List<Map<String, dynamic>> animateurs;

  const AnimateurList({required this.animateurs});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(10.0),
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
                  child: AnimateurCard(
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
            SizedBox(height: 20),
          ],
        );
      },
    );
  }

  void navigateToDetail(BuildContext context, Map<String, dynamic> animateur) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnimateurDetaille(animateur: animateur),
      ),
    );
  }
}
