import 'package:flutter/material.dart';
import 'dart:io';

import 'package:google_fonts/google_fonts.dart';

class Probleme extends StatefulWidget {
  @override
  ProblemeSet createState() => ProblemeSet();
}

class ProblemeSet extends State<Probleme> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _probleme = '';

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
            'Signaler un probléme',
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
                SizedBox(height: 20),
                TextFormField(
                  initialValue: _name,
                  decoration: InputDecoration(
                    labelText: 'Nom complet',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre nom';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _name = value;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  initialValue: _email,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Veuillez entrer un email valide';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _email = value;
                  },
                ),
                SizedBox(height: 20),
                SizedBox(height: 20),
                TextFormField(
                  initialValue: _probleme,
                  decoration: InputDecoration(
                    labelText: 'Votre probléme ...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                  onChanged: (value) {
                    _probleme = value;
                  },
                ),
                SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFB993D6), Color(0xFF8CA6DB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(
                        50), // BorderRadius for the button
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Save the information
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Message envoyé avec succès')),
                        );
                      }
                    },
                    child: const Text(
                      "Souvgardez",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Couleur du texte
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      backgroundColor: Colors.transparent,
                      textStyle: TextStyle(
                          fontSize:
                              18), // Make the ElevatedButton background transparent
                      shadowColor: Colors
                          .transparent, // Remove the shadow of ElevatedButton
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
}
