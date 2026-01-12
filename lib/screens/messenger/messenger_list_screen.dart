import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/constants.dart';
import '../../services/story_engine.dart';
import '../../theme/colors.dart';

class MessengerListScreen extends StatefulWidget {
  @override
  _MessengerListScreenState createState() => _MessengerListScreenState();
}

class _MessengerListScreenState extends State<MessengerListScreen> {
  final StoryEngine _engine = Get.find<StoryEngine>();

  @override
  void initState() {
    super.initState();
    if (_engine.currentEpisode.value == null) {
      _engine.loadEpisode('episode_1');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.messengerBackground,
      appBar: AppBar(
        title: const Text("MESSAGES", style: TextStyle(letterSpacing: 2, fontSize: 14)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        if (_engine.currentEpisode.value == null) {
          return const Center(child: CircularProgressIndicator(color: Colors.white24));
        }

        final threads = _engine.activeThreads.where((t) => t.id.toLowerCase() != 'daniel').toList();

        return ListView.builder(
          itemCount: threads.length,
          itemBuilder: (context, index) {
            final thread = threads[index];
            final lastMsg = thread.messages.last;
            final name = thread.id[0].toUpperCase() + thread.id.substring(1);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: Colors.white.withOpacity(0.03),
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white10,
                  backgroundImage: AssetImage(AppConstants.getAvatarPath(name)),
                ),
                title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                subtitle: Text(
                  lastMsg.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                ),
                trailing: Text("NOW", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10)),
                onTap: () => Get.toNamed('/messenger/chat', arguments: name),
              ),
            );
          },
        );
      }),
    );
  }
}
