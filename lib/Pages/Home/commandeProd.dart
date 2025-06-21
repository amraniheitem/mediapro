// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mediapro/Login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductOrderPage extends StatefulWidget {
  final String productId;

  const ProductOrderPage({super.key, required this.productId});

  @override
  _ProductOrderPageState createState() => _ProductOrderPageState();
}

class _ProductOrderPageState extends State<ProductOrderPage> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _villeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _quantityController =
      TextEditingController(text: "1");

  String? _userId;
  bool _isLoading = false;
  String? _token;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    print(
        '[ProductOrderPage] Initialisation avec productId: ${widget.productId}');
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    print('[ProductOrderPage] Chargement des données utilisateur...');
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Récupération des valeurs
    final userId = prefs.getString('userId');
    final token = prefs.getString('jwtToken');

    print('[ProductOrderPage] User ID depuis SharedPreferences: $userId');
    print('[ProductOrderPage] Token depuis SharedPreferences: $token');

    // Vérification de la validité des credentials
    if (userId == null || userId.isEmpty || token == null || token.isEmpty) {
      print('[ProductOrderPage] Données utilisateur manquantes ou invalides');

      // Stocker l'action en attente pour redirection après login
      await prefs.setString('pendingAction', 'order_product');
      await prefs.setString('pendingProductId', widget.productId);

      // Nettoyer les données potentiellement corrompues
      await prefs.remove('userId');
      await prefs.remove('jwtToken');

      _redirectToLogin();
      return;
    }

    setState(() {
      _userId = userId;
      _token = token;
      _isAuthenticated = true;
    });
  }

  void _redirectToLogin() {
    print('[ProductOrderPage] Redirection vers la page de connexion...');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    });
  }

  bool _validateForm() {
    bool isValid = true;
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final quantityRegex = RegExp(r'^[1-9]\d*$');

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

    if (!quantityRegex.hasMatch(_quantityController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quantité invalide (nombre entier positif)')),
      );
      isValid = false;
    }

    return isValid &&
        _nomController.text.isNotEmpty &&
        _prenomController.text.isNotEmpty &&
        _adresseController.text.isNotEmpty &&
        _villeController.text.isNotEmpty;
  }

  Future<void> _submitOrder() async {
    if (!_validateForm()) return;

    // Vérification finale de l'authentification
    if (!_isAuthenticated || _userId == null || _token == null) {
      print('[ProductOrderPage] Échec de validation des credentials');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Session invalide, veuillez vous reconnecter')),
      );
      await _clearAuthData();
      _redirectToLogin();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final jsonBody = {
        "userId": _userId,
        "type": "PRODUIT",
        "details": {
          "produitId": widget.productId,
          "quantity": int.parse(_quantityController.text),
        },
        "phone": _phoneController.text,
        "email": _emailController.text,
        "adresse": _adresseController.text,
        "ville": _villeController.text,
        "nom": _nomController.text,
        "prénom": _prenomController.text,
      };

      print('[ProductOrderPage] Corps de la requête: ${jsonEncode(jsonBody)}');

      final response = await http
          .post(
            Uri.parse('https://back-end-of-mediapro-1.onrender.com/order/add'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_token',
            },
            body: jsonEncode(jsonBody),
          )
          .timeout(const Duration(seconds: 15));

      print('[ProductOrderPage] Statut de la réponse: ${response.statusCode}');
      print('[ProductOrderPage] Corps de la réponse: ${response.body}');

      // CORRECTION ICI: Accepter les statuts 200 ET 201
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Commande passée avec succès!'),
            duration: Duration(seconds: 3),
          ),
        );

        Future.delayed(Duration(seconds: 3), () {
          if (mounted) Navigator.pop(context);
        });
      } else if (response.statusCode == 401) {
        // Token invalide ou expiré
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Session expirée, veuillez vous reconnecter')),
        );
        await _clearAuthData();
        _redirectToLogin();
      } else {
        final responseBody =
            response.body.isNotEmpty ? jsonDecode(response.body) : {};
        final errorMessage = responseBody['message'] ?? response.body;

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
      print('[ProductOrderPage] Erreur: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur inattendue: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _clearAuthData() async {
    print('[ProductOrderPage] Nettoyage des données d\'authentification...');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('jwtToken');
    setState(() {
      _userId = null;
      _token = null;
      _isAuthenticated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Commande Produit',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFFB993D6),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 0.0, left: 0.0, right: 0.0),
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
            child: Column(
              children: [
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
                        "Quantité:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Entrez la quantité...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                      ),
                      SizedBox(height: 30),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _submitOrder,
                          icon: Icon(Icons.shopping_cart),
                          label: _isLoading
                              ? CircularProgressIndicator()
                              : Text(
                                  'Passer la commande',
                                  style: TextStyle(fontSize: 18),
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFB993D6),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
