import 'package:flutter_test/flutter_test.dart';
import 'package:gitarbor/data/repo_link.dart';

void main() {
  group('accepts', () {
    const cases = <String>[
      'example/lantern',
      '  example/lantern  ',
      'example/lantern/',
      'example/lantern.git',
      'https://github.com/example/lantern',
      'https://github.com/example/lantern/',
      'https://github.com/example/lantern.git',
      'https://github.com/example/lantern/tree/feature/i18n',
      'https://github.com/example/lantern/issues/12',
      'https://github.com/example/lantern?tab=readme#top',
      'http://github.com/example/lantern',
      'https://www.github.com/example/lantern',
      'HTTPS://GitHub.com/example/lantern',
      'github.com/example/lantern',
      'www.github.com/example/lantern/pulls',
      'git@github.com:example/lantern.git',
      'git@github.com:example/lantern',
      'ssh://git@github.com/example/lantern.git',
    ];
    for (final input in cases) {
      test('"$input"', () {
        expect(parseRepoLink(input), (owner: 'example', repo: 'lantern'));
      });
    }

    test('keeps dots, dashes and underscores in repo names', () {
      expect(parseRepoLink('my-org/some_repo.js'), (
        owner: 'my-org',
        repo: 'some_repo.js',
      ));
    });
  });

  group('rejects', () {
    const cases = <String>[
      '',
      '   ',
      'lantern',
      'example/',
      '/lantern',
      'https://github.com/example',
      'https://github.com/',
      'https://gitlab.com/example/lantern',
      'https://example.com/github.com/example/lantern',
      'git@gitlab.com:example/lantern.git',
      'gitlab.com/example/lantern',
      'example/lantern/tree/main',
      'exa mple/lantern',
      'exa_mple/lantern',
      '-example/lantern',
      'example-/lantern',
      'example/lan!tern',
      'example/..',
      'ex.ample/lantern',
    ];
    for (final input in cases) {
      test('"$input"', () => expect(parseRepoLink(input), isNull));
    }
  });
}
