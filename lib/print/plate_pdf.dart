import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/models/repo_models.dart';
import '../tree/tree_model.dart';
import '../tree/tree_painter.dart';
import 'plate_render.dart';

enum PaperSize { a3, a4, letter }

class PlateOptions {
  const PlateOptions({
    this.paper = PaperSize.a3,
    this.ink = TreeInk.ink,
    this.numbered = true,
  });

  final PaperSize paper;
  final TreeInk ink;

  /// Numbered key under the tree, or full tags on the limbs.
  final bool numbered;

  PlateOptions copyWith({PaperSize? paper, TreeInk? ink, bool? numbered}) =>
      PlateOptions(
        paper: paper ?? this.paper,
        ink: ink ?? this.ink,
        numbered: numbered ?? this.numbered,
      );

  @override
  bool operator ==(Object other) =>
      other is PlateOptions &&
      other.paper == paper &&
      other.ink == ink &&
      other.numbered == numbered;

  @override
  int get hashCode => Object.hash(paper, ink, numbered);
}

/// Portrait page size for [p].
PdfPageFormat formatFor(PaperSize p) => switch (p) {
  PaperSize.a3 => PdfPageFormat.a3,
  PaperSize.a4 => PdfPageFormat.a4,
  PaperSize.letter => PdfPageFormat.letter,
};

/// "gitarbor-owner-repo-a3.pdf"
String plateFileName(RepoSnapshot s, PaperSize p) =>
    'gitarbor-${s.owner}-${s.name}-${p.name}.pdf'.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9._-]+'),
      '-',
    );

/// One line of the numbered key.
class KeyEntry {
  const KeyEntry({
    required this.number,
    required this.name,
    required this.author,
    required this.commits,
    required this.status,
  });

  final int number;
  final String name;
  final String? author;
  final int commits;
  final BranchStatus status;
}

/// The key lists branches in the same order as the numbers drawn on limbs.
List<KeyEntry> plateKey(TreeModel m) {
  final limbs = m.limbs.where((l) => l.isBranch).toList()
    ..sort((a, b) => a.number.compareTo(b.number));
  return [
    for (final l in limbs)
      KeyEntry(
        number: l.number,
        name: l.name,
        author: l.branch?.author,
        commits: l.branch?.commitCount ?? 0,
        status: l.branch?.status ?? BranchStatus.active,
      ),
  ];
}

/// Plate number shown in the kicker, from the repo seed.
String plateNumber(RepoSnapshot s) =>
    (seedFor(s.fullName) % 1000).toString().padLeft(3, '0');

const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String _long(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';
String _short(DateTime d) =>
    '${d.day} ${_months[d.month - 1].substring(0, 3)} ${d.year}';

String _num(int n) {
  final s = n.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}

String _plural(int n, String one, [String? many]) =>
    '${_num(n)} ${n == 1 ? one : (many ?? '${one}s')}';

const _paper = PdfColor.fromInt(0xFFFBFAF3);
const _ink = PdfColor.fromInt(0xFF2A2521);

PdfColor _fade(double opacity) => PdfColor(
  _paper.red + (_ink.red - _paper.red) * opacity,
  _paper.green + (_ink.green - _paper.green) * opacity,
  _paper.blue + (_ink.blue - _paper.blue) * opacity,
);

String _statusWord(BranchStatus s) => s.name;

/// Lays the tree out as a pressed-specimen plate and returns the PDF bytes.
Future<Uint8List> buildPlatePdf(
  RepoSnapshot snapshot,
  TreeModel model,
  PlateOptions o, {
  DateTime? collected,
}) async {
  final when = collected ?? DateTime.now();
  final fmt = formatFor(o.paper);
  final w = fmt.width, h = fmt.height;
  final u = w / 100; // the design's 1cqw
  final m = w * .055;
  final cw = w - 2 * m;

  final display = pw.Font.ttf(
    await rootBundle.load('assets/fonts/YoungSerif-Regular.ttf'),
  );
  final ui = pw.Font.ttf(
    await rootBundle.load('assets/fonts/BricolageGrotesque-Regular.ttf'),
  );
  final mono = pw.Font.ttf(
    await rootBundle.load('assets/fonts/IBMPlexMono-Regular.ttf'),
  );
  final monoMed = pw.Font.ttf(
    await rootBundle.load('assets/fonts/IBMPlexMono-Medium.ttf'),
  );

  final key = o.numbered ? plateKey(model) : const <KeyEntry>[];
  final rows = (key.length / 2).ceil();
  // Shrink the key so up to 40 branches fit.
  final k = rows == 0 ? 1.0 : math.min(1.0, (40 * u) / (rows * 4.3 * u));
  final ks = math.max(k, .42);

  // Estimate the tree's area so it is rendered at about the right shape.
  final headH = 15 * u;
  final sideH = 27 * u;
  final footH = math.max(rows * 4.3 * u * ks, sideH) + 4 * u;
  final areaH = math.max(h - 2 * m - headH - footH - 5 * u, 20 * u);
  const dpi = 200 / 72;
  final pxW = math.min((cw * dpi).round(), 4200);
  final pxH = math.min((areaH * dpi).round(), 4200);
  final tree = await renderPlateTree(
    model,
    widthPx: pxW,
    heightPx: pxH,
    ink: o.ink,
    labels: o.numbered ? TreeLabels.numbered : TreeLabels.full,
  );

  pw.TextStyle ts(
    pw.Font f,
    double size, {
    PdfColor color = _ink,
    double? spacing,
  }) => pw.TextStyle(
    font: f,
    fontSize: size,
    color: color,
    letterSpacing: spacing,
    lineSpacing: 0,
  );

  // -------------------------------------------------------------- header
  final repo = snapshot.name;
  final title = repo.isEmpty ? repo : repo[0].toUpperCase() + repo.substring(1);
  final scaleW = 16 * u;
  final titleMax = cw - scaleW - 3 * u;
  final titleSize = math.min(6 * u, titleMax / (math.max(title.length, 1) * .6));
  final trunkN = snapshot.trunkCommits.length;

  pw.Widget scaleBar() => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.end,
    mainAxisSize: pw.MainAxisSize.min,
    children: [
      pw.Container(
        width: 14 * u,
        height: 1.2 * u,
        decoration: pw.BoxDecoration(
          border: pw.Border(
            left: pw.BorderSide(color: _ink, width: .15 * u),
            right: pw.BorderSide(color: _ink, width: .15 * u),
            bottom: pw.BorderSide(color: _ink, width: .15 * u),
          ),
        ),
        child: pw.Row(
          children: [
            for (var i = 0; i < 4; i++)
              pw.Expanded(
                child: pw.Container(color: i.isEven ? _ink : null),
              ),
          ],
        ),
      ),
      pw.SizedBox(height: .8 * u),
      pw.Text(
        'trunk height = ${_plural(trunkN, 'commit')}',
        style: ts(mono, 1.35 * u, color: _fade(.85)),
      ),
    ],
  );

  final header = pw.Container(
    padding: pw.EdgeInsets.only(bottom: 2 * u),
    decoration: pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: _ink, width: .15 * u)),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'GITARBOR HERBARIUM · PLATE ${plateNumber(snapshot)}',
                style: ts(mono, 1.35 * u, color: _fade(.7), spacing: .13 * u),
              ),
              pw.SizedBox(height: 1 * u),
              pw.Text(title, style: ts(display, titleSize)),
              pw.SizedBox(height: 1 * u),
              pw.Text(
                '${snapshot.fullName} · branch structure as of ${_long(when)}',
                style: ts(mono, 1.5 * u, color: _fade(.8)),
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 3 * u),
        scaleBar(),
      ],
    ),
  );

  // ----------------------------------------------------------------- key
  pw.Widget keyRow(KeyEntry e) {
    final nameW = (cw * 1.25 / 2.25 - 1.5 * u) / 2 - 3.4 * u * ks;
    final fs = 1.5 * u * ks;
    final maxChars = math.max(6, (nameW / (fs * .6)).floor());
    final name = e.name.length > maxChars
        ? '${e.name.substring(0, maxChars - 1)}…'
        : e.name;
    final who = e.author == null ? '' : '${e.author} · ';
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: .8 * u * ks),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 2.4 * u * ks,
            height: 2.4 * u * ks,
            alignment: pw.Alignment.center,
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              border: pw.Border.all(color: _ink, width: .12 * u),
            ),
            child: pw.Text('${e.number}', style: ts(mono, 1.25 * u * ks)),
          ),
          pw.SizedBox(width: 1 * u * ks),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(name, style: ts(monoMed, fs)),
                pw.Text(
                  '$who${_plural(e.commits, 'commit')} · ${_statusWord(e.status)}',
                  style: ts(ui, 1.3 * u * ks, color: _fade(.75)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget keyColumns() {
    final left = key.take(rows).toList();
    final right = key.skip(rows).toList();
    pw.Widget col(List<KeyEntry> es) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [for (final e in es) keyRow(e)],
    );
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(child: col(left)),
        pw.SizedBox(width: 3 * u),
        pw.Expanded(child: col(right)),
      ],
    );
  }

  // -------------------------------------------------------------- legend
  final colored = o.ink != TreeInk.line;
  pw.Widget legend() => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Container(
        height: 1 * u,
        decoration: pw.BoxDecoration(
          borderRadius: pw.BorderRadius.circular(1 * u),
          gradient: pw.LinearGradient(
            colors: colored
                ? const [
                    PdfColor.fromInt(0xFF9BC23E),
                    PdfColor.fromInt(0xFF3D7A51),
                    PdfColor.fromInt(0xFFD6932B),
                    PdfColor.fromInt(0xFFB3502F),
                  ]
                : const [PdfColor.fromInt(0xFFFFFFFF), _ink],
            stops: colored ? const [0, .3, .66, 1] : null,
          ),
        ),
      ),
      pw.SizedBox(height: .8 * u),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          for (final s in const ['today', '4 months', '1 year+'])
            pw.Text(s, style: ts(mono, 1.35 * u, color: _fade(.75))),
        ],
      ),
      pw.SizedBox(height: .8 * u),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          _icon(u, _Icon.flower),
          pw.SizedBox(width: .5 * u),
          pw.Text('merged', style: ts(ui, 1.35 * u)),
          pw.SizedBox(width: 1.4 * u),
          _icon(u, _Icon.droop),
          pw.SizedBox(width: .5 * u),
          pw.Text('drooping limb: stale', style: ts(ui, 1.35 * u)),
        ],
      ),
      pw.SizedBox(height: .5 * u),
      pw.Row(
        children: [
          _icon(u, _Icon.stub),
          pw.SizedBox(width: .5 * u),
          pw.Text('cut stub: closed unmerged', style: ts(ui, 1.35 * u)),
        ],
      ),
    ],
  );

  // ------------------------------------------------------------ specimen
  final active = snapshot.countOf(BranchStatus.active);
  final merged = snapshot.countOf(BranchStatus.merged);
  final stale = snapshot.countOf(BranchStatus.stale);
  final pruned = snapshot.countOf(BranchStatus.pruned);
  final rowsData = <(String, String)>[
    ('Repository', snapshot.fullName),
    ('Trunk', '${snapshot.defaultBranch} · ${_plural(trunkN, 'commit')}'),
    (
      'Branches',
      '${snapshot.branches.length} ($active active, $merged merged, '
          '$stale stale, $pruned pruned)',
    ),
    (
      'Commits',
      '${_num(snapshot.totalCommits)} by ${_plural(snapshot.authors.length, 'author')}',
    ),
    ('Collected', '${_short(when)}, Gitarbor'),
  ];
  pw.Widget label() => pw.Container(
    padding: pw.EdgeInsets.symmetric(horizontal: 2 * u, vertical: 1.6 * u),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: _ink, width: .15 * u),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          padding: pw.EdgeInsets.only(bottom: .8 * u),
          margin: pw.EdgeInsets.only(bottom: .8 * u),
          decoration: pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: _ink, width: .1 * u),
            ),
          ),
          child: pw.Text('Specimen', style: ts(display, 2.2 * u)),
        ),
        for (final (a, b) in rowsData)
          pw.Padding(
            padding: pw.EdgeInsets.only(bottom: .5 * u),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                  width: 9.5 * u,
                  child: pw.Text(a, style: ts(mono, 1.3 * u, color: _fade(.7))),
                ),
                pw.Expanded(child: pw.Text(b, style: ts(ui, 1.4 * u))),
              ],
            ),
          ),
      ],
    ),
  );

  final footer = pw.Container(
    padding: pw.EdgeInsets.only(top: 2 * u),
    decoration: pw.BoxDecoration(
      border: pw.Border(top: pw.BorderSide(color: _ink, width: .15 * u)),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 125,
          child: o.numbered ? keyColumns() : legend(),
        ),
        pw.SizedBox(width: 3 * u),
        pw.Expanded(
          flex: 100,
          child: o.numbered
              ? pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [legend(), pw.SizedBox(height: 2 * u), label()],
                )
              : label(),
        ),
      ],
    ),
  );

  final doc = pw.Document(
    title: 'Gitarbor plate: ${snapshot.fullName}',
    author: 'Gitarbor',
    creator: 'Gitarbor',
  );
  doc.addPage(
    pw.Page(
      pageTheme: pw.PageTheme(
        pageFormat: fmt,
        margin: pw.EdgeInsets.zero,
        buildBackground: (_) => pw.FullPage(
          ignoreMargins: true,
          child: pw.Container(color: _paper),
        ),
      ),
      build: (_) => pw.Padding(
        padding: pw.EdgeInsets.all(m),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            header,
            pw.SizedBox(height: 1.5 * u),
            pw.Expanded(
              child: pw.Center(
                child: pw.Image(
                  pw.MemoryImage(tree),
                  fit: pw.BoxFit.contain,
                ),
              ),
            ),
            pw.SizedBox(height: 1.5 * u),
            footer,
          ],
        ),
      ),
    ),
  );
  return doc.save();
}

enum _Icon { flower, droop, stub }

pw.Widget _icon(double u, _Icon kind) {
  final s = 2 * u;
  return pw.SizedBox(
    width: s,
    height: s,
    child: pw.CustomPaint(
      painter: (canvas, size) {
        final c = size.x / 2;
        canvas
          ..setStrokeColor(_ink)
          ..setFillColor(_ink)
          ..setLineWidth(.14 * u);
        switch (kind) {
          case _Icon.flower:
            for (var i = 0; i < 5; i++) {
              final a = i * math.pi * 2 / 5;
              canvas.drawEllipse(
                c + math.cos(a) * s * .24,
                c + math.sin(a) * s * .24,
                s * .15,
                s * .15,
              );
              canvas.strokePath();
            }
            canvas.drawEllipse(c, c, s * .09, s * .09);
            canvas.fillPath();
          case _Icon.droop:
            canvas
              ..moveTo(s * .1, s * .6)
              ..curveTo(s * .4, s * .95, s * .75, s * .85, s * .9, s * .3)
              ..strokePath();
          case _Icon.stub:
            canvas
              ..moveTo(s * .2, s * .15)
              ..lineTo(s * .8, s * .15)
              ..strokePath();
            canvas.drawEllipse(c, s * .5, s * .22, s * .22);
            canvas.strokePath();
            canvas.drawEllipse(c, s * .5, s * .08, s * .08);
            canvas.fillPath();
        }
      },
    ),
  );
}
