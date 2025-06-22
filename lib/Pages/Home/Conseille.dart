import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../home/conseille1.dart';

class Conseille extends StatelessWidget {
  const Conseille({super.key});

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Impossible d’ouvrir le lien $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String currentDate = DateFormat('MMM d, y', 'fr_FR').format(now);
    final String currentDayName = DateFormat('E', 'fr_FR').format(now);
    final int currentDayNumber = now.day;

    final List<String> days = [];
    final List<int> dates = [];
    for (int i = 0; i < 7; i++) {
      DateTime day = now.subtract(Duration(days: now.weekday - 1 - i));
      days.add(DateFormat('E', 'fr_FR').format(day));
      dates.add(day.day);
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 20, left: 5, right: 5, bottom: 1),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back),
                                iconSize: 30,
                                onPressed: () => Navigator.pop(context),
                              ),
                              Text(
                                currentDate,
                                style: const TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const Text(
                                "Aujourd’hui",
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () =>
                                  Navigator.pushNamed(context, '/profile'),
                              child: const CircleAvatar(
                                backgroundImage:
                                    AssetImage('assets/images/animateur.jpg'),
                                radius: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Jours
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: days.map((day) {
                          final isCurrentDay = day == currentDayName;
                          return Text(
                            day,
                            style: TextStyle(
                              fontSize: 18.5,
                              fontWeight: isCurrentDay
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isCurrentDay ? Colors.blue : Colors.black,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),

                      // Dates
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: dates.map((date) {
                          final isCurrentDate = date == currentDayNumber;
                          return Text(
                            date.toString(),
                            style: TextStyle(
                              fontSize: 18.5,
                              fontWeight: isCurrentDate
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isCurrentDate ? Colors.blue : Colors.black,
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),

                      // Les Conseils
                      const Conseille1(
                        name:
                            "Soyez authentique et engagez votre public avec enthousiasme et humour",
                      ),
                      const Conseille1(
                        name:
                            "Préparez-vous minutieusement mais restez flexible pour improviser",
                      ),
                      const Conseille1(
                        name:
                            "Soyez attentif aux réactions du public et ajustez votre approche en conséquence.",
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: const [
                          Text(
                            'Des Vidéos :',
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.w900),
                          ),
                          Spacer(),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Vidéos Cliquables
                      SizedBox(
                        height: 120,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            GestureDetector(
                              onTap: () => _launchURL(
                                  "https://www.youtube.com/watch?v=eIho2S0ZahI"),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: Image.asset(
                                  'assets/images/promo1.jpg',
                                  width: 180,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () => _launchURL(
                                  "https://www.youtube.com/watch?v=liQLdRk0Ziw"),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: Image.asset(
                                  'assets/images/promo2.jpg',
                                  width: 180,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () => _launchURL(
                                  "https://www.youtube.com/watch?v=xz0P7UbKGr0"),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: Image.asset(
                                  'assets/images/promo1.jpg',
                                  width: 180,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
