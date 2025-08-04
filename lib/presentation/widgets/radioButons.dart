import 'package:flutter/material.dart';

  Widget buildTitle() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Create Sports Person Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
    );
  }

  Widget buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        'Provide your honest answers to help us analyze your profile and show to sponsors.',
        textAlign: TextAlign.start,
      ),
    );
  }


  Widget buildTextField(String hintText, String label, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: TextField(
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          counterText: "",
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.black),
          ),
          hintText: hintText,
          suffixIcon: icon != null ? Icon(icon) : null,
          label: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: label,
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
                ),
                TextSpan(
                  text: " *",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMultiLineTextField(String hintText, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: TextField(
        style: const TextStyle(color: Colors.black),
        maxLines: 3,
        minLines: 3,
        decoration: InputDecoration(
          counterText: "",
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.black),
          ),
          hintText: hintText,
          label: Text(label),
        ),
      ),
    );
  }

  Widget buildDropdownFields(String label1, String label2) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Expanded(child: buildTextField("", label1, icon: Icons.keyboard_arrow_down_outlined)),
          SizedBox(width: 16),
          Expanded(child: buildTextField("", label2, icon: Icons.keyboard_arrow_down_outlined)),
        ],
      ),
    );
  }

  Widget buildSubmitButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 24),
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, '/sb_otp'),
        child: Text('Continue to Sports Details'),
      ),
    );
  }
