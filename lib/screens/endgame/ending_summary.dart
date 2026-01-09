import 'package:flutter/material.dart';
import '../../models/ending.dart';

class EndingSummary extends StatelessWidget {
  final Ending ending;

  const EndingSummary({Key? key, required this.ending}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(ending.title, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Text(ending.description, textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
