// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mediapro/Login/login.dart';
import 'package:mediapro/Pages/Home/voix.dart';
import 'package:mediapro/Pages/Voice/contactezv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class VoiceDetailPage extends StatefulWidget {
  final VoixModel voix;
  const VoiceDetailPage({super.key, required this.voix});

  @override
  _voiceoverDetailleState createState() => _voiceoverDetailleState();
}

class _voiceoverDetailleState extends State<VoiceDetailPage> {
  int _rating = 0;
  bool _hasRated = false;
  bool _hasLiked = false;
  String? _userId;
  String? _token;
  int _likes = 0;
  int _totalRatings = 0;
  double _averageRating = 0.0;
  @override
  void initState() {
    super.initState();
    print('\n=== DONNÉES INITIALES ===');
    print('ID Voix: ${widget.voix.id}');
    print('Note existante: $_rating');
    print('Moyenne initiale: ${widget.voix.averageRating}');
    print('Likes initiaux: ${widget.voix.nbrLike}');

    _loadUserData().then((_) {
      print('\n=== UTILISATEUR ===');
      print('User ID: $_userId');
      print('Token: ${_token != null ? "présent" : "absent"}');
      _fetchRatings();
      if (_userId != null) {
        _loadSavedRating();
        _loadSavedLike();
      }
    });
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
      _token = prefs.getString('jwtToken');
      _likes = widget.voix.nbrLike;
      _hasLiked =
          prefs.getBool('user_${_userId}_liked_${widget.voix.id}') ?? false;
    });
  }

  Future<void> _loadSavedLike() async {
    final prefs = await SharedPreferences.getInstance();
    final hasLiked =
        prefs.getBool('user_${_userId}_liked_${widget.voix.id}') ?? false;
    setState(() {
      _hasLiked = hasLiked;
      _likes = widget.voix.nbrLike + (hasLiked ? 1 : 0);
    });
  }

  Future<void> _toggleLike() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez vous connecter pour aimer')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasLiked = !_hasLiked;
      _likes += _hasLiked ? 1 : -1;
    });

    await prefs.setBool('user_${_userId}_liked_${widget.voix.id}', _hasLiked);
  }

  Future<void> _fetchRatings() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://back-end-of-mediapro-1.onrender.com/voix/getOne/${widget.voix.id}'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _averageRating = (data['averageRating'] as num?)?.toDouble() ?? 0.0;
          _totalRatings = (data['ratings'] as List<dynamic>?)?.length ?? 0;
        });
      }
    } catch (e) {
      print('Erreur fetchRatings: $e');
    }
  }

  Future<void> _saveRating(int rating) async {
    print("Tentative d'évaluation avec $rating étoiles...");

    if (_userId == null || _token == null) {
      print("Échec: Utilisateur non connecté");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez vous connecter pour évaluer')),
      );
      return;
    }

    try {
      print("Envoi de la requête à l'API...");
      final response = await http
          .post(
            Uri.parse(
                'https://back-end-of-mediapro-1.onrender.com/voix/${widget.voix.id}/rate'),
            headers: {
              'Authorization': 'Bearer $_token',
              'Content-Type': 'application/json',
            },
            body: json.encode({'rating': rating}),
          )
          .timeout(Duration(seconds: 30));

      print('\n=== RÉPONSE SERVEUR ===');
      print('Status Code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body: ${response.body}\n');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Succès du serveur, traitement de la réponse...");
        final data = json.decode(response.body);
        if (data['averageRating'] == null) {
          await _fetchRatings(); // Forcer un rafraîchissement si donnée manquante
        }
        print('Données reçues:');
        print(
            '- AverageRating: ${data['averageRating']} (type: ${data['averageRating']?.runtimeType})');
        print('- TotalRatings: ${data['totalRatings']}');
        print('- Ratings: ${data['ratings']?.length} éléments');

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_${_userId}_rating_${widget.voix.id}', rating);
        print("Préférences locales mises à jour");

        // Rafraîchissement des données
        print("Rafraîchissement des données...");

        setState(() {
          _hasRated = true;
          _totalRatings += 1;
          _averageRating =
              ((_averageRating * (_totalRatings - 1) + rating) / _totalRatings);
        });
        await _fetchRatings();

        print('\n=== ÉTAT ACTUALISÉ ===');
        print('_rating: $_rating');
        print('_hasRated: $_hasRated');
        print('_averageRating: $_averageRating');
        print('_totalRatings: $_totalRatings');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Évaluation enregistrée avec succès !'),
            duration: Duration(seconds: 2),
          ),
        );
      } else if (response.statusCode == 401) {
        print("Erreur 401: Token invalide");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Session expirée - Veuillez vous reconnecter')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      } else {
        print("Erreur serveur inattendue: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur serveur: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('\n=== ERREUR ===');
      print('Type: ${e.runtimeType}');
      print('Message: ${e.toString()}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Erreur de connexion: ${e.toString()}')),
      );
    }
  }

  Future<void> _loadSavedRating() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRating =
        prefs.getInt('user_${_userId}_rating_${widget.voix.id}');
    if (savedRating != null) {
      setState(() {
        _rating = savedRating;
        _hasRated = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(
            top: 20.0,
            left: 5.0,
            right: 5.0,
            bottom: 1.0,
          ),
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 237, 237, 237).withOpacity(0.6),
                    Color.fromARGB(255, 255, 255, 255).withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
                border: Border.all(
                  width: 1.0,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    children: [
                      AppBar(
                        automaticallyImplyLeading: false,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        flexibleSpace: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFD4A9FF).withOpacity(0.6),
                                Color(0xFF80D1FF).withOpacity(0.6),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.vertical(
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 25.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.arrow_back,
                                          color: Colors.black),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    IconButton(
                                      icon:
                                          Icon(Icons.menu, color: Colors.black),
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.0),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Profile",
                                      style: TextStyle(
                                          fontSize: 25, color: Colors.white),
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          color:
                                              (widget.voix.available ?? false)
                                                  ? Colors.green
                                                  : Colors.red,
                                          size: 12.0,
                                        ),
                                        SizedBox(width: 4.0),
                                        Text(
                                          (widget.voix.available ?? false)
                                              ? "Disponible"
                                              : "Non disponible",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                (widget.voix.available ?? false)
                                                    ? Colors.green
                                                    : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 100.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "${widget.voix.prenom} ${widget.voix.nom}",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Text(
                              "Voix Off",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Container(
                              padding: EdgeInsets.all(16.0),
                              margin: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8.0,
                                    spreadRadius: 2.0,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.location_on,
                                          color: Color.fromARGB(
                                              255, 140, 48, 232)),
                                      SizedBox(width: 4.0),
                                      Text(
                                        widget.voix.wilaya,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.phone,
                                          color: Color.fromARGB(
                                              255, 140, 48, 232)),
                                      SizedBox(width: 4.0),
                                      Text(
                                        widget.voix.numero.toString(),
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 18.0),
                            Container(
                              padding: EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8.0,
                                    spreadRadius: 2.0,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 30.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          (widget.voix.videoFa ?? 0).toString(),
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                  255, 140, 48, 232)),
                                        ),
                                        Text(
                                          "Vidéo",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                  255, 140, 48, 232)),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          "|",
                                          style: TextStyle(
                                              fontSize: 40,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                  255, 140, 48, 232)),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          _likes.toString(),
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                  255, 140, 48, 232)),
                                        ),
                                        Text(
                                          "J'aime",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                  255, 140, 48, 232)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.all(16.0),
                        margin: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8.0,
                              spreadRadius: 2.0,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "À propos de Voix off",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              widget.voix.description ??
                                  'Aucune description disponible',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              final token =
                                  prefs.getString('jwtToken'); // Clé corrigée

                              if (token == null) {
                                // Stocker l'intention de contact voix
                                await prefs.setString(
                                    'pendingAction', 'contact_voice');
                                await prefs.setString(
                                    'pendingVoixId', widget.voix.id);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Login()),
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "Connectez-vous pour contacter cette voix"),
                                  ),
                                );
                              } else {
                                // Utilisateur connecté - procéder directement
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ContactezV(voixId: widget.voix.id),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.contact_mail),
                            label: const Text('Contactez',
                                style: TextStyle(fontSize: 18)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 147, 153, 214),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                          ),
                          SizedBox(width: 16.0),
                          ElevatedButton.icon(
                            onPressed: _userId != null ? _toggleLike : null,
                            icon: Icon(Icons.favorite),
                            label:
                                Text("J'aime", style: TextStyle(fontSize: 18)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(255, 147, 153, 214),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Column(
                        children: [
                          Text(
                            "Évaluez le Voix Off :",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              return GestureDetector(
                                onTap: !_hasRated && _userId != null
                                    ? () => _saveRating(index + 1)
                                    : null,
                                child: Icon(
                                  index < _rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: !_hasRated && _userId != null
                                      ? Colors.amber
                                      : Colors.grey[400],
                                  size: 40.0,
                                ),
                              );
                            }),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            "Moyenne: ${_averageRating.toStringAsFixed(1)}/5 ($_totalRatings votes)",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          if (_hasRated)
                            Padding(
                              padding: EdgeInsets.only(top: 10.0),
                              child: Text(
                                "Vous avez donné $_rating étoile(s)",
                                style: TextStyle(
                                    color: Colors.green, fontSize: 16),
                              ),
                            ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 340,
                          height: 245,
                          margin: const EdgeInsets.symmetric(vertical: 10.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                spreadRadius: 2,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Ecoutez un extrait du Voix Off ",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Image.asset(
                                  "assets/images/present.jpg",
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                    ],
                  ),
                  Positioned(
                    top: 80,
                    left: MediaQuery.of(context).size.width / 2 - 85,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 4.0,
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                            'https://back-end-of-mediapro-1.onrender.com/uploads/voix/${widget.voix.photoProfil}'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
