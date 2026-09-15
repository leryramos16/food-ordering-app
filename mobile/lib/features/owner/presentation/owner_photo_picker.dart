import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// A tappable photo preview used on owner forms to upload a restaurant or
/// menu item photo. Shows the current [imageUrl] (or a placeholder icon),
/// a small camera badge, and a loading spinner while [isUploading].
class OwnerPhotoPicker extends StatelessWidget {
  const OwnerPhotoPicker({
    super.key,
    required this.imageUrl,
    required this.isUploading,
    required this.onPicked,
    this.placeholderIcon = Icons.storefront_outlined,
  });

  final String? imageUrl;
  final bool isUploading;
  final ValueChanged<String> onPicked;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: GestureDetector(
        onTap: isUploading ? null : () => _pickImage(context),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 120,
                height: 120,
                color: colorScheme.surfaceContainerHighest,
                child: imageUrl == null || imageUrl!.isEmpty
                    ? Icon(
                        placeholderIcon,
                        size: 36,
                        color: colorScheme.onSurfaceVariant,
                      )
                    : Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, _, _) => Icon(
                          placeholderIcon,
                          size: 36,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
              ),
            ),
            if (isUploading)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: SizedBox.square(
                      dimension: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.surface, width: 2),
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  size: 16,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );

      if (picked != null) onPicked(picked.path);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $source: $error')),
        );
      }
    }
  }
}
