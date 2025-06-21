import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mediapro/Signup/signup3.dart';
import '../Bottom/Component/textfield.dart';

class Signup2 extends StatefulWidget {
  final String userId;

  const Signup2({super.key, required this.userId});

  @override
  State<Signup2> createState() => _Signup2State();
}

class _Signup2State extends State<Signup2> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmedPassword = TextEditingController();

  bool isLoading = false;

  void handleSubmit() async {
    if (email.text.isEmpty ||
        password.text.isEmpty ||
        confirmedPassword.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez remplir tous les champs"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password.text != confirmedPassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Les mots de passe ne correspondent pas"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(
            "https://back-end-of-mediapro-1.onrender.com/auth/account_register/${widget.userId}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email.text,
          "password": password.text,
          "confirmed_password": confirmedPassword.text,
        }),
      );

      final data = jsonDecode(response.body);
      print("✅ Réponse API Signup2: $data");

      if (data.containsKey('userId') &&
          data['userId'] != null &&
          data['userId'].toString().isNotEmpty) {
        String newUserId = data['userId'].toString();

        print("✅ userId est bien défini, on navigue vers Signup3 !");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Signup3(userId: newUserId),
          ),
        );
      } else {
        print("❌ userId manquant dans la réponse !");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message'] ?? "Erreur lors de la création du compte.",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("❌ Erreur API Signup2: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur réseau : ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/Capture2.PNG"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            // ✅ POUR LE SCROLL
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: 150),
                  const Text(
                    "S'inscrire",
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Information du compte",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 30),
                  MyTextField(
                    textInputType: TextInputType.emailAddress,
                    isPassword: false,
                    hintText: "Email",
                    controller: email,
                  ),
                  const SizedBox(height: 20),
                  MyTextField(
                    textInputType: TextInputType.visiblePassword,
                    isPassword: true,
                    hintText: "Mot de passe",
                    controller: password,
                  ),
                  const SizedBox(height: 20),
                  MyTextField(
                    textInputType: TextInputType.visiblePassword,
                    isPassword: true,
                    hintText: "Confirmez le mot de passe",
                    controller: confirmedPassword,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: const Text(
                          "Précédent",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: isLoading ? null : handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 25, 0, 253),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Suivant",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(
                      height: 200), // Ajout de marge pour éviter l’écrasement
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
