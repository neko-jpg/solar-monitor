import 'package:flutter/material.dart';

class StepUrlInput extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  const StepUrlInput({super.key, required this.controller, this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.url,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: const InputDecoration(
        labelText: 'URL',
        hintText: 'https://example.com/plant/123',
        border: OutlineInputBorder(),
      ),
      validator: validator,
    );
  }
}
