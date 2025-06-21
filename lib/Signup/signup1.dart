import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mediapro/Signup/signup2.dart';
import '../Bottom/Component/textfield.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final ValueNotifier<String?> selectedWilaya = ValueNotifier<String?>(null);

  bool isLoading = false;

  static const List<String> wilayas = [
    "Adrar",
    "Chlef",
    "Laghouat",
    "Oum El Bouaghi",
    "Batna",
    "Béjaïa",
    "Biskra",
    "Béchar",
    "Blida",
    "Bouira",
    "Tamanrasset",
    "Tébessa",
    "Tlemcen",
    "Tiaret",
    "Tizi Ouzou",
    "Alger",
    "Djelfa",
    "Jijel",
    "Sétif",
    "Saïda",
    "Skikda",
    "Sidi Bel Abbès",
    "Annaba",
    "Guelma",
    "Constantine",
    "Médéa",
    "Mostaganem",
    "M'Sila",
    "Mascara",
    "Ouargla",
    "Oran",
    "El Bayadh",
    "Illizi",
    "Bordj Bou Arreridj",
    "Boumerdès",
    "El Tarf",
    "Tindouf",
    "Tissemsilt",
    "El Oued",
    "Khenchela",
    "Souk Ahras",
    "Tipaza",
    "Mila",
    "Aïn Defla",
    "Naâma",
    "Aïn Témouchent",
    "Ghardaïa",
    "Relizane",
    "Timimoun",
    "Bordj Badji Mokhtar",
    "Ouled Djellal",
    "Béni Abbès",
    "In Salah",
    "In Guezzam",
    "Touggourt",
    "Djanet",
    "El M'Ghair",
    "El Menia"
  ];

  @override
  void dispose() {
    lastNameController.dispose();
    firstNameController.dispose();
    birthDateController.dispose();
    phoneNumberController.dispose();
    selectedWilaya.dispose();
    super.dispose();
  }

  Future<void> submitForm() async {
    if (lastNameController.text.isEmpty ||
        firstNameController.text.isEmpty ||
        birthDateController.text.isEmpty ||
        selectedWilaya.value == null ||
        phoneNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ✅ Validation du numéro de téléphone (doit comporter 10 chiffres)
    final phone = phoneNumberController.text.trim();
    final phoneRegExp = RegExp(r'^\d{10}$');
    if (!phoneRegExp.hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Numéro invalide. Exemple : 0781234567"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(
            'https://back-end-of-mediapro-1.onrender.com/auth/info_register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "nom": lastNameController.text,
          "prénom": firstNameController.text,
          "date": birthDateController.text,
          "numéro": phoneNumberController.text,
          "wilaya": selectedWilaya.value,
        }),
      );

      final data = jsonDecode(response.body);
      print("✅ Réponse: $data");

      if (mounted &&
          data.containsKey('userId') &&
          data['userId'].toString().isNotEmpty) {
        final userId = data['userId'].toString();
        print("✅ userId valide : $userId");

        Future.microtask(() {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => Signup2(userId: userId),
            ),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Erreur lors de l’enregistrement'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("❌ Erreur réseau : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur réseau : ${e.toString()}'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  "assets/images/Capture2.PNG",
                  fit: BoxFit.cover,
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.15),
                            Text(
                              "S'inscrire",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 40,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Informations Personnelles",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 30),
                            MyTextField(
                                controller: lastNameController,
                                textInputType: TextInputType.text,
                                isPassword: false,
                                hintText: "Nom"),
                            const SizedBox(height: 20),
                            MyTextField(
                                controller: firstNameController,
                                textInputType: TextInputType.text,
                                isPassword: false,
                                hintText: "Prénom"),
                            const SizedBox(height: 20),

                            // ✅ Champ de date de naissance avec DatePicker
                            GestureDetector(
                              onTap: () async {
                                final DateTime? pickedDate =
                                    await showDatePicker(
                                  context: context,
                                  initialDate: DateTime(2000),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                );
                                if (pickedDate != null) {
                                  final formattedDate =
                                      "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                                  birthDateController.text = formattedDate;
                                }
                              },
                              child: AbsorbPointer(
                                child: MyTextField(
                                    controller: birthDateController,
                                    textInputType: TextInputType.none,
                                    isPassword: false,
                                    hintText: "Date de Naissance"),
                              ),
                            ),

                            const SizedBox(height: 20),
                            MyTextField(
                                controller: phoneNumberController,
                                textInputType: TextInputType.phone,
                                isPassword: false,
                                hintText: "Numéro téléphone"),
                            const SizedBox(height: 20),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(50)),
                              child: ValueListenableBuilder<String?>(
                                valueListenable: selectedWilaya,
                                builder: (context, value, _) {
                                  return DropdownButtonFormField<String>(
                                    value: value,
                                    decoration: const InputDecoration(
                                        border: InputBorder.none),
                                    hint:
                                        const Text('Sélectionnez votre wilaya'),
                                    items: wilayas
                                        .map((wilaya) => DropdownMenuItem(
                                            value: wilaya, child: Text(wilaya)))
                                        .toList(),
                                    onChanged: (newValue) =>
                                        selectedWilaya.value = newValue,
                                    isExpanded: true,
                                  );
                                },
                              ),
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
                                        vertical: 14, horizontal: 20),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                  ),
                                  child: const Text("Précédent",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black)),
                                ),
                                ElevatedButton(
                                  onPressed: isLoading ? null : submitForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 20),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.black))
                                      : const Text("Suivant",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
