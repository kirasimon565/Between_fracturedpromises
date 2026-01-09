import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChoiceOverlay extends StatelessWidget {
  final List<String> choices;
  final Function(int) onSelected;

  const ChoiceOverlay({Key? key, required this.choices, required this.onSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: choices.asMap().entries.map((entry) {
          int idx = entry.key;
          String text = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Get.theme.primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () => onSelected(idx),
              child: Text(text, style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          );
        }).toList(),
      ),
    );
  }
}
