import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/github_auth.dart';
import '../state/app_state.dart';
import 'format.dart';
import 'theme.dart';

/// Opens the GitHub sign-in sheet.
Future<void> showConnectGitHubSheet(BuildContext context) {
  final t = context.tokens;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: t.surface,
    constraints: const BoxConstraints(maxWidth: 520),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const ConnectGitHubSheet(),
  );
}

class ConnectGitHubSheet extends ConsumerStatefulWidget {
  const ConnectGitHubSheet({super.key});

  @override
  ConsumerState<ConnectGitHubSheet> createState() => _ConnectGitHubSheetState();
}

class _ConnectGitHubSheetState extends ConsumerState<ConnectGitHubSheet> {
  final _token = TextEditingController();
  DeviceCode? _code;
  bool _starting = false;
  bool _copied = false;
  String? _error;

  @override
  void dispose() {
    _token.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final auth = ref.read(githubAuthProvider);
    final tokens = ref.read(tokenProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    setState(() {
      _starting = true;
      _error = null;
    });
    try {
      final code = await auth.start();
      if (!mounted) return;
      setState(() {
        _code = code;
        _starting = false;
      });
      final token = await auth.poll(code);
      if (!mounted) return;
      await tokens.save(token);
      nav.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Connected to GitHub')),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _code = null;
        _starting = false;
      });
    }
  }

  Future<void> _saveToken() async {
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    await ref.read(tokenProvider.notifier).save(_token.text);
    nav.pop();
    messenger.showSnackBar(
      const SnackBar(content: Text('Connected to GitHub')),
    );
  }

  Future<void> _copy(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (mounted) setState(() => _copied = true);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final signedIn = ref.watch(tokenProvider).value != null;
    final code = _code;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Connect GitHub',
              style: TextStyles.display.copyWith(fontSize: 26, color: t.ink),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to plant private repositories and lift GitHub\'s '
              'hourly rate limit.',
              style: TextStyle(color: t.ink2),
            ),
            const SizedBox(height: 20),
            if (signedIn) ...[
              Row(
                children: [
                  Icon(Icons.check_circle, color: t.moss, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('Connected')),
                  OutlinedButton(
                    onPressed: () => ref.read(tokenProvider.notifier).signOut(),
                    child: const Text('Sign out'),
                  ),
                ],
              ),
            ] else ...[
              if (oauthConfigured && code == null)
                FilledButton(
                  onPressed: _starting ? null : _signIn,
                  child: Text(
                    _starting ? 'Contacting GitHub…' : 'Sign in with GitHub',
                  ),
                ),
              if (code != null) _codeCard(t, code),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: t.rust, fontSize: 13)),
              ],
              const SizedBox(height: 24),
              Text(
                'OR PASTE A PERSONAL ACCESS TOKEN',
                style: TextStyles.label(t),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _token,
                      obscureText: true,
                      autocorrect: false,
                      enableSuggestions: false,
                      style: mono(14, color: t.ink),
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) =>
                          _token.text.trim().isEmpty ? null : _saveToken(),
                      decoration: const InputDecoration(
                        hintText: 'Paste a personal access token instead',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _token.text.trim().isEmpty ? null : _saveToken,
                    child: const Text('Save'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Needs the "repo" scope for private repositories. Stored in '
                'your system keychain.',
                style: TextStyle(color: t.ink3, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _codeCard(GitarborTokens t, DeviceCode code) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.ctaSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.ctaLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('ENTER THIS CODE ON GITHUB', style: TextStyles.label(t)),
          const SizedBox(height: 8),
          Center(
            child: SelectableText(
              code.userCode,
              style: mono(
                32,
                weight: FontWeight.w500,
                color: t.ink,
              ).copyWith(letterSpacing: 4),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => _copy(code.userCode),
                icon: Icon(_copied ? Icons.check : Icons.copy, size: 16),
                label: Text(_copied ? 'Copied' : 'Copy'),
              ),
              FilledButton(
                onPressed: () => launchUrl(
                  Uri.parse(code.verificationUri),
                  mode: LaunchMode.externalApplication,
                ),
                child: const Text('Open github.com/login/device'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              Text(
                'Waiting for you to approve…',
                style: TextStyle(color: t.ink2, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
