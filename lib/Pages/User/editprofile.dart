// edit_profile.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  File? _image;
  String? _selectedWilaya;

  // Liste des 48 wilayas d'Algérie
  final List<String> _wilayas = [
    'Adrar',
    'Chlef',
    'Laghouat',
    'Oum El Bouaghi',
    'Batna',
    'Béjaïa',
    'Biskra',
    'Béchar',
    'Blida',
    'Bouira',
    'Tamanrasset',
    'Tébessa',
    'Tlemcen',
    'Tiaret',
    'Tizi Ouzou',
    'Alger',
    'Djelfa',
    'Jijel',
    'Sétif',
    'Saïda',
    'Skikda',
    'Sidi Bel Abbès',
    'Annaba',
    'Guelma',
    'Constantine',
    'Médéa',
    'Mostaganem',
    "M'Sila",
    'Mascara',
    'Ouargla',
    'Oran',
    'El Bayadh',
    'Illizi',
    'Bordj Bou Arréridj',
    'Boumerdès',
    'El Tarf',
    'Tindouf',
    'Tissemsilt',
    'El Oued',
    'Khenchela',
    'Souk Ahras',
    'Tipaza',
    'Mila',
    'Aïn Defla',
    'Naâma',
    'Aïn Témouchent',
    'Ghardaïa',
    'Relizane'
  ];

  @override
  void initState() {
    super.initState();
    // Initialiser les contrôleurs
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedWilaya = prefs.getString('wilaya');

    setState(() {
      _firstNameController.text = prefs.getString('prénom') ?? '';
      _lastNameController.text = prefs.getString('nom') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
      _phoneController.text = prefs.getString('numéro') ?? '';

      // Gérer les incompatibilités de wilaya
      if (savedWilaya != null) {
        // Trouver une correspondance insensible à la casse avec normalisation des accents
        final normalizedSaved = _normalizeString(savedWilaya);
        _selectedWilaya = _wilayas.firstWhere(
          (wilaya) => _normalizeString(wilaya) == normalizedSaved,
          orElse: () => _wilayas[0],
        );
      } else {
        _selectedWilaya = _wilayas[0];
      }
    });
  }

  // Fonction utilitaire pour normaliser les chaînes
  String _normalizeString(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[àâä]'), 'a')
        .replaceAll(RegExp(r'[ïî]'), 'i')
        .replaceAll(RegExp(r'[ôö]'), 'o')
        .replaceAll(RegExp(r'[ùûü]'), 'u')
        .replaceAll('ç', 'c')
        .replaceAll(' ', '');
  }

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('prénom', _firstNameController.text);
      await prefs.setString('nom', _lastNameController.text);

      // Sauvegarder la wilaya sélectionnée
      if (_selectedWilaya != null) {
        await prefs.setString('wilaya', _selectedWilaya!);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour avec succès')),
      );

      Navigator.pop(context); // Retour au profil
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFB993D6), Color(0xFF8CA6DB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            'Modifier le Profil',
            style: GoogleFonts.lobster(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage('assets/images/profile.jpg'),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt,
                            color: Colors.blue, size: 30),
                        onPressed: _pickImage,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'Prénom',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre prénom';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nom',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre nom';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Email (lecture seule)
                TextFormField(
                  controller: _emailController,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                    filled: true,
                    fillColor: Color(0xFFF0F0F0),
                  ),
                ),
                const SizedBox(height: 20),
                // Téléphone (lecture seule)
                TextFormField(
                  controller: _phoneController,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                    filled: true,
                    fillColor: Color(0xFFF0F0F0),
                  ),
                ),
                const SizedBox(height: 20),
                // Profession fixée à "Utilisateur simple"
                TextFormField(
                  initialValue: 'Utilisateur simple',
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Profession',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.work),
                    filled: true,
                    fillColor: Color(0xFFF0F0F0),
                  ),
                ),
                const SizedBox(height: 20),
                // Wilaya - Menu déroulant
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedWilaya,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down),
                    decoration: const InputDecoration(
                      labelText: 'Wilaya',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    items: _wilayas.map((String wilaya) {
                      return DropdownMenuItem<String>(
                        value: wilaya,
                        child: Text(wilaya),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedWilaya = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez sélectionner votre wilaya';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save),
                  label: const Text('Sauvegarder'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8CA6DB),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
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
