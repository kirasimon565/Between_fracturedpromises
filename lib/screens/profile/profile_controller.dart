import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController extends GetxController {
  // Observable variables
  var name = "Nadia".obs;
  var bio = "Just looking for a spark...".obs;
  var age = 28.obs;
  var isEditing = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProfile(); // Load saved data as soon as the controller starts
  }

  // 🛠️ Load data from persistent storage
  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    name.value = prefs.getString('user_name') ?? "Nadia";
    bio.value = prefs.getString('user_bio') ?? "Just looking for a spark...";
    // Age could also be persisted if needed
  }

  // 🛠️ Updated Save method with Persistence
  Future<void> saveProfile(String newName, String newBio) async {
    name.value = newName;
    bio.value = newBio;
    isEditing.value = false;

    // Save to device storage so it survives app restarts
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', newName);
    await prefs.setString('user_bio', newBio);
    
    // Logic can be added here to trigger a notification to other services
    // if they need to refresh their UI immediately.
  }
}
