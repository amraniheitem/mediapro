import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mediapro/Bottom/Component/video.dart';
import 'package:mediapro/Login/login.dart';
import 'package:mediapro/Pages/Animateur/VIP/contactez.dart';
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
  bool _isLoading = false;
  String? _errorMessage;
  String? _photoUrl;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _initSharedPrefs().then((_) {
      _loadUserData().then((_) {
        _initializeData();
        if (_userId != null) {
          _loadSavedRating();
          _loadSavedLike();
        }
        _loadPhotoProfil();
      });
    });
  }

  Future<void> _initSharedPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _loadPhotoProfil() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://back-end-of-mediapro-1.onrender.com/animateurvip/getOne/${widget.animateur['_id']}'),
        headers: {
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['photo_profil'] != null) {
          setState(() {
            _photoUrl =
                'https://back-end-of-mediapro-1.onrender.com/uploads/animateurVip/${data['photo_profil']}';
          });
        }
      } else {
        print('Failed to load photo: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading photo: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _initializeData() {
    final animateur = widget.animateur;

    setState(() {
      _likes = animateur['nbrLike'] ?? 0;
      _averageRating = _parseRating(animateur['averageRating']);
      _totalRatings = (animateur['ratings'] as List<dynamic>?)?.length ?? 0;
    });
  }

  double _parseRating(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Future<void> _saveRating(int rating) async {
    if (_userId == null || _token == null) {
      _showLoginPrompt();
      return;
    }

    final url = Uri.parse(
      'https://back-end-of-mediapro-1.onrender.com/animateurvip/${widget.animateur['_id']}/rate',
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
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);

        if (responseBody['success'] == true) {
          await _prefs!.setInt(
              'user_${_userId}_rating_${widget.animateur['_id']}', rating);

          setState(() {
            _rating = rating;
            _hasRated = true;
            _averageRating = _parseRating(responseBody['averageRating']);
            _totalRatings = responseBody['totalRatings'] ?? _totalRatings;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
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
      _handleServerError('Erreur technique: ${e.runtimeType}');
    }
  }

  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connexion requise'),
        content:
            const Text('Veuillez vous connecter pour effectuer cette action'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
            },
            child: const Text('Se connecter'),
          ),
        ],
      ),
    );
  }

  void _handleAuthError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
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
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _loadSavedRating() async {
    final savedRating = _prefs!.getInt(
      'user_${_userId}_rating_${widget.animateur['_id']}',
    );

    if (savedRating != null) {
      setState(() {
        _rating = savedRating;
        _hasRated = true;
      });
    }
  }

  Future<void> _loadUserData() async {
    setState(() {
      _userId = _prefs!.getString('userId');
      _token = _prefs!.getString('jwtToken');
    });
  }

  Future<void> _loadSavedLike() async {
    final hasLiked =
        _prefs!.getBool('user_${_userId}_liked_${widget.animateur['_id']}') ??
            false;

    setState(() {
      _hasLiked = hasLiked;
      _likes = (widget.animateur['nbrLike'] ?? 0) + (hasLiked ? 1 : 0);
    });
  }

  Future<void> _toggleLike() async {
    if (_userId == null) {
      _showLoginPrompt();
      return;
    }

    final newLikeStatus = !_hasLiked;

    setState(() {
      _hasLiked = newLikeStatus;
      _likes = (widget.animateur['nbrLike'] ?? 0) + (newLikeStatus ? 1 : 0);
    });

    await _prefs!.setBool(
        'user_${_userId}_liked_${widget.animateur['_id']}', newLikeStatus);
  }

  @override
  Widget build(BuildContext context) {
    final animateur = widget.animateur;
    final videoUrl = animateur['videoUrl'] ?? 'assets/videos/default.mp4';

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 237, 237, 237).withOpacity(0.6),
                const Color.fromARGB(255, 255, 255, 255).withOpacity(0.6),
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
                            const Color.fromARGB(255, 212, 175, 55)
                                .withOpacity(0.6),
                            const Color.fromARGB(255, 250, 250, 94)
                                .withOpacity(0.6),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 25.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back,
                                      color: Colors.black),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.menu,
                                      color: Colors.black),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                            const SizedBox(height: 10.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Profile",
                                  style: TextStyle(
                                      fontSize: 25, color: Colors.black),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.circle,
                                        color: Colors.green, size: 12.0),
                                    const SizedBox(width: 4.0),
                                    const Text(
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
                  const SizedBox(height: 100.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "ID: ${animateur['_id']}",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          "${animateur['prenom']} ${animateur['nom']}",
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        const Text(
                          "Animateur VIP",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          margin: const EdgeInsets.all(8.0),
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
                                  Icon(
                                    Icons.location_on,
                                    color:
                                        const Color.fromARGB(255, 212, 175, 55)
                                            .withOpacity(0.6),
                                  ),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    "${animateur['wilaya']}",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone,
                                    color:
                                        const Color.fromARGB(255, 212, 175, 55)
                                            .withOpacity(0.6),
                                  ),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    "${animateur['numero']}",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18.0),
                        Container(
                          padding: const EdgeInsets.all(16.0),
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      "${animateur['event']}",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: const Color.fromARGB(
                                                255, 212, 175, 55)
                                            .withOpacity(0.6),
                                      ),
                                    ),
                                    const Text(
                                      "Evenement",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Color.fromARGB(255, 212, 175, 55),
                                      ),
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
                                        color: const Color.fromARGB(
                                                255, 212, 175, 55)
                                            .withOpacity(0.6),
                                      ),
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
                                        color: const Color.fromARGB(
                                                255, 212, 175, 55)
                                            .withOpacity(0.6),
                                      ),
                                    ),
                                    const Text(
                                      "J'aime",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Color.fromARGB(255, 212, 175, 55),
                                      ),
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
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              final token =
                                  prefs.getString('jwtToken'); // Clé corrigée

                              if (token == null) {
                                await prefs.setString(
                                    'pendingAction', 'contact_animator');
                                await prefs.setString('pendingAnimateurId',
                                    widget.animateur['_id'].toString());

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
                                        animateurVIPId:
                                            widget.animateur['_id']),
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
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _toggleLike,
                            icon: Icon(
                              _hasLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: _hasLiked ? Colors.red : null,
                            ),
                            label: Text("J'aime"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 147, 153, 214),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      const Text(
                        "Évaluez l'animateur :",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: !_hasRated
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
                      const SizedBox(height: 10.0),
                      Text(
                        "Moyenne: ${_averageRating.toStringAsFixed(1)}/5 ($_totalRatings votes)",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (_hasRated)
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            "Vous avez donné $_rating étoile(s)",
                            style: const TextStyle(
                                color: Colors.green, fontSize: 16),
                          ),
                        ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VideoPlayerScreen(videoUrl: videoUrl),
                      ),
                    ),
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
                          const Padding(
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
                  child: _photoUrl != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(_photoUrl!),
                          radius: 60,
                          backgroundColor: Colors.transparent,
                        )
                      : const CircleAvatar(
                          child: Icon(Icons.person, size: 60),
                          radius: 60,
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
