// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:mediapro/Bottom/Component/video.dart';
import 'package:mediapro/Pages/Animateur/contactez.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Ajout de la dépendance SharedPreferences

class AnimateurDetaille extends StatefulWidget {
  final Map<String, dynamic> animateur;

  const AnimateurDetaille({super.key, required this.animateur});

  @override
  _AnimateurDetailleState createState() => _AnimateurDetailleState();
}

class _AnimateurDetailleState extends State<AnimateurDetaille> {
  int _rating = 0; // Stocke la note donnée par l'utilisateur
  bool _hasRated = false; // Indique si l'utilisateur a déjà évalué
  late int _likes; // Stocke le nombre de "J'aime"
  bool _hasLiked = false; // Empêche l'utilisateur de liker plusieurs fois

  @override
  void initState() {
    super.initState();
    _likes = widget.animateur['likes']; // Initialise avec la valeur existante
  }

  Future<void> _loadLikeStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasLiked = prefs.getBool('hasLiked_${widget.animateur['id']}') ??
          false; // حالة الإعجاب الافتراضية هي false
    });
  }

  // تحديث حالة الإعجاب وحفظها
  Future<void> _updateLikeStatus() async {
    if (!_hasLiked) {
      setState(() {
        _likes++;
        widget.animateur['likes'] = _likes;
        _hasLiked = true;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasLiked_${widget.animateur['id']}', true);
    }
  }

  @override
  void initStates() {
    super.initState();
    _loadRatingStatus(); // Charger l'état de l'évaluation au démarrage
  }

  // Charger l'état de l'évaluation depuis SharedPreferences
  _loadRatingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasRated = prefs.getBool('hasRated') ?? false;
      _rating = prefs.getInt('rating') ?? 0; // Charger l'évaluation précédente
    });
  }

  // Sauvegarder l'état d'évaluation dans SharedPreferences
  _saveRating() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
        'hasRated', true); // Marquer l'utilisateur comme ayant évalué
    await prefs.setInt('rating', _rating); // Sauvegarder la note donnée
  }

  @override
  Widget build(BuildContext context) {
    var animateur = widget.animateur;

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
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
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
                                          color: Colors.green,
                                          size: 12.0,
                                        ),
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
                                          color: Color.fromARGB(
                                              255, 140, 48, 232)),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push<void>(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext context) =>
                                        const Contactez(),
                                  ),
                                );
                              },
                              icon: Icon(Icons.contact_mail),
                              label: Text(
                                'Contactez',
                                style: TextStyle(fontSize: 18),
                              ),
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
                          ),
                          SizedBox(width: 16.0), // Space between buttons
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _updateLikeStatus,
                              icon: Icon(Icons.favorite),
                              label: Text(
                                "J'aime",
                                style: TextStyle(fontSize: 18),
                              ),
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
                                onTap:
                                    _hasRated // Si déjà évalué, ne rien faire
                                        ? null
                                        : () {
                                            setState(() {
                                              _rating = index + 1;
                                              _hasRated =
                                                  true; // Empêcher de réévaluer
                                            });
                                            _saveRating(); // Sauvegarder la note
                                          },
                                child: Icon(
                                  index < _rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 40.0,
                                ),
                              );
                            }),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            "$_rating étoile(s)",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10.0),
                          if (_hasRated)
                            Text(
                              "Vous avez déjà évalué cet animateur.",
                              style:
                                  TextStyle(color: Colors.green, fontSize: 16),
                            ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoPlayerScreen(
                                videoUrl:
                                    "assets/videos/anes.mp4", // Remplacez par votre chemin vidéo
                              ),
                            ),
                          );
                        },
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
                                  width: double.infinity, // Full width
                                  height: 200, // Fixed height for the image
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
                        backgroundImage:
                            AssetImage("assets/images/animateur.jpg"),
                        radius: 60,
                        backgroundColor: Colors.transparent,
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
