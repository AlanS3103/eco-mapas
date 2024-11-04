import 'package:flutter/material.dart';

class CustomMapMarker extends StatelessWidget {
  final VoidCallback onTap;

  const CustomMapMarker({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.9),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.recycling,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
