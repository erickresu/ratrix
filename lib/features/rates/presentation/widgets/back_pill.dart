import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../rates_colors.dart';

class BackPill extends StatelessWidget {
  const BackPill({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.only(left: 6, right: 14, top: 6, bottom: 6),
          decoration: BoxDecoration(
            color: RatesColors.surface,
            border: Border.all(color: RatesColors.borderStrong),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: RatesColors.surfaceSubtle, shape: BoxShape.circle),
                child: const Icon(CupertinoIcons.back, size: 16),
              ),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: RatesColors.textMutedStrong)),
            ],
          ),
        ),
      ),
    );
  }
}
