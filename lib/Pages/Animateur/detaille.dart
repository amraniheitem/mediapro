// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mediapro/Bottom/Component/video.dart';
import 'package:mediapro/Login/login.dart';
import 'package:mediapro/Pages/Animateur/contactez.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnimateurDetaille extends StatefulWidget {
  final Map<String, dynamic> animateur;

  const AnimateurDetaille({super.key, required this.animateur});

  @override
  _AnimateurDetailleState createState() => _AnimateurDetailleState();
}

class _AnimateurDetailleState extends State<AnimateurDetaille> {
  int _rating = 0;
  bool _hasRated = false;
  bool _hasLiked = false;
  String? _userId;
  String? _token;
  int _likes = 0;
  int _totalRatings = 0;
  double _averageRating = 0.0;

  Future<void> _fetchRatings() async {
    final animateurData = widget.animateur;

    setState(() {
      _averageRating =
          (animateurData['averageRating'] as num?)?.toDouble() ?? 0.0;
      print('average Body: ${_averageRating}');

      _totalRatings = (animateurData['ratings'] as List<dynamic>?)?.length ?? 0;
      print('total Body: ${_totalRatings}');
    });
  }

  Future<void> _saveRating(int rating) async {
    if (_userId == null || _token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez vous connecter pour évaluer')),
      );
      return;
    }

    final url = Uri.parse(
      'https://back-end-of-mediapro-1.onrender.com/animateur/${widget.animateur['id']}/rate',
    );

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $_token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'rating': rating}),
          )
          .timeout(Duration(seconds: 10));

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      // Handle both 200 and 201 status codes
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);

        if (responseBody['success'] == true) {
          // Update local storage
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt(
              'user_${_userId}_rating_${widget.animateur['id']}', rating);

          // Parse server response
          dynamic serverAverage = responseBody['averageRating'];
          double parsedAverage = _parseRating(serverAverage);

          setState(() {
            _rating = rating;
            _hasRated = true;
            _averageRating = parsedAverage;
            _totalRatings =
                (responseBody['totalRatings'] as int?) ?? _totalRatings;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Évaluation enregistrée avec succès !'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          _handleServerError(
              responseBody['message'] ?? 'Erreur inconnue du serveur');
        }
      } else if (response.statusCode == 401) {
        _handleAuthError();
      } else {
        _handleServerError('Erreur HTTP ${response.statusCode}');
      }
    } on TimeoutException {
      _handleServerError('Timeout - Vérifiez votre connexion internet');
    } catch (e) {
      print('Erreur complète: $e');
      _handleServerError('Erreur technique: ${e.runtimeType}');
    }
  }

  double _parseRating(dynamic value) {
    try {
      if (value is String) return double.parse(value);
      if (value is num) return value.toDouble();
      return 0.0;
    } catch (e) {
      print('Erreur de parsing: $e');
      return _averageRating; // Garde l'ancienne valeur en cas d'erreur
    }
  }

  void _handleAuthError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Session expirée - Veuillez vous reconnecter'),
        duration: Duration(seconds: 3),
      ),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  void _handleServerError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ Erreur: $message'),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _loadSavedRating() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRating = prefs.getInt(
      'user_${_userId}_rating_${widget.animateur['id']}',
    );

    if (savedRating != null) {
      setState(() {
        _rating = savedRating;
        _hasRated = true;
      });
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
      _token = prefs.getString('jwtToken');
    });

    if (_token == null || _userId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      });
    }
  }

  Future<void> _updateLikeStatus() async {
    if (_userId == null) return;

    final prefs = await SharedPreferences.getInstance();
    final hasLiked =
        prefs.getBool('user_${_userId}_liked_${widget.animateur['id']}') ??
            false;
    final currentLikes =
        prefs.getInt('animator_${widget.animateur['id']}_likes') ?? _likes;

    setState(() {
      _hasLiked = !hasLiked;
      _likes = hasLiked ? _likes - 1 : _likes + 1;
    });

    await prefs.setBool(
        'user_${_userId}_liked_${widget.animateur['id']}', !hasLiked);
    await prefs.setInt('animator_${widget.animateur['id']}_likes', _likes);
  }

  @override
  void initState() {
    super.initState();
    _loadUserData().then((_) {
      _fetchRatings();
      if (_userId != null) {
        _loadSavedRating();
        // Gardez la partie likes si nécessaire
        SharedPreferences.getInstance().then((prefs) {
          setState(() {
            _likes = prefs.getInt('animator_${widget.animateur['id']}_likes') ??
                widget.animateur['nbrLike'];
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = _userId != null;
    final animateur = widget.animateur;

    return Scaffold(
      body: SingleChildScrollView(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.arrow_back,
                                      color: Colors.black),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                IconButton(
                                  icon: Icon(Icons.menu, color: Colors.black),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                            SizedBox(height: 10.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Profile",
                                  style: TextStyle(
                                      fontSize: 25, color: Colors.white),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.circle,
                                        color: Colors.green, size: 12.0),
                                    SizedBox(width: 4.0),
                                    Text(
                                      "Disponible",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
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
                          "ID: ${widget.animateur['id']}",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          "${animateur['name']}",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        Text(
                          "Animateur",
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.location_on,
                                      color: Color.fromARGB(255, 140, 48, 232)),
                                  SizedBox(width: 4.0),
                                  Text(
                                    "${animateur['location']}",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.phone,
                                      color: Color.fromARGB(255, 140, 48, 232)),
                                  SizedBox(width: 4.0),
                                  Text(
                                    "07-75-98-12-35",
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
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      "${animateur['events']}",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(
                                              255, 140, 48, 232)),
                                    ),
                                    Text(
                                      "Evenement",
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
                                      "$_likes",
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: // Pour un animateur
                            ElevatedButton.icon(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            final token =
                                prefs.getString('jwtToken'); // Clé corrigée

                            if (token == null) {
                              await prefs.setString(
                                  'pendingAction', 'contact_animator');
                              await prefs.setString('pendingAnimateurId',
                                  widget.animateur['id'].toString());

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Login()),
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Connectez-vous pour contacter cet animateur"),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Contactez(
                                      animateurId: widget.animateur['id']),
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
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isLoggedIn
                              ? (_hasLiked ? null : _updateLikeStatus)
                              : null,
                          icon: Icon(Icons.favorite),
                          label: Text("J'aime"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _hasLiked
                                ? Colors.grey
                                : Color.fromARGB(255, 147, 153, 214),
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Column(
                    children: [
                      Text(
                        "Évaluez l'animateur :",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: isLoggedIn && !_hasRated
                                ? () => _saveRating(index + 1)
                                : null,
                            child: Icon(
                              index < _rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
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
                            style: TextStyle(color: Colors.green, fontSize: 16),
                          ),
                        ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoPlayerScreen(
                            videoUrl: "assets/videos/anes.mp4"),
                      ),
                    ),
                    child: Container(
                      width: 340,
                      height: 245,
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            spreadRadius: 2,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "La présentation de l'animateur ",
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
                    backgroundImage: AssetImage("assets/images/animateur.jpg"),
                    radius: 60,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
