import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/models/repo_models.dart';
import '../tree/tree_model.dart';
import '../tree/tree_painter.dart';
import '../ui/live_parts.dart';
import '../ui/theme.dart';
import '../ui/widgets/brand.dart';
import '../ui/widgets/repo_crumb.dart';
import 'plate_pdf.dart';

/// "Print as a herbarium plate": a live preview of the sheet and the
/// paper, ink and label options.
class PrintScreen extends StatefulWidget {
  const PrintScreen({super.key, required this.snapshot});

  final RepoSnapshot snapshot;

  @override
  State<PrintScreen> createState() => _PrintScreenState();
}

class _PrintScreenState extends State<PrintScreen> {
  late final TreeModel _model = TreeModelBuilder().build(widget.snapshot);
  final DateTime _collected = DateTime.now();

  PlateOptions _options = const PlateOptions();
  Timer? _debounce;
  int _gen = 0;
  bool _building = true;
  bool _failed = false;
  Uint8List? _pdf;
  Uint8List? _preview;
  Future<Uint8List>? _pending;

  RepoSnapshot get _snap => widget.snapshot;

  @override
  void initState() {
    super.initState();
    _rebuild();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _set(PlateOptions o) {
    if (o == _options) return;
    setState(() {
      _options = o;
      _building = true;
    });
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _rebuild);
  }

  Future<Uint8List> _bytes() => buildPlatePdf(
    _snap,
    _model,
    _options,
    collected: _collected,
  );

  Future<void> _rebuild() async {
    final gen = ++_gen;
    final future = _bytes();
    _pending = future;
    try {
      final bytes = await future;
      if (!mounted || gen != _gen) return;
      setState(() {
        _pdf = bytes;
        _failed = false;
      });
      Uint8List? png;
      try {
        await for (final page in Printing.raster(
          bytes,
          pages: const [0],
          dpi: 100,
        )) {
          png = await page.toPng();
          break;
        }
      } catch (_) {
        // No rasteriser on this platform: the sheet keeps its placeholder.
      }
      if (!mounted || gen != _gen) return;
      setState(() {
        _preview = png ?? _preview;
        _building = false;
      });
    } catch (_) {
      if (!mounted || gen != _gen) return;
      setState(() {
        _failed = true;
        _building = false;
      });
    }
  }

  Future<Uint8List> _currentPdf() async => _pdf ?? await (_pending ?? _bytes());

  String get _fileName => plateFileName(_snap, _options.paper);

  Future<void> _print() async {
    final bytes = await _currentPdf();
    try {
      await Printing.layoutPdf(
        onLayout: (_) => bytes,
        name: _fileName,
        format: formatFor(_options.paper),
      );
    } catch (e) {
      _toast('Printing is not available here: $e');
    }
  }

  Future<void> _export() async {
    final bytes = await _currentPdf();
    final name = _fileName;
    if (Platform.isAndroid || Platform.isIOS) {
      await Printing.sharePdf(bytes: bytes, filename: name);
      return;
    }
    try {
      Directory? dir;
      try {
        dir = await getDownloadsDirectory();
      } catch (_) {}
      dir ??= await getApplicationDocumentsDirectory();
      final file = File('${dir.path}${Platform.pathSeparator}$name');
      await file.writeAsBytes(bytes, flush: true);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Saved $name to Downloads'),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () => launchUrl(Uri.file(file.path)),
          ),
        ),
      );
    } catch (_) {
      try {
        await Printing.sharePdf(bytes: bytes, filename: name);
      } catch (e) {
        _toast('Could not save the PDF: $e');
      }
    }
  }

  void _toast(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(text)));
  }

  // ------------------------------------------------------------- layout

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) => Scaffold(
        body: c.maxWidth >= 700 ? _wide(context) : _phone(context),
      ),
    );
  }

  Widget _wide(BuildContext context) {
    final t = context.tokens;
    return Column(
      children: [
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: t.surface,
            border: Border(bottom: BorderSide(color: t.line)),
          ),
          child: Row(
            children: [
              const Brand(),
              const SizedBox(width: 16),
              Flexible(child: RepoCrumb(owner: _snap.owner, repo: _snap.name)),
              const Spacer(),
              LiveTabs(
                printActive: true,
                onLive: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: ColoredBox(
                  color: t.line2,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(child: _sheet(t)),
                  ),
                ),
              ),
              Container(
                width: 336,
                decoration: BoxDecoration(
                  color: t.surface,
                  border: Border(left: BorderSide(color: t.line)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(child: _options_(t)),
                    ),
                    const SizedBox(height: 16),
                    _actions(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _phone(BuildContext context) {
    final t = context.tokens;
    return SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                  Expanded(
                    child: Center(
                      child: RepoCrumb(
                        owner: _snap.owner,
                        repo: _snap.name,
                        leadingSlash: false,
                        center: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ColoredBox(
                  color: t.line2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 420),
                        child: _sheet(t),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _options_(t),
                const SizedBox(height: 24),
                _actions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The paper with its preview, in the paper's aspect ratio.
  Widget _sheet(GitarborTokens t) {
    final f = formatFor(_options.paper);
    final shadow = BoxShadow(
      color: t.shadow,
      offset: const Offset(0, 20),
      blurRadius: 40,
      spreadRadius: -20,
    );
    return AspectRatio(
      aspectRatio: f.width / f.height,
      child: Semantics(
        label: 'Preview of the herbarium plate',
        image: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFFBFAF3),
            boxShadow: [shadow],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_preview != null)
                Opacity(
                  opacity: _building ? .55 : 1,
                  child: Image.memory(
                    _preview!,
                    fit: BoxFit.fill,
                    gaplessPlayback: true,
                  ),
                ),
              if (_building)
                const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                ),
              if (_failed && !_building)
                const Center(
                  child: Text(
                    'Could not build the plate',
                    style: TextStyle(color: Color(0xFF2A2521)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _group(GitarborTokens t, String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label.toUpperCase(), style: TextStyles.label(t)),
      const SizedBox(height: 8),
      child,
    ],
  );

  Widget _options_(GitarborTokens t) {
    final o = _options;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Print settings',
          style: TextStyle(fontFamily: Fonts.display, fontSize: 22),
        ),
        const SizedBox(height: 24),
        _group(
          t,
          'Paper',
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (p, label) in const [
                (PaperSize.a3, 'A3'),
                (PaperSize.a4, 'A4'),
                (PaperSize.letter, 'Letter'),
              ])
                _Chip(
                  label: label,
                  selected: o.paper == p,
                  onTap: () => _set(o.copyWith(paper: p)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _group(
          t,
          'Ink',
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (i, label) in const [
                (TreeInk.color, 'Full colour'),
                (TreeInk.ink, 'Botanical ink'),
                (TreeInk.line, 'Line only'),
              ])
                _Chip(
                  label: label,
                  selected: o.ink == i,
                  onTap: () => _set(o.copyWith(ink: i)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _group(
          t,
          'Branch names',
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(
                label: 'Numbered key',
                selected: o.numbered,
                onTap: () => _set(o.copyWith(numbered: true)),
              ),
              _Chip(
                label: 'Tags on limbs',
                selected: !o.numbered,
                onTap: () => _set(o.copyWith(numbered: false)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _group(
          t,
          'Include',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final s in const [
                'Specimen label',
                'Leaf-age legend',
                'Branch key',
              ])
                _Check(s),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actions() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      FilledButton(onPressed: _export, child: const Text('Export PDF')),
      const SizedBox(height: 8),
      OutlinedButton.icon(
        onPressed: _print,
        icon: const Icon(Icons.print_outlined, size: 18),
        label: const Text('Print'),
      ),
    ],
  );
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? t.ctaSoft : t.surface,
        shape: StadiumBorder(
          side: BorderSide(color: selected ? t.ctaLine : t.line),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: selected ? t.ink : t.ink2,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A static tick, as in the design; the plate always includes these.
class _Check extends StatelessWidget {
  const _Check(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: t.cta,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(Icons.check, size: 13, color: t.onCta),
          ),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(fontSize: 14, color: t.ink)),
        ],
      ),
    );
  }
}
