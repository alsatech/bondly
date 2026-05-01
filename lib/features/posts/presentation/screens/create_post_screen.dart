import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/widgets/snack_helper.dart';
import '../providers/create_post_notifier.dart';
import '../widgets/brand_chips_selector.dart';
import '../widgets/media_picker_section.dart';
import '../widgets/sale_section.dart';

/// Bond type selector — which category this post belongs to.
enum _BondType { place, brand, event, restaurant }

extension _BondTypeLabel on _BondType {
  String get label => switch (this) {
        _BondType.place => 'PLACE',
        _BondType.brand => 'BRAND',
        _BondType.event => 'EVENT',
        _BondType.restaurant => 'RESTAURANT',
      };
}

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  // Text controllers
  final _captionController = TextEditingController();
  final _locationNameController = TextEditingController();
  final _locationAreaController = TextEditingController();
  final _musicNameController = TextEditingController();
  final _musicArtistController = TextEditingController();
  final _externalUrlController = TextEditingController();
  final _priceController = TextEditingController();

  // State
  List<File> _mediaFiles = [];
  bool _isPrivate = false;
  bool _isSale = false;
  Set<String> _selectedBrandIds = {};
  String? _selectedProductType;
  bool _isFree = false;
  _BondType _selectedBondType = _BondType.place;

  static const int _maxCaptionLength = 280;

  bool get _canPublish {
    final caption = _captionController.text.trim();
    return caption.isNotEmpty || _mediaFiles.isNotEmpty;
  }

  bool get _hasMusic =>
      _musicNameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _captionController.addListener(() => setState(() {}));
    _locationNameController.addListener(() => setState(() {}));
    _musicNameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _captionController.dispose();
    _locationNameController.dispose();
    _locationAreaController.dispose();
    _musicNameController.dispose();
    _musicArtistController.dispose();
    _externalUrlController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifierState = ref.watch(createPostNotifierProvider);
    final isSubmitting = notifierState is CreatePostSubmitting;

    ref.listen<CreatePostState>(createPostNotifierProvider, (_, next) {
      if (next is CreatePostSuccess) {
        Navigator.of(context).pop(next.post);
      } else if (next is CreatePostError) {
        SnackHelper.showError(context, next.failure.message);
        ref.read(createPostNotifierProvider.notifier).reset();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AbsorbPointer(
        absorbing: isSubmitting,
        child: _buildBody(isSubmitting),
      ),
    );
  }

  Widget _buildBody(bool isSubmitting) {
    return CustomScrollView(
      slivers: [
        // ── Top: full-bleed photo section with overlay app bar ──────────────
        SliverToBoxAdapter(
          child: _PhotoSection(
            mediaFiles: _mediaFiles,
            isSubmitting: isSubmitting,
            onAdd: _pickMedia,
            onRemove: (i) => setState(() {
              _mediaFiles = List.from(_mediaFiles)..removeAt(i);
            }),
          ),
        ),

        // ── Form body ────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section label
                _SectionHeader(
                  label: 'WHAT IS THIS BOND WITH?',
                  subtitle: '— The point of the post.',
                ),
                const SizedBox(height: 12),

                // Bond type selector chips
                _BondTypeSelector(
                  selected: _selectedBondType,
                  onChanged: (t) => setState(() => _selectedBondType = t),
                ),
                const SizedBox(height: 20),

                // Location search field
                _SearchField(
                  controller: _locationNameController,
                  hint: _locationNameController.text.isEmpty
                      ? 'Search for a ${_selectedBondType.label.toLowerCase()}…'
                      : null,
                ),

                // Recent locations row
                if (_locationNameController.text.isEmpty) ...[
                  const SizedBox(height: 10),
                  _RecentRow(
                    onTap: (name) {
                      _locationNameController.text = name;
                      setState(() {});
                    },
                  ),
                ],

                const SizedBox(height: 24),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 24),

                // Caption
                _SectionHeader(
                  label: 'CAPTION',
                  subtitle: '— A note, not a press release.',
                ),
                const SizedBox(height: 10),
                _CaptionField(
                  controller: _captionController,
                  maxLength: _maxCaptionLength,
                ),

                const SizedBox(height: 24),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 24),

                // Soundtrack
                _SectionHeader(
                  label: 'SOUNDTRACK',
                  subtitle: '— Optional. Plays on the card.',
                ),
                const SizedBox(height: 10),
                _SoundtrackField(
                  nameController: _musicNameController,
                  artistController: _musicArtistController,
                  hasTrack: _hasMusic,
                ),

                const SizedBox(height: 24),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 24),

                // Brands
                _SectionHeader(label: 'BRANDS', subtitle: null),
                const SizedBox(height: 10),
                BrandChipsSelector(
                  selectedIds: _selectedBrandIds,
                  enabled: true,
                  onChanged: (updated) =>
                      setState(() => _selectedBrandIds = updated),
                ),

                const SizedBox(height: 24),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 24),

                // Audience
                _SectionHeader(label: 'AUDIENCE', subtitle: null),
                const SizedBox(height: 10),
                _AudienceSelector(
                  isPrivate: _isPrivate,
                  onChanged: (v) => setState(() => _isPrivate = v),
                ),

                const SizedBox(height: 24),

                // Sale section (optional)
                if (_isSale) ...[
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 16),
                  SaleSection(
                    priceController: _priceController,
                    selectedProductType: _selectedProductType,
                    isFree: _isFree,
                    onProductTypeChanged: (v) =>
                        setState(() => _selectedProductType = v),
                    onIsFreeChanged: (v) => setState(() => _isFree = v),
                    enabled: true,
                  ),
                  const SizedBox(height: 24),
                ],

                // Share Bond CTA
                _ShareBondButton(
                  enabled: _canPublish && !isSubmitting,
                  isLoading: isSubmitting,
                  onPressed: _handleSubmit,
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'VISIBLE TO ALL OF BONDLY',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickMedia() async {
    final picked = await pickMediaFiles(context);
    if (picked.isEmpty) return;
    setState(() {
      _mediaFiles = [..._mediaFiles, ...picked];
    });
  }

  Future<void> _handleSubmit() async {
    final caption = _captionController.text.trim();
    if (caption.isEmpty && _mediaFiles.isEmpty) {
      SnackHelper.showError(
        context,
        'Add a photo or write something to share.',
      );
      return;
    }

    int? priceCents;
    if (_isSale && !_isFree) {
      final rawPrice = int.tryParse(_priceController.text.trim());
      if (rawPrice != null) priceCents = rawPrice * 100;
    }

    await ref.read(createPostNotifierProvider.notifier).submit(
          caption: caption.isNotEmpty ? caption : null,
          isPrivate: _isPrivate,
          isSale: _isSale,
          musicName: _musicNameController.text.trim().isEmpty
              ? null
              : _musicNameController.text.trim(),
          musicArtist: _musicArtistController.text.trim().isEmpty
              ? null
              : _musicArtistController.text.trim(),
          locationName: _locationNameController.text.trim().isEmpty
              ? null
              : _locationNameController.text.trim(),
          locationArea: _locationAreaController.text.trim().isEmpty
              ? null
              : _locationAreaController.text.trim(),
          externalUrl: _externalUrlController.text.trim().isEmpty
              ? null
              : _externalUrlController.text.trim(),
          brandIds: _selectedBrandIds.toList(),
          mediaFiles: _mediaFiles,
          priceCents: priceCents,
          productType: _selectedProductType,
          isFree: _isSale ? _isFree : null,
        );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Photo section with overlay app bar
// ─────────────────────────────────────────────────────────────────────────────

class _PhotoSection extends StatelessWidget {
  const _PhotoSection({
    required this.mediaFiles,
    required this.isSubmitting,
    required this.onAdd,
    required this.onRemove,
  });

  final List<File> mediaFiles;
  final bool isSubmitting;
  final VoidCallback onAdd;
  final void Function(int) onRemove;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return SizedBox(
      height: 340 + topPadding,
      child: Stack(
        children: [
          // Full-bleed background
          Positioned.fill(
            child: mediaFiles.isEmpty
                ? _EmptyPhotoPlaceholder(onTap: onAdd)
                : _PhotoPreview(
                    files: mediaFiles,
                    onAdd: onAdd,
                    onRemove: onRemove,
                  ),
          ),
          // Overlay gradient at top for nav bar readability
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 100 + topPadding,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // App bar overlay: CANCEL | New Bond. | DRAFT
          Positioned(
            top: topPadding,
            left: 0,
            right: 0,
            child: _OverlayAppBar(isSubmitting: isSubmitting),
          ),
          // Thumbnail strip at bottom when media is present
          if (mediaFiles.isNotEmpty)
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: _ThumbStrip(
                files: mediaFiles,
                onAdd: onAdd,
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyPhotoPlaceholder extends StatelessWidget {
  const _EmptyPhotoPlaceholder({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: AppColors.card,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                color: AppColors.textSecondary,
                size: 48,
              ),
              const SizedBox(height: 10),
              Text(
                'Tap to add photo',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
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

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({
    required this.files,
    required this.onAdd,
    required this.onRemove,
  });
  final List<File> files;
  final VoidCallback onAdd;
  final void Function(int) onRemove;

  @override
  Widget build(BuildContext context) {
    return Image.file(
      files.first,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }
}

class _ThumbStrip extends StatelessWidget {
  const _ThumbStrip({required this.files, required this.onAdd});
  final List<File> files;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: files.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          if (i == files.length) {
            return GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            );
          }
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              files[i],
              width: 52,
              height: 52,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}

class _OverlayAppBar extends StatelessWidget {
  const _OverlayAppBar({required this.isSubmitting});
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: isSubmitting ? null : () => Navigator.of(context).pop(),
            child: Text(
              'CANCEL',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'New Bond.',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          Text(
            'DRAFT',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.6),
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.subtitle});
  final String label;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(width: 8),
          Text(
            subtitle!,
            style: GoogleFonts.playfairDisplay(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bond type chip selector
// ─────────────────────────────────────────────────────────────────────────────

class _BondTypeSelector extends StatelessWidget {
  const _BondTypeSelector({
    required this.selected,
    required this.onChanged,
  });

  final _BondType selected;
  final ValueChanged<_BondType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _BondType.values
          .map(
            (t) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onChanged(t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: t == selected
                        ? AppColors.textPrimary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: t == selected
                          ? AppColors.textPrimary
                          : AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    t.label,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: t == selected
                          ? Colors.black
                          : AppColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search / location field
// ─────────────────────────────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, this.hint});
  final TextEditingController controller;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.dmSans(
        fontSize: 15,
        color: AppColors.textPrimary,
      ),
      cursorColor: AppColors.textPrimary,
      decoration: InputDecoration(
        hintText: hint ?? 'Search…',
        hintStyle: GoogleFonts.dmSans(
          fontSize: 15,
          color: AppColors.textSecondary,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.textSecondary,
          size: 20,
        ),
        filled: true,
        fillColor: AppColors.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: AppColors.textSecondary, width: 1),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recent locations chip row
// ─────────────────────────────────────────────────────────────────────────────

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.onTap});
  final void Function(String name) onTap;

  // Static UI labels — these just fill the text field when tapped.
  static const _recent = ['Bellweather Coffee', 'Cape Formentor', 'Atelier Nord'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'RECENT · ',
          style: GoogleFonts.dmSans(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
        ..._recent.map(
          (name) => GestureDetector(
            onTap: () => onTap(name),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                name,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Caption field with char counter
// ─────────────────────────────────────────────────────────────────────────────

class _CaptionField extends StatelessWidget {
  const _CaptionField({
    required this.controller,
    required this.maxLength,
  });

  final TextEditingController controller;
  final int maxLength;

  @override
  Widget build(BuildContext context) {
    final count = controller.text.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          maxLines: 5,
          minLines: 3,
          maxLength: maxLength,
          style: GoogleFonts.dmSans(
            fontSize: 15,
            color: AppColors.textPrimary,
            height: 1.5,
          ),
          cursorColor: AppColors.textPrimary,
          buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
              const SizedBox.shrink(),
          decoration: InputDecoration(
            hintText: 'Write your bond…',
            hintStyle: GoogleFonts.dmSans(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.card,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.textSecondary, width: 1),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              'AUTO DROP-CAP ON FIRST LETTER',
              style: GoogleFonts.dmSans(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
            const Spacer(),
            Text(
              '$count / $maxLength',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Soundtrack field
// ─────────────────────────────────────────────────────────────────────────────

class _SoundtrackField extends StatelessWidget {
  const _SoundtrackField({
    required this.nameController,
    required this.artistController,
    required this.hasTrack,
  });

  final TextEditingController nameController;
  final TextEditingController artistController;
  final bool hasTrack;

  @override
  Widget build(BuildContext context) {
    if (hasTrack) {
      // Show the selected track as a row card.
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.music_note_rounded,
                color: AppColors.gold,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nameController.text,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (artistController.text.isNotEmpty)
                    Text(
                      artistController.text.toUpperCase(),
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                ],
              ),
            ),
            // Radio-style selected indicator
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold, width: 2),
              ),
              child: Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        TextFormField(
          controller: nameController,
          style: GoogleFonts.dmSans(
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
          cursorColor: AppColors.textPrimary,
          decoration: InputDecoration(
            hintText: 'Song title…',
            hintStyle: GoogleFonts.dmSans(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.card,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            prefixIcon: const Icon(
              Icons.music_note_outlined,
              color: AppColors.textSecondary,
              size: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.textSecondary, width: 1),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: artistController,
          style: GoogleFonts.dmSans(
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
          cursorColor: AppColors.textPrimary,
          decoration: InputDecoration(
            hintText: 'Artist…',
            hintStyle: GoogleFonts.dmSans(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.card,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            prefixIcon: const Icon(
              Icons.person_outline_rounded,
              color: AppColors.textSecondary,
              size: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.textSecondary, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Audience selector (Public / My Circles / Founders only)
// ─────────────────────────────────────────────────────────────────────────────

class _AudienceSelector extends StatelessWidget {
  const _AudienceSelector({
    required this.isPrivate,
    required this.onChanged,
  });

  final bool isPrivate;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AudienceTile(
          title: 'Public',
          subtitle: 'Visible to all of Bondly',
          isSelected: !isPrivate,
          onTap: () => onChanged(false),
        ),
        const SizedBox(height: 8),
        _AudienceTile(
          title: 'My Circles',
          subtitle: 'Only the clubs you belong to',
          isSelected: false,
          onTap: () {},
        ),
        const SizedBox(height: 8),
        _AudienceTile(
          title: 'Founders only',
          subtitle: 'Other founders & invited members',
          isSelected: isPrivate,
          onTap: () => onChanged(true),
          isFounders: true,
        ),
      ],
    );
  }
}

class _AudienceTile extends StatelessWidget {
  const _AudienceTile({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.isFounders = false,
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isFounders;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.textSecondary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio button
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isFounders) ...[
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.gold,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        title,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isFounders
                              ? AppColors.gold
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Share Bond CTA button — gold gradient
// ─────────────────────────────────────────────────────────────────────────────

class _ShareBondButton extends StatelessWidget {
  const _ShareBondButton({
    required this.enabled,
    required this.isLoading,
    required this.onPressed,
  });

  final bool enabled;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.45,
        duration: const Duration(milliseconds: 180),
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            gradient: enabled
                ? const LinearGradient(
                    colors: [AppColors.gold, AppColors.goldDark],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: enabled ? null : AppColors.border,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.black, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'SHARE BOND',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
