import 'dart:convert';
import 'dart:io';

/// A stored response, replayed when GitHub answers `304 Not Modified`.
class CachedResponse {
  const CachedResponse({required this.etag, required this.body, this.link});

  final String etag;
  final String body;

  /// The `Link` header, so paging can continue from a cached page.
  final String? link;
}

abstract class EtagCache {
  Future<CachedResponse?> get(String url);
  Future<void> put(String url, CachedResponse r);
}

class MemoryEtagCache implements EtagCache {
  final _entries = <String, CachedResponse>{};

  @override
  Future<CachedResponse?> get(String url) async => _entries[url];

  @override
  Future<void> put(String url, CachedResponse r) async => _entries[url] = r;
}

/// One JSON file per URL inside [dir], named by an FNV-1a hash of the URL.
class FileEtagCache implements EtagCache {
  FileEtagCache(this.dir);

  final Directory dir;

  File _file(String url) => File('${dir.path}/${_fnv1a(url)}.json');

  @override
  Future<CachedResponse?> get(String url) async {
    try {
      final f = _file(url);
      if (!await f.exists()) return null;
      final json = jsonDecode(await f.readAsString()) as Map<String, dynamic>;
      if (json['url'] != url) return null; // hash collision
      return CachedResponse(
        etag: json['etag'] as String,
        body: json['body'] as String,
        link: json['link'] as String?,
      );
    } on Object {
      return null; // a damaged entry is just a miss
    }
  }

  @override
  Future<void> put(String url, CachedResponse r) async {
    await dir.create(recursive: true);
    await _file(url).writeAsString(
      jsonEncode({'url': url, 'etag': r.etag, 'body': r.body, 'link': r.link}),
    );
  }
}

String _fnv1a(String s) {
  var h = 0x811c9dc5;
  for (final b in utf8.encode(s)) {
    h = ((h ^ b) * 0x01000193) & 0xffffffff;
  }
  return h.toRadixString(16).padLeft(8, '0');
}
