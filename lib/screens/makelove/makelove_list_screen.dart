import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/story_engine.dart';
import '../../theme/colors.dart';
import '../../theme/theme.dart';

class MakeloveListScreen extends StatefulWidget {
  @override
  _MakeloveListScreenState createState() => _MakeloveListScreenState();
}

class _MakeloveListScreenState extends State<MakeloveListScreen> {
  final ThemeService _themeService = Get.find<ThemeService>();
  final StoryEngine _engine = Get.find<StoryEngine>();

  @override
  void initState() {
    super.initState();
    // Force Secret Theme
    _themeService.setSecretMode(true);
  }

  @override
  void dispose() {
    // Revert to Safe Theme on exit
    _themeService.setSecretMode(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Makelove", style: TextStyle(fontFamily: 'Cursive', fontSize: 28)),
        centerTitle: true,
        backgroundColor: AppColors.makeloveBackground,
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildMatchTile("Daniel", "Curiosity killed the cat...", "Now"),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.makeloveBackground,
        selectedItemColor: AppColors.makelovePrimary,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Matches"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: "Chats"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildMatchTile(String name, String lastMessage, String time) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.makelovePrimary.withOpacity(0.3)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: AppColors.makelovePrimary,
          child: Text(name[0], style: TextStyle(color: Colors.white)),
        ),
        title: Text(name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(lastMessage, style: TextStyle(color: Colors.white70)),
        trailing: Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
           Get.toNamed('/makelove/chat', arguments: name);
        },
      ),
    );
  }
}
