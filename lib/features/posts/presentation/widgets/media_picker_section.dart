import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_typography.dart';

class MediaPickerSection extends StatelessWidget {
  const MediaPickerSection({
    super.key,
    required this.mediaFiles,
    required this.onAdd,
    required this.onRemove,
    required this.enabled,
  });

  final List<File> mediaFiles;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (mediaFiles.isEmpty) {
      return _EmptyMediaArea(onTap: enabled ? onAdd : null);
    }
    return _MediaGrid(
      files: mediaFiles,
      onAdd: enabled ? onAdd : null,
      onRemove: enabled ? onRemove : null,
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state — dashed border drop zone
// ---------------------------------------------------------------------------

class _EmptyMediaArea extends StatelessWidget {
  const _EmptyMediaArea({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            width: 1.5,
            // Dart doesn't support CSS dashed borders natively; solid border
            // with slightly raised opacity reads as a placeholder zone.
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                color: AppColors.textSecondary,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                'Toca para añadir foto',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Grid with thumbnails + add button
// ---------------------------------------------------------------------------

class _MediaGrid extends StatelessWidget {
  const _MediaGrid({
    required this.files,
    required this.onAdd,
    required this.onRemove,
  });

  final List<File> files;
  final VoidCallback? onAdd;
  final void Function(int index)? onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: files.length + (onAdd != null ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == files.length) {
            // "Add more" button
            return GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: AppColors.textSecondary,
                  size: 28,
                ),
              ),
            );
          }

          return _MediaThumbnail(
            file: files[index],
            onRemove: onRemove != null ? () => onRemove!(index) : null,
          );
        },
      ),
    );
  }
}

class _MediaThumbnail extends StatelessWidget {
  const _MediaThumbnail({required this.file, required this.onRemove});

  final File file;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            file,
            width: 88,
            height: 88,
            fit: BoxFit.cover,
          ),
        ),
        if (onRemove != null)
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Helper — shows bottom sheet to pick source, returns selected files.
// ---------------------------------------------------------------------------

Future<List<File>> pickMediaFiles(BuildContext context) async {
  final picker = ImagePicker();
  ImageSource? source;

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined,
                    color: AppColors.accent),
                title: Text('Galería', style: AppTypography.bodyLarge),
                onTap: () {
                  source = ImageSource.gallery;
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined,
                    color: AppColors.accent),
                title: Text('Cámara', style: AppTypography.bodyLarge),
                onTap: () {
                  source = ImageSource.camera;
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      );
    },
  );

  if (source == null) return [];

  if (source == ImageSource.gallery) {
    final images = await picker.pickMultiImage(imageQuality: 85);
    return images.map((x) => File(x.path)).toList();
  } else {
    final image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (image == null) return [];
    return [File(image.path)];
  }
}
