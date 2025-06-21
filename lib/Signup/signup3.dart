import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mediapro/Login/login.dart';
import '../Bottom/Component/textfield.dart';

class Signup3 extends StatefulWidget {
  final String userId;

  const Signup3({super.key, required this.userId});

  @override
  State<Signup3> createState() => _Signup3State();
}

class _Signup3State extends State<Signup3> {
  final TextEditingController code = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    print("✅ Arrivé dans Signup3 avec userId: ${widget.userId}");
  }

  Future<void> verifyCode() async {
    final String codeText = code.text.trim();

    if (codeText.isEmpty || codeText.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez entrer un code à 6 chiffres."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(
            "https://back-end-of-mediapro-1.onrender.com/auth/verify/${widget.userId}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"code": codeText}),
      );

      final data = jsonDecode(response.body);
      print("📨 Réponse API vérification: $data");

      // ✅ Vérifie si le message contient le mot "succès"
      if (response.statusCode == 200 &&
          (data["message"]?.toString().toLowerCase().contains("succès") ??
              false)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Compte vérifié avec succès !"),
            backgroundColor: Colors.green,
          ),
        );

        // 🔁 Aller à Login
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const Login()),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? "Code incorrect."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("❌ Erreur vérification : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur réseau : ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

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
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 100),
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
                  "Nous avons envoyé un code de 6 chiffres à votre email",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                MyTextField(
                  textInputType: TextInputType.number,
                  isPassword: false,
                  hintText: "Entrez le code de confirmation",
                  controller: code,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: isLoading ? null : verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 30),
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
                          "Entrer",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
