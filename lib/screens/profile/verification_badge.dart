import 'package:flutter/material.dart';
import '../../app/constants.dart';

class VerificationBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppConstants.badgeVerified,
      width: 20,
      height: 20,
    );
  }
}
