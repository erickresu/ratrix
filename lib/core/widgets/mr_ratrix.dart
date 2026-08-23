import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

/// The app's mascot — used contextually at empty states and onboarding
/// moments (not as a persistent floating presence, which would just be
/// noise for daily admin use).
class MrRatrix extends StatelessWidget {
  const MrRatrix({super.key, this.size = 96, this.repeat = true});

  final double size;
  final bool repeat;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset('assets/lottie/mr.ratrix.json', repeat: repeat),
    );
  }
}
