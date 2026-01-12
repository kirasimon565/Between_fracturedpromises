import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes.dart';
import '../../theme/colors.dart';
import '../../services/state_service.dart';

class DialpadScreen extends StatefulWidget {
  @override
  _DialpadScreenState createState() => _DialpadScreenState();
}

class _DialpadScreenState extends State<DialpadScreen> {
  String _input = "";
  final StateService _stateService = Get.find<StateService>();

  void _onKeyPress(String key) {
    if (_input.length < 10) {
      setState(() => _input += key);
      _checkCode();
    }
  }

  void _checkCode() {
    // Your secret access code
    if (_input == "*#77*#") {
      _stateService.unlockAdmin();
      Get.offNamed(AppRoutes.adminDashboard);
    } else if (_input.length >= 8) {
      setState(() => _input = ""); // Auto-reset on wrong long code
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Pure black for the terminal feel
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Text("SYSTEM AUTHENTICATION", 
                style: TextStyle(color: Colors.white24, letterSpacing: 4, fontSize: 10)),
            ),
            Expanded(
              child: Center(
                child: Text(
                  _input,
                  style: const TextStyle(color: Colors.white, fontSize: 36, letterSpacing: 8, fontWeight: FontWeight.w300),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 25,
                  crossAxisSpacing: 25,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final String key = _getKey(index);
                  return GestureDetector(
                    onTap: () => _onKeyPress(key),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white10),
                        color: Colors.white.withOpacity(0.03),
                      ),
                      child: Center(
                        child: Text(key, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w200)),
                      ),
                    ),
                  );
                },
              ),
            ),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("CANCEL", style: TextStyle(color: Colors.white24, fontSize: 12)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _getKey(int index) {
    if (index < 9) return "${index + 1}";
    if (index == 9) return "*";
    if (index == 10) return "0";
    return "#";
  }
}
