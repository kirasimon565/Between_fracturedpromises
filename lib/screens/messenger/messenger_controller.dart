import 'package:get/get.dart';
import '../../services/story_engine.dart';
import '../../services/audio_service.dart';
import '../../models/message.dart';

class MessengerController extends GetxController {
  final StoryEngine _engine = Get.find<StoryEngine>();
  final AudioService _audio = Get.find<AudioService>();

  // 🛠️ Search/Filter logic for the list screen
  var searchQuery = "".obs;

  // 🛠️ Tracking the currently active chat thread
  var activeThreadId = "".obs;

  @override
  void onInit() {
    super.onInit();
    // Monitor typing states globally if needed for notifications
  }

  // 🛠️ Filtered threads based on search input
  List<String> get filteredThreads {
    if (searchQuery.value.isEmpty) {
      return _engine.activeThreadIds.toList();
    }
    return _engine.activeThreadIds
        .where((id) => id.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  // 🛠️ Logic to handle entering a chat
  void enterChat(String threadId) {
    activeThreadId.value = threadId;
    _audio.playPing(); // Professional feedback on navigation
    
    // In a full implementation, you'd call an engine method here 
    // to mark all messages in this thread as 'read' in Firestore.
  }

  // 🛠️ Logic to handle exiting a chat
  void leaveChat() {
    activeThreadId.value = "";
  }

  // 🛠️ Feature: Check if a thread has a pending choice
  // This can be used to show a "!" badge on the list screen
  bool hasPendingChoice(String threadId) {
    // Logic to check if the last message in a thread requires a user choice
    return false; // Placeholder for future logic
  }
}
