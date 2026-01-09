import 'package:flutter/material.dart';

class SecretChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Encrypted Channel"),
        backgroundColor: Colors.grey[900],
      ),
      body: Center(
        child: Text(
          "This conversation is encrypted.",
          style: TextStyle(color: Colors.greenAccent, fontFamily: 'Courier')
        ),
      ),
    );
  }
}
