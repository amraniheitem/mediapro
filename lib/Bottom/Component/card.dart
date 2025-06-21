import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnimateurCard extends StatelessWidget {
  final String name;
  final String photoUrl;
  final String location;
  final double rating;
  final int events;
  final int likes;
  final String id;

  const AnimateurCard({
    Key? key,
    required this.name,
    required this.photoUrl,
    required this.location,
    required this.rating,
    required this.events,
    required this.likes,
    required this.id,
  }) : super(key: key);

  Future<int> getActualLikes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('animator_${id}_likes') ?? likes;
    } catch (e) {
      return likes;
    }
  }

  ImageProvider get imageProvider {
    if (photoUrl.startsWith('http')) {
      return NetworkImage(photoUrl);
    } else {
      return AssetImage(photoUrl);
    }
  }

  // Fonction pour formater le rating avec 2 décimales
  String formatRating(double value) {
    return '${value.toStringAsFixed(2)}/5';
  }

  // Fonction pour diviser la wilaya si trop longue
  Widget buildLocationText(String text) {
    const maxChars = 10;
    if (text.length <= maxChars) {
      return Text(
        text,
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
      );
    }

    int splitIndex = text.indexOf(' ', (text.length / 2).round());
    if (splitIndex == -1) splitIndex = maxChars;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text.substring(0, splitIndex).trim(),
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        Text(
          text.substring(splitIndex).trim(),
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
        future: getActualLikes(),
        builder: (context, snapshot) {
          final actualLikes = snapshot.hasData ? snapshot.data! : likes;
          final formattedRating = formatRating(rating);

          return Container(
            width: 282,
            height: 230, // Augmenté pour éviter l'overflow
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/card.PNG'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(25, 20, 15, 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage: AssetImage(photoUrl),
                      radius: 45,
                      backgroundColor: Colors.transparent,
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 5.0,
                                  color: Colors.black.withOpacity(0.5),
                                  offset: Offset(0, 3),
                                )
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 5),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 3),
                                child: Icon(Icons.location_pin,
                                    color: Colors.white, size: 20),
                              ),
                              SizedBox(width: 5),
                              Flexible(
                                child: buildLocationText(location),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Divider(color: Colors.white.withOpacity(0.7)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    _buildStatColumn('$events', 'Événements'),
                    _buildStatColumn('$actualLikes', 'J\'aime'),
                    _buildStatColumn(formattedRating, 'Évaluation',
                        highlight: true),
                  ],
                ),
              ],
            ),
          );
        });
  }

  Widget _buildStatColumn(String value, String label,
      {bool highlight = false}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: highlight ? Color(0xFF9A47DD) : Colors.white,
            shadows: [
              Shadow(
                blurRadius: 3.0,
                color: Colors.black.withOpacity(0.3),
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
        SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color:
                highlight ? Color(0xFF9A47DD) : Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
