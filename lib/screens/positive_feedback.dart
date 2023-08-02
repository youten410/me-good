import 'package:flutter/material.dart';

class PositiveFeedback extends StatefulWidget {
  const PositiveFeedback({super.key});

  @override
  State<PositiveFeedback> createState() => _PositiveFeedbackState();
}

class _PositiveFeedbackState extends State<PositiveFeedback> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('feedback'),
      ),
    );
  }
}