import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/colors.dart';

class IdentityEditSheet extends StatefulWidget {
  final String currentMessengerName;
  final String currentMakeloveAlias;
  final Function(String, String) onSave;

  const IdentityEditSheet({
    Key? key,
    required this.currentMessengerName,
    required this.currentMakeloveAlias,
    required this.onSave,
  }) : super(key: key);

  @override
  _IdentityEditSheetState createState() => _IdentityEditSheetState();
}

class _IdentityEditSheetState extends State<IdentityEditSheet> {
  late TextEditingController _messengerController;
  late TextEditingController _makeloveController;

  @override
  void initState() {
    super.initState();
    _messengerController = TextEditingController(text: widget.currentMessengerName);
    _makeloveController = TextEditingController(text: widget.currentMakeloveAlias);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "EDIT IDENTITY",
            style: TextStyle(
              color: Colors.white,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildField("PUBLIC PERSONA (MESSENGER)", _messengerController, AppColors.messengerPrimary),
          const SizedBox(height: 15),
          _buildField("HIDDEN ALIAS (MAKELOVE)", _makeloveController, AppColors.makelovePrimary),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () {
                widget.onSave(_messengerController.text, _makeloveController.text);
                Get.back();
              },
              child: const Text("SAVE CHANGES", style: TextStyle(letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: accent, fontSize: 10, letterSpacing: 1.5)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          cursorColor: accent,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: accent),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
