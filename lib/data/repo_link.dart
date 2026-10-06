final _owner = RegExp(r'^[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?$');
final _repo = RegExp(r'^[A-Za-z0-9._-]+$');

final _hostForms = [
  RegExp(r'^git@github\.com:(.+)$', caseSensitive: false),
  RegExp(
    r'^(?:https?|ssh|git)://(?:[^@/]+@)?(?:www\.)?github\.com/(.+)$',
    caseSensitive: false,
  ),
  RegExp(r'^(?:www\.)?github\.com/(.+)$', caseSensitive: false),
];

/// Reads `owner/repo` out of whatever the user pasted: a short name, a web
/// URL, or a git remote. Returns null when it is not a GitHub repository.
({String owner, String repo})? parseRepoLink(String input) {
  final s = input.trim();
  if (s.isEmpty || s.contains(RegExp(r'\s'))) return null;

  String? path;
  var fullForm = false;
  for (final re in _hostForms) {
    path = re.firstMatch(s)?.group(1);
    if (path != null) {
      fullForm = true;
      break;
    }
  }
  path ??= s;

  final parts = path.split(RegExp(r'[?#]')).first.split('/');
  // Subpaths (/tree/main, /issues) only make sense after a host.
  while (parts.isNotEmpty && parts.last.isEmpty) {
    parts.removeLast();
  }
  if (parts.length < 2 || (!fullForm && parts.length != 2)) return null;

  final owner = parts[0];
  var repo = parts[1];
  if (repo.toLowerCase().endsWith('.git')) {
    repo = repo.substring(0, repo.length - 4);
  }
  if (!_owner.hasMatch(owner) || !_repo.hasMatch(repo)) return null;
  if (repo == '.' || repo == '..') return null;
  return (owner: owner, repo: repo);
}
