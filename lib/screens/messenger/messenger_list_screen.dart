import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/constants.dart';
import '../../models/message.dart';
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
    // In a real app, this might be called elsewhere or checked if already loaded
    if (_engine.currentEpisode.value == null) {
      _engine.loadEpisode('episode_1');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chats"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Obx(() {
        if (_engine.currentEpisode.value == null) {
          return Center(child: CircularProgressIndicator());
        }

        final threads = _engine.activeThreads.where((t) {
          // Filter out secret contacts (Daniel)
          return t.id.toLowerCase() != 'daniel';
        }).toList();

        return ListView.separated(
          itemCount: threads.length,
          separatorBuilder: (c, i) => Divider(height: 1),
          itemBuilder: (context, index) {
            final thread = threads[index];
            final lastMsg = thread.messages.last;
            // Capitalize first letter
            final name = thread.id[0].toUpperCase() + thread.id.substring(1);

            return _buildChatTile(
              name,
              lastMsg.content,
              "Now", // TODO: Real timestamp
              true // TODO: Read status
            );
          },
        );
      }),
    );
  }

  Widget _buildChatTile(String name, String lastMessage, String time, bool unread) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage(AppConstants.getAvatarPath(name)),
        backgroundColor: Colors.grey[300],
        child: Text(name[0]),
      ),
      title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontWeight: unread ? FontWeight.bold : FontWeight.normal),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(time, style: TextStyle(fontSize: 12, color: Colors.grey)),
          if (unread)
            Container(
              margin: EdgeInsets.only(top: 5),
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: AppColors.messengerPrimary, shape: BoxShape.circle),
            )
        ],
      ),
      onTap: () {
        Get.toNamed('/messenger/chat', arguments: name);
      },
    );
  }
}
