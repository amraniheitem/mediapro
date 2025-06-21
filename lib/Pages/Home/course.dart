import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import './commande2.dart';
import 'package:mediapro/Login/login.dart';

class Course extends StatefulWidget {
  final String courseId;

  const Course({super.key, required this.courseId});

  @override
  State<Course> createState() => _CourseState();
}

class _CourseState extends State<Course> {
  Map<String, dynamic>? courseDetails;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchCourseDetails();
  }

  Future<void> fetchCourseDetails() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://back-end-of-mediapro-1.onrender.com/course/search/${widget.courseId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            courseDetails = data['data'];
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Failed to load course: ${data['message']}';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage =
              'Failed to load course (Status: ${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(child: Text(errorMessage!)),
      );
    }

    if (courseDetails == null) {
      return Scaffold(
        body: Center(child: Text('Course not found')),
      );
    }

    return Scaffold(
      body: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              iconSize: 30,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFB993D6), Color(0xFF8CA6DB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                courseDetails!['name_of_course'] ?? 'Course Details',
                style: GoogleFonts.lobster(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundImage:
                      const AssetImage('assets/images/animateur.jpg'),
                  radius: 20,
                ),
              ),
            ],
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: courseDetails!['imageOfCourse'] != null
                        ? Image.network(
                            'https://back-end-of-mediapro-1.onrender.com/uploads/course/${courseDetails!['imageOfCourse']}',
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                color: Colors.grey[200],
                                child: Center(
                                  child: Icon(Icons.broken_image, size: 50),
                                ),
                              );
                            },
                          )
                        : Container(
                            height: 200,
                            color: Colors.grey[200],
                            child: Center(
                              child: Icon(Icons.image, size: 50),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  courseDetails!['name_of_course'] ?? 'Course Title',
                  style: GoogleFonts.aBeeZee(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Formateur: ${courseDetails!['name_of_formator'] ?? 'Unknown Instructor'}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: const Color.fromARGB(255, 149, 56, 203),
                      size: 30.0,
                    ),
                    SizedBox(width: 10),
                    Text(
                      '4.8 (25 Évaluations)',
                      style: TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 149, 56, 203),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (context) => _buildBottomSheet(
                              context,
                              'Description',
                              courseDetails!['description'] ??
                                  'No description available',
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                            side: BorderSide(
                              color: const Color(0xFFB993D6),
                              width: 2,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Description',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (context) => _buildBottomSheet(
                              context,
                              'À propos du formateur',
                              courseDetails!['name_of_formator'] != null
                                  ? '${courseDetails!['name_of_formator']} .'
                                  : 'Information sur le formateur non disponible',
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                            side: BorderSide(
                              color: const Color(0xFFB993D6),
                              width: 2,
                            ),
                          ),
                        ),
                        child: const Text(
                          'À propos',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (context) => _buildBottomSheet(
                              context,
                              'Leçons',
                              'Le contenu des leçons sera disponible une fois le cours acheté.',
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                            side: BorderSide(
                              color: const Color(0xFFB993D6),
                              width: 2,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Leçons',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Text(
                      'Prix du cours',
                      style: GoogleFonts.aBeeZee(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 70),
                    Text(
                      '\$${courseDetails!['price'] ?? '0'}',
                      style: TextStyle(
                        fontSize: 23.0,
                        color: const Color.fromARGB(255, 110, 56, 203),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFB993D6), Color(0xFF8CA6DB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final token =
                            prefs.getString('jwtToken'); // Clé corrigée

                        if (token == null) {
                          // Stocker l'intention de commander
                          await prefs.setString(
                              'pendingAction', 'order_course');
                          await prefs.setString(
                              'pendingCourseId', widget.courseId);

                          // Redirection vers le login
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Login()),
                          );

                          // Afficher un message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Connectez-vous pour vous inscrire à ce cours"),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Command2Page(courseId: widget.courseId),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 20),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: const Text(
                        "Inscription",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Méthode pour afficher le bottom sheet amélioré
  Widget _buildBottomSheet(BuildContext context, String title, String content) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.4,
      maxChildSize: 0.7,
      minChildSize: 0.3,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              controller: scrollController,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(content),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fermer'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
