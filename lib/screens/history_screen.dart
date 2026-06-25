// Displays the history of generated PDFs with share and delete actions.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pdf_export.dart';
import '../providers/history_provider.dart';
import '../services/file_service.dart';
import '../utils/constants.dart';
import '../widgets/empty_state.dart';
import '../widgets/pdf_history_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Load history when the tab first appears.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().load();
    });
  }

  Future<void> _confirmDelete(PdfExport export) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete PDF?'),
        content: Text('"${export.title}" will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<HistoryProvider>().remove(export);
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: history.isLoading
          ? const Center(child: CircularProgressIndicator())
          : history.isEmpty
              ? const EmptyState(
                  icon: Icons.history,
                  title: AppStrings.noHistory,
                  hint: AppStrings.noHistoryHint,
                )
              : RefreshIndicator(
                  onRefresh: history.load,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: history.items.length,
                    itemBuilder: (context, index) {
                      final export = history.items[index];
                      return PdfHistoryCard(
                        export: export,
                        onShare: () => FileService.sharePdf(
                          export.filePath,
                          title: export.title,
                        ),
                        onDelete: () => _confirmDelete(export),
                      );
                    },
                  ),
                ),
    );
  }
}
