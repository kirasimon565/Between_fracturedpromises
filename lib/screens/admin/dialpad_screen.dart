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
    setState(() {
      _input += key;
    });
    _checkCode();
  }

  void _checkCode() {
    if (_input == "*#77*#") {
      _stateService.unlockAdmin();
      Get.offNamed(AppRoutes.adminDashboard);
    } else if (_input.length > 6) {
      // Reset if too long and wrong
      setState(() {
        _input = "";
      });
      Get.snackbar("Error", "Invalid Code", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  _input,
                  style: TextStyle(color: Colors.white, fontSize: 32, letterSpacing: 5),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 40),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  String key;
                  if (index < 9) {
                    key = "${index + 1}";
                  } else if (index == 9) {
                    key = "*";
                  } else if (index == 10) {
                    key = "0";
                  } else {
                    key = "#";
                  }

                  return GestureDetector(
                    onTap: () => _onKeyPress(key),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[900],
                      ),
                      child: Center(
                        child: Text(
                          key,
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
