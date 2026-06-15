import 'package:flutter/material.dart';
import '../services/repo_repository.dart';
import 'tree_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController(text: 'flutter/flutter');
  bool _isLoading = false;

  void _generateTree() async {
    setState(() => _isLoading = true);

    try {
      String input = _controller.text.trim();

      // Smart Parsing: Handle full URLs by looking for the last two parts
      if (input.contains('github.com/')) {
        input = input.split('github.com/').last;
      }

      final parts = input.split('/');
      if (parts.length < 2) {
        throw Exception("Invalid format. Use owner/repo");
      }

      final owner = parts[parts.length - 2];
      final repo = parts[parts.length - 1];

      final repository = RepoRepository();
      final tree = await repository.getFullTree(owner, repo);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TreeScreen(tree: tree)),
      );
    } catch (e) {
      debugPrint("API ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🌳', style: TextStyle(fontSize: 80)),
              const Text('Rootprint', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'GitHub Repository (owner/repo)',
                  hintText: 'e.g. flutter/flutter',
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _generateTree,
                child: const Text('Generate Tree 🌱'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}