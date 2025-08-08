import 'package:flutter/material.dart';

class StepCredentials extends StatelessWidget {
  final TextEditingController userC;
  final TextEditingController passC;
  final String? Function(String?)? userValidator;
  final String? Function(String?)? passValidator;
  const StepCredentials({
    super.key,
    required this.userC,
    required this.passC,
    this.userValidator,
    this.passValidator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: userC,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: const InputDecoration(
            labelText: 'Username',
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(),
          ),
          validator: userValidator,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: passC,
          obscureText: true,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: const InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock_outline),
            border: OutlineInputBorder(),
          ),
          validator: passValidator,
        ),
      ],
    );
  }
}
