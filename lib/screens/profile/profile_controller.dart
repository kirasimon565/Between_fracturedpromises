import 'package:get/get.dart';

class ProfileController extends GetxController {
  var name = "Nadia".obs;
  var bio = "Just looking for a spark...".obs;
  var age = 28.obs;
  var isEditing = false.obs;

  void saveProfile(String newName, String newBio) {
    name.value = newName;
    bio.value = newBio;
    isEditing.value = false;
  }
}
