import 'package:flutter/material.dart';

class BranchLabel extends StatelessWidget{

  final String name;
  BranchLabel({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical : 4, horizontal : 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius : BorderRadius.circular(2),
      ),
      child: Text(
        name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }

}