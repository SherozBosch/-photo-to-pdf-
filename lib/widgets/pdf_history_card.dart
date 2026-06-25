// Card widget representing one entry in the PDF history list.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/pdf_export.dart';
import '../utils/extensions.dart';

class PdfHistoryCard extends StatelessWidget {
  final PdfExport export;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const PdfHistoryCard({
    super.key,
    required this.export,
    required this.onShare,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dateLabel =
        DateFormat('MMM d, y · h:mm a').format(export.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.picture_as_pdf,
                  color: colors.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    export.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${export.imageCount} photos · '
                    '${export.fileSizeBytes.readableFileSize}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    dateLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: onShare,
              tooltip: 'Share',
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: colors.error),
              onPressed: onDelete,
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}
