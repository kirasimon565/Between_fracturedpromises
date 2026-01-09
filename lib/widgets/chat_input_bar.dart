import 'package:flutter/material.dart';

class ChatInputBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(child: TextField(decoration: InputDecoration(hintText: "Type a message..."))),
          IconButton(icon: Icon(Icons.send), onPressed: () {}),
        ],
      ),
    );
  }
}
