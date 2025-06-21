// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mediapro/Login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactezV extends StatefulWidget {
  final String voixId;

  const ContactezV({super.key, required this.voixId});

  @override
  _ContactezVState createState() => _ContactezVState();
}

class _ContactezVState extends State<ContactezV> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _villeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _eventLieuController = TextEditingController();
  final TextEditingController _eventDateController = TextEditingController();
  final TextEditingController _eventHeureController = TextEditingController();
  final TextEditingController _eventTypeController = TextEditingController();

  String? _userId;
  bool _isLoading = false;
  String? _dateError;
  String? _timeError;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
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

  void _redirectToLogin() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const Login(),
          ),
        );
      },
    );
  }

  bool _validateForm() {
    bool isValid = true;
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!phoneRegex.hasMatch(_phoneController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Numéro invalide (10 chiffres requis)')),
      );
      isValid = false;
    }

    if (!emailRegex.hasMatch(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Format email invalide')),
      );
      isValid = false;
    }

    if (_eventDateController.text.isEmpty ||
        !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(_eventDateController.text)) {
      setState(() => _dateError = 'Format: AAAA-MM-JJ');
      isValid = false;
    } else {
      setState(() => _dateError = null);
    }

    if (_eventHeureController.text.isEmpty ||
        !RegExp(r'^\d{2}:\d{2}$').hasMatch(_eventHeureController.text)) {
      setState(() => _timeError = 'Format: HH:MM');
      isValid = false;
    } else {
      setState(() => _timeError = null);
    }

    return isValid &&
        _nomController.text.isNotEmpty &&
        _prenomController.text.isNotEmpty &&
        _adresseController.text.isNotEmpty &&
        _villeController.text.isNotEmpty &&
        _eventLieuController.text.isNotEmpty &&
        _eventTypeController.text.isNotEmpty;
  }

  Future<void> _submitOrder() async {
    if (!_validateForm()) return;
    if (_userId == null || _token == null) {
      await _clearAuthData();
      _redirectToLogin();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final jsonBody = {
        "userId": _userId,
        "type": "VOICEOVER", // Modification ici
        "details": {
          "voiceoverId": widget.voixId, // Modification ici
          "typeEvenement": _eventTypeController.text,
          "dateEvenement": _eventDateController.text,
          "heureEvenement": _eventHeureController.text,
          "lieuEvenement": _eventLieuController.text
        },
        "phone": _phoneController.text,
        "email": _emailController.text,
        "adresse": _adresseController.text,
        "ville": _villeController.text,
        "nom": _nomController.text,
        "prénom": _prenomController.text,
      };

      print("Envoi du corps JSON: ${jsonEncode(jsonBody)}");

      final response = await http
          .post(
            Uri.parse('https://back-end-of-mediapro-1.onrender.com/order/add'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_token',
            },
            body: jsonEncode(jsonBody),
          )
          .timeout(Duration(seconds: 10));

      print("Réponse du serveur: ${response.statusCode} ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Demande envoyée avec succès!'),
            duration: Duration(seconds: 3),
          ),
        );

        Future.delayed(Duration(seconds: 5), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      } else {
        final errorMessage =
            jsonDecode(response.body)['message'] ?? response.body;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur serveur: $errorMessage')),
        );
      }
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Timeout: Serveur non disponible')),
      );
    } on http.ClientException {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur inconnue: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearAuthData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('jwtToken');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.0),
                              Text(
                                "Coordonnées de la commande",
                                style: TextStyle(
                                    fontSize: 22, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(16.0),
                      margin: EdgeInsets.all(16.0),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Nom:',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    TextField(
                                      controller: _nomController,
                                      decoration: InputDecoration(
                                        hintText: 'Entrez votre Nom...',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[200],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Prénom:',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    TextField(
                                      controller: _prenomController,
                                      decoration: InputDecoration(
                                        hintText: 'Entrez votre Prénom...',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
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
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Adresse:',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    TextField(
                                      controller: _adresseController,
                                      decoration: InputDecoration(
                                        hintText: 'Entrez votre adresse...',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[200],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ville:',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    TextField(
                                      controller: _villeController,
                                      decoration: InputDecoration(
                                        hintText: 'Entrez votre ville...',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
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
                          SizedBox(height: 20),
                          Text(
                            'Numéro de téléphone:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 10),
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
                          SizedBox(height: 20),
                          Text(
                            'Adresse Email:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 10),
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
                          SizedBox(height: 20),
                          Text(
                            "Lieu de l'événement:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: _eventLieuController,
                            decoration: InputDecoration(
                              hintText: "Entrez le Lieu de l'événement....",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Date de l'événement:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: _eventDateController,
                            decoration: InputDecoration(
                              hintText: "AAAA-MM-JJ",
                              errorText: _dateError,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Heure de l'événement:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: _eventHeureController,
                            decoration: InputDecoration(
                              hintText: "HH:MM",
                              errorText: _timeError,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Type de l'événement:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: _eventTypeController,
                            decoration: InputDecoration(
                              hintText: "Publicité, Documentaire...",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              SizedBox(width: 65),
                              ElevatedButton.icon(
                                onPressed: _isLoading ? null : _submitOrder,
                                icon: Icon(Icons.contact_mail),
                                label: _isLoading
                                    ? CircularProgressIndicator()
                                    : Text(
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
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
