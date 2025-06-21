import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final TextInputType textInputType;
  final bool isPassword;
  final String hintText;
  final TextEditingController controller; // Ajoutez ceci

  const MyTextField({
    Key? key,
    required this.textInputType,
    required this.isPassword,
    required this.hintText,
    required this.controller, // Ajoutez ceci
  }) : super(key: key);

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: TextField(
        controller: widget.controller, // Utilisez le contrôleur ici
        focusNode: _focusNode,
        keyboardType: widget.textInputType,
        obscureText: widget.isPassword,
        decoration: InputDecoration(
          hintText: widget.hintText,
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 20.0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none,
          ),
        ),
        onEditingComplete: () {
          _focusNode.unfocus();
        },
      ),
    );
  }
}
