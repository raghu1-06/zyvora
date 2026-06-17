import 'package:flutter/material.dart';

class ZeniBottomSheet extends StatelessWidget {
  const ZeniBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: const Center(child: Text("Zeni Assistant Sheet")),
    );
  }
}
