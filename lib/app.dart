import 'package:flutter/material.dart';

class GitarborApp extends StatelessWidget {
  const GitarborApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gitarbor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Bricolage Grotesque',
        scaffoldBackgroundColor: const Color(0xFFEDF1E8),
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'Gitarbor',
            style: TextStyle(
              fontFamily: 'Young Serif',
              fontSize: 44,
              color: Color(0xFF1C2826),
            ),
          ),
        ),
      ),
    );
  }
}
