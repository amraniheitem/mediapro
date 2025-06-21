import 'package:flutter/material.dart';
import 'package:mediapro/Pages/Home/voix.dart';
import 'package:mediapro/Pages/Voice/Voice.dart';

class VoiceOverProfile extends StatelessWidget {
  final VoixModel voix;

  const VoiceOverProfile({
    Key? key,
    required this.voix,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: EdgeInsets.all(12.0),
      margin: EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 320,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(
                    'https://back-end-of-mediapro-1.onrender.com/uploads/voix/${voix.photoProfil}'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                voix.nom.toString(), // Conversion explicite en String
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              Text(
                voix.langue.toString(), // Conversion explicite en String
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          _buildRatingStars(
              voix.averageRating.toDouble()), // Conversion en double
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VoiceDetailPage(voix: voix),
                ),
              );
            },
            child: Text('Ecoutez un extrait'),
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

  Widget _buildRatingStars(double rating) {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return Icon(
            Icons.star,
            color: Colors.orange[600],
            size: 20,
          );
        } else if (index == fullStars && hasHalfStar) {
          return Icon(
            Icons.star_half,
            color: Colors.orange[600],
            size: 20,
          );
        } else {
          return Icon(
            Icons.star_border,
            color: Colors.orange[600],
            size: 20,
          );
        }
      }),
    );
  }
}
