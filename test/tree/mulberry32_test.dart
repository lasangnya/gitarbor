import 'package:flutter_test/flutter_test.dart';
import 'package:gitarbor/tree/tree_model.dart';

// Expected values come from the design page's JS mulberry32, run in node.
const _expected = <int, List<double>>{
  11: [
    0.5115870486479253,
    0.5299464082345366,
    0.6081185641232878,
    0.5901576359756291,
    0.8507766961120069,
  ],
  99: [
    0.2604658124037087,
    0.8048227655235678,
    0.5408715349622071,
    0.6902434257790446,
    0.001138708321377635,
  ],
  0: [
    0.26642920868471265,
    0.0003297457005828619,
    0.2232720274478197,
    0.1462021479383111,
    0.46732782293111086,
  ],
  4294967295: [
    0.8964226141106337,
    0.189478256739676,
    0.7156526781618595,
    0.9440599093213677,
    0.8452364315744489,
  ],
};

void main() {
  for (final e in _expected.entries) {
    test('matches the JS reference for seed ${e.key}', () {
      final r = Mulberry32(e.key);
      for (final v in e.value) {
        expect(r(), closeTo(v, 1e-15));
      }
    });
  }
}
