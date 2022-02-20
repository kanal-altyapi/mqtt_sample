import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NameTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;

  NameTextField({required this.hintText,required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp(r'\s+')) // no spaces allowed
        ],
        validator: (value) {
          if (value!.trim().isEmpty) {
            return 'Please enter a valid $hintText';
          }
          return null;
        },
        controller: controller,
        style:const TextStyle(
          fontSize: 18.0,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding:const EdgeInsets.only(bottom: -15.0),
          focusedBorder:const UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
