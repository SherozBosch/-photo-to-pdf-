// Generates a single PDF from a list of images, laid out N-per-page.
//
// Heavy work (decoding, rotating, compressing, PDF assembly) runs in a
// background isolate via `compute` so the UI never freezes.

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/image_data.dart';
import '../utils/constants.dart';

/// Serializable payload passed into the isolate.
class _PdfJob {
  final List<_ImageJob> images;
  final int perPage;
  final int jpegQuality;
  final String title;

  _PdfJob({
    required this.images,
    required this.perPage,
    required this.jpegQuality,
    required this.title,
  });
}

class _ImageJob {
  final String path;
  final int rotation;
  _ImageJob(this.path, this.rotation);
}

class PdfGeneratorService {
  /// Build the PDF and return its raw bytes.
  static Future<Uint8List> generate({
    required List<ImageData> images,
    required GridLayout layout,
    required PdfQuality quality,
    required String title,
  }) async {
    final job = _PdfJob(
      images: images
          .map((e) => _ImageJob(e.path, e.rotation))
          .toList(growable: false),
      perPage: layout.perPage,
      jpegQuality: quality.jpegQuality,
      title: title,
    );
    // Run the whole build off the UI thread.
    return compute(_buildPdf, job);
  }
}

/// Top-level isolate entry point. Must be a pure function.
Future<Uint8List> _buildPdf(_PdfJob job) async {
  final doc = pw.Document(title: job.title);

  // Pre-process every image: decode, apply EXIF + user rotation, compress.
  final List<Uint8List> processed = [];
  for (final image in job.images) {
    final bytes = await File(image.path).readAsBytes();
    var decoded = img.decodeImage(bytes);
    if (decoded == null) continue;

    decoded = img.bakeOrientation(decoded); // EXIF orientation
    if (image.rotation != 0) {
      decoded = img.copyRotate(decoded, angle: image.rotation);
    }

    // Downscale very large images to keep the PDF light.
    if (decoded.width > 1600) {
      decoded = img.copyResize(decoded, width: 1600);
    }

    processed.add(
      Uint8List.fromList(img.encodeJpg(decoded, quality: job.jpegQuality)),
    );
  }

  // Chunk images into pages of `perPage` and lay them out in a column.
  for (var i = 0; i < processed.length; i += job.perPage) {
    final pageImages = processed.sublist(
      i,
      (i + job.perPage).clamp(0, processed.length),
    );

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(AppDimensions.pdfPageMargin),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              for (var j = 0; j < pageImages.length; j++) ...[
                pw.Expanded(
                  child: pw.Center(
                    child: pw.Image(
                      pw.MemoryImage(pageImages[j]),
                      fit: pw.BoxFit.contain,
                    ),
                  ),
                ),
                if (j != pageImages.length - 1) pw.SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }

  return doc.save();
}
