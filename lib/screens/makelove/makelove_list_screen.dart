import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/constants.dart';
import '../../services/story_engine.dart';
import '../../theme/colors.dart';
import '../../theme/theme.dart';
import '../../models/message.dart';

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
    _themeService.setSecretMode(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Hard black
      appBar: AppBar(
        title: const Text("MAKELOVE", style: TextStyle(letterSpacing: 8, fontSize: 14, fontWeight: FontWeight.w900, color: Colors.red)),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white38),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final allThreads = _engine.activeThreadIds.toList();
        final threads = allThreads.where((id) => id.toLowerCase() == 'daniel').toList();

        if (threads.isEmpty) {
          return Center(
             child: Text("NO SIGNAL", style: TextStyle(color: Colors.red.withOpacity(0.3), letterSpacing: 4)),
          );
        }

        return ListView.builder(
          itemCount: threads.length,
          itemBuilder: (context, index) {
            final threadId = threads[index];
            final name = threadId.toUpperCase();

            return StreamBuilder<Message?>(
              stream: _engine.getLastMessageStream(threadId),
              builder: (context, snapshot) {
                 final lastMsg = snapshot.data;
                 final content = lastMsg?.content ?? "Waiting...";
                 return _buildMatchTile(name, content);
              }
            );
          },
        );
      }),
    );
  }

  Widget _buildMatchTile(String name, String lastMessage) {
    return GestureDetector(
      onTap: () => Get.toNamed('/makelove/chat', arguments: name),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFF100000),
          border: Border(
            top: BorderSide(color: Colors.red.withOpacity(0.5), width: 1),
            bottom: BorderSide(color: Colors.red.withOpacity(0.5), width: 1),
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.4,
                child: Image.asset(
                  AppConstants.getAvatarPath(name),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          color: Colors.red,
                          child: Text(name, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          lastMessage,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Didot',
                            fontStyle: FontStyle.italic
                          )
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_sharp, color: Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
