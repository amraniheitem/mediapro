import 'package:flutter/material.dart';
import 'package:mediapro/Pages/Animateur/VIP/détaille.dart';

class UserProfile extends StatelessWidget {
  final String id;
  final String name;
  final String photoUrl;
  final String location;
  final int rating;
  final int likes; // Note sur 5
  final int events; // Note sur 5
  final int numero; // Note sur 5

  const UserProfile({
    Key? key,
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.location,
    required this.rating,
    required this.likes,
    required this.events,
    required this.numero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250, // Largeur fixe pour chaque profil
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          CircleAvatar(
            backgroundImage: photoUrl.startsWith('http')
                ? NetworkImage(photoUrl)
                : AssetImage(photoUrl) as ImageProvider,
            radius: 30,
            backgroundColor: Colors.transparent,
          ),
          SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            location,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4),
          _buildRatingStars(rating),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnimateurDetaille(
                    animateur: {
                      '_id': id,
                      'nom':
                          name, // Tu peux parser name en nom/prénom si nécessaire
                      'photo_profil': photoUrl,
                      'wilaya': location,
                      'averageRating': rating,
                      'nbrLike': likes,
                      'event': events,
                      'numero': numero,
                    },
                  ),
                ),
              );
            },
            child: Text('Voir le profil'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.yellow[700],
          size: 20,
        );
      }),
    );
  }
}
