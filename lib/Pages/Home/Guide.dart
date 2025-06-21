import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediapro/Pages/Home/course.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Guide extends StatefulWidget {
  const Guide({super.key});

  @override
  State<Guide> createState() => _GuideState();
}

class _GuideState extends State<Guide> {
  List<dynamic> courses = [];
  List<dynamic> categories = [];
  bool isLoading = true;
  bool isCategoryLoading = true;
  String? errorMessage;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchCourses();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://back-end-of-mediapro-1.onrender.com/catecourse/list'),
      );

      if (response.statusCode == 200) {
        setState(() {
          categories = json.decode(response.body);
          isCategoryLoading = false;
        });
      } else {
        setState(() {
          isCategoryLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isCategoryLoading = false;
      });
    }
  }

  Future<void> fetchCourses({String? categoryId}) async {
    setState(() {
      isLoading = true;
      _selectedCategoryId = categoryId;
    });

    try {
      final response = await http.get(
        Uri.parse('https://back-end-of-mediapro-1.onrender.com/course/list'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          List<dynamic> allCourses = data['data'];

          // Filtrer par catégorie si une catégorie est sélectionnée
          List<dynamic> filteredCourses = categoryId != null
              ? allCourses
                  .where((course) =>
                      course['category'] != null &&
                      course['category']['_id'] == categoryId)
                  .toList()
              : allCourses;

          setState(() {
            courses = filteredCourses;
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Failed to load courses: ${data['message']}';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage =
              'Failed to load courses (Status: ${response.statusCode})';
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
    return Scaffold(
      body: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Scaffold(
          appBar: AppBar(
            title: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [Color(0xFFB993D6), Color(0xFF8CA6DB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                'Mediapro',
                style: GoogleFonts.lobster(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.notifications),
                iconSize: 30,
                onPressed: () {},
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                  child: CircleAvatar(
                    backgroundImage: AssetImage('assets/images/animateur.jpg'),
                    radius: 20,
                  ),
                ),
              ),
            ],
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Trouvez...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.search),
                      iconSize: 30,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16.0),
                child: const Text(
                  'Sélectionnez un type des Cours :',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              // Liste des catégories
              if (isCategoryLoading)
                Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length + 1, // +1 pour "Toutes"
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // Option "Toutes"
                        return Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: ChoiceChip(
                            label: Text('Toutes'),
                            selected: _selectedCategoryId == null,
                            onSelected: (selected) {
                              if (selected) {
                                fetchCourses();
                              }
                            },
                          ),
                        );
                      }

                      final categoryIndex = index - 1;
                      final category = categories[categoryIndex];

                      return Padding(
                        padding: EdgeInsets.only(
                            left: 8.0,
                            right: categoryIndex == categories.length - 1
                                ? 16.0
                                : 0),
                        child: ChoiceChip(
                          label: Text(category['name'] ?? 'Catégorie inconnue'),
                          selected: _selectedCategoryId == category['_id'],
                          onSelected: (selected) {
                            if (selected) {
                              fetchCourses(categoryId: category['_id']);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16.0),
                child: const Text(
                  'Cours disponibles :',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : errorMessage != null
                        ? Center(child: Text(errorMessage!))
                        : courses.isEmpty
                            ? Center(child: Text('Aucun cours disponible'))
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                itemCount: courses.length,
                                itemBuilder: (context, index) {
                                  final course = courses[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Course(
                                            courseId: course['_id'],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: 200,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 10.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 5,
                                            spreadRadius: 2,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        child: Image.network(
                                          'https://back-end-of-mediapro-1.onrender.com/uploads/course/${course['imageOfCourse']}',
                                          width: double.infinity,
                                          height: 200,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent?
                                                  loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                    : null,
                                              ),
                                            );
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[200],
                                              child: Center(
                                                child: Icon(Icons.broken_image,
                                                    size: 50),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}
