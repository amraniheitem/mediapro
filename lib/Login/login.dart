import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:mediapro/Bottom/bottombar.dart';
import 'package:mediapro/Signup/signup1.dart';
import 'dart:convert';
import '../Bottom/Component/textfield.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
/*
    Future<void> _login() async {
      print('Email: ${emailController.text}');
      print('Password: ${passwordController.text}');

      final response = await http.post(
        Uri.parse('https://desktop-star-event-1.onrender.com/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': emailController.text,
          'password': passwordController.text,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final String token = responseData['token'];
        print('Token: $token'); // Afficher le token
        Navigator.pushNamed(context, "/home1");
      } else {
        String errorMessage;
        try {
          final Map<String, dynamic> errorResponse = json.decode(response.body);
          errorMessage = errorResponse['message'] ?? 'Échec de la connexion!';
        } catch (e) {
          errorMessage = 'Erreur lors de la connexion!';
        }

        // Afficher le message d'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
*/
    return Scaffold(
      body: SingleChildScrollView(
        // Ajoutez SingleChildScrollView ici
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/Capture.PNG"),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.07),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  Text(
                    'Se Connecter',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.1,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  MyTextField(
                    textInputType: TextInputType.emailAddress,
                    isPassword: false,
                    hintText: "Email",
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  MyTextField(
                    textInputType: TextInputType.visiblePassword,
                    isPassword: true,
                    hintText: "Mot de passe",
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0xFF2D42C8)),
                      padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.02,
                          horizontal: MediaQuery.of(context).size.width * 0.05,
                        ),
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => BottomNavbar()),
                      );
                    },
                    child: Text(
                      "Se Connecter",
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(
                          height: 9,
                          thickness: 2,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                      const Text(
                        "Connectez Vous",
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                      const Expanded(
                        child: Divider(
                          height: 9,
                          thickness: 2,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Gérer la connexion Facebook
                        },
                        child: SvgPicture.asset(
                          "assets/images/facebook.svg",
                          height: MediaQuery.of(context).size.height * 0.1,
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.1),
                      GestureDetector(
                        onTap: () {
                          // Gérer la connexion Google
                        },
                        child: SvgPicture.asset(
                          "assets/images/google.svg",
                          height: MediaQuery.of(context).size.height * 0.1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                  TextButton(
                    onPressed: () {
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => const Signup(),
                        ),
                      );
                    },
                    child: RichText(
                      text: const TextSpan(
                        text: "Si vous n'avez pas de compte,",
                        style: TextStyle(color: Colors.grey),
                        children: [
                          TextSpan(
                            text: " s'inscrire",
                            style: TextStyle(
                              color: Color.fromARGB(255, 46, 9, 121),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
