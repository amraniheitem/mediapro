import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Team extends StatefulWidget {
  const Team({super.key});

  @override
  _TeamState createState() => _TeamState();
}

class _TeamState extends State<Team> {
  String? selectedDomain;

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
            'MediaPro Team',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Sélectionnez un domaine:",
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: selectedDomain,
              hint: const Text("Choisissez un domaine"),
              items: ['Animateur', 'Voix Off', 'Formateur', 'Produit en Vente']
                  .map((String domain) {
                return DropdownMenuItem<String>(
                  value: domain,
                  child: Text(domain),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDomain = value;
                });
              },
            ),
            const SizedBox(height: 20),
            if (selectedDomain != null)
              Expanded(
                child: SingleChildScrollView(
                  child: DomainForm(domain: selectedDomain!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DomainForm extends StatelessWidget {
  final String domain;

  DomainForm({required this.domain});

  final _formKey = GlobalKey<FormState>(); // Clé pour le formulaire

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey, // Associer la clé au formulaire
      child: Column(
        children: [
          CommonFields(),
          const SizedBox(height: 20),
          if (domain == 'Animateur') AnimatorForm(),
          if (domain == 'Voix Off') VoiceOffForm(),
          if (domain == 'Formateur') TrainerForm(),
          if (domain == 'Produit en Vente') ProductForm(),
          const SizedBox(height: 20),
          SubmitButton(formKey: _formKey), // Passer la clé au bouton
        ],
      ),
    );
  }
}

class CommonFields extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: 'Nom'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer un nom';
            }
            return null;
          },
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Prénom'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer un prénom';
            }
            return null;
          },
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Wilaya'),
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Adresse'),
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Numéro de téléphone'),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer un numéro de téléphone';
            }
            return null;
          },
        ),
      ],
    );
  }
}

class AnimatorForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: 'Années d\'expérience'),
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Type de Programme'),
        ),
      ],
    );
  }
}

class VoiceOffForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: 'Type de voix'),
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Langues maîtrisées'),
        ),
      ],
    );
  }
}

class TrainerForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: 'Domaine de formation'),
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Expérience'),
        ),
      ],
    );
  }
}

class ProductForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: 'Nom du produit'),
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Description'),
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Quantité du produit'),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}

class SubmitButton extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const SubmitButton({required this.formKey, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (formKey.currentState?.validate() ?? false) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Message envoyé avec succès')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Veuillez corriger les erreurs')),
          );
        }
      },
      child: const Text(
        "Sauvegardez",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        backgroundColor: const Color(0xFFB993D6),
        textStyle: const TextStyle(fontSize: 18),
      ),
    );
  }
}
