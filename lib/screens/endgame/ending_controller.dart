import 'package:get/get.dart';
import '../../models/ending.dart';

class EndingController extends GetxController {
  // Logic to determine ending based on choices would go here
  final ending = Ending(
    id: 'e1',
    type: EndingType.fractured,
    title: "Fractured",
    description: "You chose to stay, but the trust is gone.",
    imagePath: 'assets/gallery/ending_fractured.png'
  ).obs;
}
