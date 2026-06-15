import 'package:flutter/material.dart';
import 'branch_label.dart';

class ContributorNode extends StatelessWidget {
  final String login;
  final String? avatarUrl;

  const ContributorNode({super.key, required this.login, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey[300],
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
          child: avatarUrl == null ? Text(login[0].toUpperCase()) : null,
        ),
        const SizedBox(height: 8),
        BranchLabel(name: login),
      ],
    );
  }
}