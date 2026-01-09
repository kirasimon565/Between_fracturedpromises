import 'package:get/get.dart';
import '../../app/constants.dart';

class GalleryController extends GetxController {
  // Mock data for unlocked images
  final unlockedImages = <String>[
    AppConstants.gallerySecret1,
    AppConstants.gallerySecret2,
  ].obs;
}
