import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mediapro/Signup/signup3.dart';
import '../Bottom/Component/textfield.dart';

class Signup2 extends StatelessWidget {
  const Signup2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
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
                const SizedBox(height: 150),
                Text(
                  "S'inscrire",
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
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
                ),
                const SizedBox(height: 20),
                MyTextField(
                  textInputType: TextInputType.visiblePassword,
                  isPassword: true,
                  hintText: "Mot de passe",
                ),
                const SizedBox(height: 20),
                MyTextField(
                  textInputType: TextInputType.visiblePassword,
                  isPassword: true,
                  hintText: "Confirmez le mot de passe",
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Color.fromARGB(255, 255, 255, 255)),
                        padding: MaterialStateProperty.all(
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10)),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                        ),
                      ),
                      child: Text(
                        "Précédent",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => const Signup3(),
                          ),
                        ); // Navigue vers la route "/signup3"
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Color.fromARGB(255, 25, 0, 253)),
                        padding: MaterialStateProperty.all(
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10)),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                        ),
                      ),
                      child: Text(
                        "Se Connecter",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
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
