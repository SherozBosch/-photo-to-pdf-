// Configure title, layout, and quality, then generate, save, and share PDF.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/pdf_export.dart';
import '../providers/history_provider.dart';
import '../providers/image_batch_provider.dart';
import '../providers/pdf_settings_provider.dart';
import '../services/file_service.dart';
import '../services/pdf_generator_service.dart';
import '../utils/constants.dart';
import '../utils/extensions.dart';
import '../widgets/loading_overlay.dart';

class PdfSettingsScreen extends StatefulWidget {
  const PdfSettingsScreen({super.key});

  @override
  State<PdfSettingsScreen> createState() => _PdfSettingsScreenState();
}

class _PdfSettingsScreenState extends State<PdfSettingsScreen> {
  late final TextEditingController _titleController;
  bool _generating = false;

  @override
  void initState() {
    super.initState();
    final settings = context.read<PdfSettingsProvider>();
    _titleController = TextEditingController(text: settings.title);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final batch = context.read<ImageBatchProvider>();
    final settings = context.read<PdfSettingsProvider>();
    final history = context.read<HistoryProvider>();

    final title = _titleController.text.trim().isEmpty
        ? 'My Document'
        : _titleController.text.trim();
    settings.setTitle(title);

    setState(() => _generating = true);
    try {
      // Build the PDF off the UI thread.
      final bytes = await PdfGeneratorService.generate(
        images: batch.images,
        layout: settings.layout,
        quality: settings.quality,
        title: title,
      );

      // Persist to disk.
      final saved = await FileService.savePdf(bytes, title);

      // Record in history.
      final export = PdfExport(
        id: const Uuid().v4(),
        title: title,
        fileName: saved.file.path.split('/').last,
        filePath: saved.file.path,
        imageCount: batch.count,
        fileSizeBytes: saved.sizeBytes,
        createdAt: DateTime.now(),
      );
      await history.add(export);

      if (!mounted) return;
      setState(() => _generating = false);
      _showSuccessSheet(export);
    } catch (e) {
      if (!mounted) return;
      setState(() => _generating = false);
      context.showSnack('Failed to generate PDF: $e', isError: true);
    }
  }

  void _showSuccessSheet(PdfExport export) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle,
                size: 64, color: Theme.of(ctx).colorScheme.primary),
            const SizedBox(height: 16),
            Text('PDF created!',
                style: Theme.of(ctx).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              '${export.title}.pdf · ${export.fileSizeBytes.readableFileSize}',
              style: Theme.of(ctx).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                FileService.sharePdf(export.filePath, title: export.title);
              },
              icon: const Icon(Icons.share),
              label: const Text('Share / Save to Downloads'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(ctx); // close sheet
                // Clear the batch and return to the create screen.
                context.read<ImageBatchProvider>().clear();
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<PdfSettingsProvider>();
    final batch = context.watch<ImageBatchProvider>();

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: const Text('PDF Settings')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Document title',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Scanned Receipts',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 24),
              Text('Photos per page',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: GridLayout.values.map((layout) {
                  final selected = settings.layout == layout;
                  return ChoiceChip(
                    label: Text(layout.label),
                    selected: selected,
                    onSelected: (_) => settings.setLayout(layout),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text('Quality',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: PdfQuality.values.map((quality) {
                  final selected = settings.quality == quality;
                  return ChoiceChip(
                    label: Text(quality.label),
                    selected: selected,
                    onSelected: (_) => settings.setQuality(quality),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${batch.count} photos will be placed '
                          '${settings.layout.perPage} per page.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _generating ? null : _generate,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text(AppStrings.generatePdf),
              ),
            ],
          ),
        ),
        if (_generating)
          const LoadingOverlay(message: AppStrings.generating),
      ],
    );
  }
}
