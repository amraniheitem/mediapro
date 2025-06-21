import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:mediapro/Bottom/bottombar.dart';
import 'package:mediapro/Pages/Animateur/contactez.dart';
import 'package:mediapro/Pages/Home/commande2.dart';
import 'package:mediapro/Pages/Home/commandeProd.dart';
import 'package:mediapro/Pages/Voice/contactezv.dart';
import 'package:mediapro/Signup/signup1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../Bottom/Component/textfield.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with AutomaticKeepAliveClientMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  bool get wantKeepAlive => true;

  Future<void> _login(BuildContext context) async {
    if (_isLoading) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez remplir tous les champs."),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://back-end-of-mediapro-1.onrender.com/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwtToken', responseData['token'] ?? '');

        // Gestion robuste de l'ID utilisateur
        final user = responseData['user'] ?? {};
        String? userId;
        if (user['_id'] != null) {
          userId = user['_id'].toString();
        } else if (user['id'] != null) {
          userId = user['id'].toString();
        } else if (user['userId'] != null) {
          userId = user['userId'].toString();
        }

        if (userId == null) {
          throw Exception("ID utilisateur non trouvé dans la réponse");
        }

        print("Réponse serveur brute: ${response.body}");

// CORRECTION : Utilisez les bonnes clés
        await prefs.setString('userId', userId);
        await prefs.setString('nom', user['nom']?.toString() ?? '');
        await prefs.setString(
            'prénom', user['prénom']?.toString() ?? ''); // Clé exacte
        await prefs.setString('wilaya', user['wilaya']?.toString() ?? '');
        await prefs.setString('email', user['email']?.toString() ?? '');
        await prefs.setString(
            'numéro', user['numéro']?.toString() ?? ''); // Clé exacte

        print("Données sauvegardées:");
        print("nom: ${prefs.getString('nom')}");
        print("Prénom: ${prefs.getString('prénom')}");
        print("Téléphone: ${prefs.getString('numéro')}");
        final pendingAction = prefs.getString('pendingAction');
        final pendingCourseId = prefs.getString('pendingCourseId');
        final pendingProductId = prefs.getString('pendingProductId');
        final pendingAnimateurId = prefs.getString('pendingAnimateurId');
        final pendingVoixId = prefs.getString('pendingVoixId');

        // Gestion des redirections après login
        if (pendingAction == 'order_course' && pendingCourseId != null) {
          await prefs.remove('pendingAction');
          await prefs.remove('pendingCourseId');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Command2Page(courseId: pendingCourseId),
            ),
          );
        } else if (pendingAction == 'order_product' &&
            pendingProductId != null) {
          await prefs.remove('pendingAction');
          await prefs.remove('pendingProductId');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ProductOrderPage(productId: pendingProductId),
            ),
          );
        } else if (pendingAction == 'contact_animator' &&
            pendingAnimateurId != null) {
          await prefs.remove('pendingAction');
          await prefs.remove('pendingAnimateurId');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Contactez(animateurId: pendingAnimateurId),
            ),
          );
        } else if (pendingAction == 'contact_voice' && pendingVoixId != null) {
          await prefs.remove('pendingAction');
          await prefs.remove('pendingVoixId');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ContactezV(voixId: pendingVoixId),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const BottomNavbar()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Échec de la connexion. Vérifiez vos identifiants"),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur: ${e.toString()}"),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/Capture.PNG"),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.07),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: screenHeight * 0.1),
                  Text(
                    'Se Connecter',
                    style: TextStyle(
                      fontSize: screenWidth * 0.1,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  MyTextField(
                    controller: emailController,
                    textInputType: TextInputType.emailAddress,
                    isPassword: false,
                    hintText: "Email",
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  MyTextField(
                    controller: passwordController,
                    textInputType: TextInputType.visiblePassword,
                    isPassword: true,
                    hintText: "Mot de passe",
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0xFF2D42C8)),
                      padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                          horizontal: screenWidth * 0.05,
                        ),
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                    onPressed: _isLoading ? null : () => _login(context),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Se Connecter",
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  SizedBox(height: screenHeight * 0.15),
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(
                          height: 9,
                          thickness: 2,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      const Text(
                        "Connectez Vous",
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      const Expanded(
                        child: Divider(
                          height: 9,
                          thickness: 2,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Cette fonctionnalité n'est pas disponible pour le moment."),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: SvgPicture.asset(
                          "assets/images/facebook.svg",
                          height: screenHeight * 0.1,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.1),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Cette fonctionnalité n'est pas disponible pour le moment."),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: SvgPicture.asset(
                          "assets/images/google.svg",
                          height: screenHeight * 0.1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.08),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Signup()),
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
