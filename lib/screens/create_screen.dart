// Create flow: pick photos, reorder, rotate, remove, then continue to
// PDF settings.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/image_batch_provider.dart';
import '../services/image_service.dart';
import '../services/permission_service.dart';
import '../utils/constants.dart';
import '../utils/extensions.dart';
import '../widgets/empty_state.dart';
import 'pdf_settings_screen.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  bool _busy = false;

  Future<void> _pickImages() async {
    final granted = await PermissionService.requestPhotoAccess();
    if (!granted) {
      if (!mounted) return;
      _showPermissionDialog();
      return;
    }

    setState(() => _busy = true);
    try {
      final picked = await ImageService.pickImages();
      if (!mounted) return;
      if (picked.isNotEmpty) {
        context.read<ImageBatchProvider>().addAll(picked);
      }
    } catch (e) {
      if (mounted) context.showSnack('Could not load images: $e', isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _capture() async {
    final picked = await ImageService.captureFromCamera();
    if (!mounted) return;
    if (picked != null) {
      context.read<ImageBatchProvider>().addAll([picked]);
    }
  }

  void _showPermissionDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Permission needed'),
        content: const Text(
          'Photo access is required to select images. Please enable it in '
          'settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              PermissionService.openSettings();
            },
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final batch = context.watch<ImageBatchProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            onPressed: _busy ? null : _capture,
            icon: const Icon(Icons.photo_camera_outlined),
            tooltip: 'Camera',
          ),
        ],
      ),
      body: batch.isEmpty
          ? EmptyState(
              icon: Icons.add_photo_alternate_outlined,
              title: AppStrings.noPhotosSelected,
              hint: AppStrings.noPhotosHint,
              action: FilledButton.icon(
                onPressed: _busy ? null : _pickImages,
                icon: const Icon(Icons.add),
                label: const Text(AppStrings.selectPhotos),
              ),
            )
          : _buildList(batch),
      floatingActionButton: batch.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PdfSettingsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text(AppStrings.next),
            ),
    );
  }

  Widget _buildList(ImageBatchProvider batch) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${batch.count} photo(s) · drag to reorder',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              OutlinedButton.icon(
                onPressed: _busy ? null : _pickImages,
                icon: const Icon(Icons.add),
                label: const Text(AppStrings.addMore),
              ),
            ],
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: batch.images.length,
            onReorder: batch.reorder,
            itemBuilder: (context, index) {
              final image = batch.images[index];
              return _ImageTile(
                key: ValueKey(image.id),
                index: index,
                image: image,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ImageTile extends StatelessWidget {
  final int index;
  final dynamic image; // ImageData

  const _ImageTile({
    super.key,
    required this.index,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final batch = context.read<ImageBatchProvider>();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: image.thumbnailBytes != null
              ? RotatedBox(
                  quarterTurns: (image.rotation ~/ 90),
                  child: Image.memory(
                    image.thumbnailBytes,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                )
              : Container(
                  width: 56,
                  height: 56,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.image),
                ),
        ),
        title: Text('Photo ${index + 1}'),
        subtitle: image.rotation != 0
            ? Text('Rotated ${image.rotation}°')
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.rotate_right),
              tooltip: 'Rotate',
              onPressed: () => batch.rotate(image.id),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error),
              tooltip: 'Remove',
              onPressed: () => batch.remove(image.id),
            ),
          ],
        ),
      ),
    );
  }
}
