import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mediapro/Login/login.dart';

class Command2Page extends StatefulWidget {
  final String courseId;

  const Command2Page({super.key, required this.courseId});

  @override
  _Command2PageState createState() => _Command2PageState();
}

class _Command2PageState extends State<Command2Page> {
  String? _selectedNiveau;
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _villeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  String? _userId;
  String? _token;
  bool _isLoading = false;
  bool _isUserDataLoaded = false; // Nouveau flag pour suivre le chargement

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final token = prefs.getString('jwtToken');

      if (mounted) {
        setState(() {
          _userId = userId;
          _token = token;
          _isUserDataLoaded = true;
        });
      }

      if (token == null || userId == null) {
        _redirectToLogin();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement: ${e.toString()}')),
        );
      }
    }
  }

  void _redirectToLogin() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    }
  }

  Future<void> _submitOrder() async {
    if (!_isUserDataLoaded || _token == null || _userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chargement des données utilisateur...')),
      );
      await _loadUserData();
      if (_token == null || _userId == null) {
        _redirectToLogin();
        return;
      }
    }

    if (!_validateForm()) return;

    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final jsonBody = {
        "nom": _nomController.text,
        "prénom": _prenomController.text,
        "userId": _userId,
        "type": "COURS",
        "details": {
          "courseId": widget.courseId,
          "Niveau": _selectedNiveau,
          "courseDetails": _bioController.text,
        },
        "phone": _phoneController.text,
        "email": _emailController.text,
        "adresse": _adresseController.text,
        "ville": _villeController.text,
      };

      final response = await http.post(
        Uri.parse('https://back-end-of-mediapro-1.onrender.com/order/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(jsonBody),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inscription réussie!'),
              duration: Duration(seconds: 3),
            ),
          );
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) Navigator.pop(context);
          });
        }
      } else {
        final errorMessage = jsonDecode(response.body)['message'] ??
            'Erreur inconnue: ${response.statusCode}';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $errorMessage')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur réseau: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _validateForm() {
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final errors = <String>[];

    if (_nomController.text.isEmpty) errors.add('Le nom est requis');
    if (_prenomController.text.isEmpty) errors.add('Le prénom est requis');
    if (_adresseController.text.isEmpty) errors.add('L\'adresse est requise');
    if (_villeController.text.isEmpty) errors.add('La ville est requise');
    if (!phoneRegex.hasMatch(_phoneController.text))
      errors.add('Numéro invalide (10 chiffres requis)');
    if (!emailRegex.hasMatch(_emailController.text))
      errors.add('Format email invalide');
    if (_selectedNiveau == null) errors.add('Veuillez sélectionner un niveau');

    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errors.join('\n')),
          duration: const Duration(seconds: 5),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _adresseController.dispose();
    _villeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Inscription',
          style: GoogleFonts.lobster(
            fontSize: 35,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFB993D6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Entrez vos coordonnées pour l'inscription dans la formation",
                style: GoogleFonts.roboto(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              // Section Nom et Prénom
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nom:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _nomController,
                          decoration: InputDecoration(
                            hintText: 'Entrez votre nom...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Prénom:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _prenomController,
                          decoration: InputDecoration(
                            hintText: 'Entrez votre prénom...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Champ pour l'adresse
              const Text(
                'Adresse:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _adresseController,
                decoration: InputDecoration(
                  hintText: 'Entrez votre adresse complète...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 20),

              // Champ pour la ville
              const Text(
                'Ville:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _villeController,
                decoration: InputDecoration(
                  hintText: 'Entrez votre ville...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 20),

              // Champ pour le numéro de téléphone
              const Text(
                'Numéro de téléphone:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Entrez votre numéro de téléphone...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 20),

              // Champ pour l'email
              const Text(
                'Adresse Email:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Entrez votre email...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 20),

              // Champ pour le niveau
              const Text(
                'Choisissez votre niveau:',
                style: TextStyle(fontSize: 20),
              ),
              DropdownButton<String>(
                value: _selectedNiveau,
                hint: const Text('Sélectionnez un niveau'),
                items: <String>['Débutant', 'Intermédiaire', 'Expert']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedNiveau = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),
              Text(
                _selectedNiveau != null
                    ? 'Niveau sélectionné: $_selectedNiveau'
                    : 'Aucun niveau sélectionné',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),

              // Champ pour la bio
              const Text(
                'Le but de choisir cette formation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _bioController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Pourquoi choisissez-vous cette formation?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 30),

              // Bouton d'inscription
              Center(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitOrder,
                  icon: const Icon(Icons.shopping_cart),
                  label: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Inscrit dans la formation',
                          style: TextStyle(fontSize: 18),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB993D6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
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
