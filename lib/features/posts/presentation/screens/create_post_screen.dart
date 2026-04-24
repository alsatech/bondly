import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_typography.dart';
import '../../../../../shared/widgets/snack_helper.dart';
import '../providers/create_post_notifier.dart';
import '../widgets/brand_chips_selector.dart';
import '../widgets/location_music_section.dart';
import '../widgets/media_picker_section.dart';
import '../widgets/sale_section.dart';

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
  bool _isDetailsExpanded = false;
  Set<String> _selectedBrandIds = {};
  String? _selectedProductType;
  bool _isFree = false;

  bool get _canPublish {
    final caption = _captionController.text.trim();
    return caption.isNotEmpty || _mediaFiles.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    // Rebuild "Publicar" button reactivity when caption changes.
    _captionController.addListener(() => setState(() {}));
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

    // Listen for state transitions
    ref.listen<CreatePostState>(createPostNotifierProvider, (_, next) {
      if (next is CreatePostSuccess) {
        Navigator.of(context).pop(next.post);
      } else if (next is CreatePostError) {
        SnackHelper.showError(context, next.failure.message);
        // Reset so user can retry
        ref.read(createPostNotifierProvider.notifier).reset();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(isSubmitting),
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: isSubmitting,
          child: _buildBody(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isSubmitting) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary, size: 20),
        onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Nuevo post',
        style: AppTypography.headlineMedium,
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: _PublishAppBarButton(
            enabled: _canPublish && !isSubmitting,
            isLoading: isSubmitting,
            onPressed: _handleSubmit,
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ----------------------------------------------------------------
          // Media section
          // ----------------------------------------------------------------
          _sectionLabel('Fotos / Videos'),
          const SizedBox(height: 8),
          MediaPickerSection(
            mediaFiles: _mediaFiles,
            enabled: true,
            onAdd: _pickMedia,
            onRemove: (index) {
              setState(() {
                _mediaFiles = List.from(_mediaFiles)..removeAt(index);
              });
            },
          ),

          const SizedBox(height: 20),

          // ----------------------------------------------------------------
          // Caption
          // ----------------------------------------------------------------
          TextFormField(
            controller: _captionController,
            maxLines: 5,
            minLines: 3,
            style: AppTypography.bodyLarge,
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              hintText: '¿Qué estás compartiendo?',
              hintStyle: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              filled: true,
              fillColor: AppColors.card,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.accent, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ----------------------------------------------------------------
          // Detalles (colapsable)
          // ----------------------------------------------------------------
          _CollapsibleSection(
            title: 'Detalles',
            icon: Icons.tune_rounded,
            isExpanded: _isDetailsExpanded,
            onToggle: () =>
                setState(() => _isDetailsExpanded = !_isDetailsExpanded),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Privacy toggle
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Privado', style: AppTypography.bodyMedium),
                  subtitle: Text(
                    'Solo gente que sigues',
                    style: AppTypography.bodySmall,
                  ),
                  value: _isPrivate,
                  onChanged: (v) => setState(() => _isPrivate = v),
                  activeThumbColor: AppColors.accent,
                  activeTrackColor: AppColors.accent.withValues(alpha: 0.5),
                  inactiveThumbColor: AppColors.textSecondary,
                  inactiveTrackColor: AppColors.border,
                ),
                const SizedBox(height: 8),
                // Location + Music
                LocationMusicSection(
                  locationNameController: _locationNameController,
                  locationAreaController: _locationAreaController,
                  musicNameController: _musicNameController,
                  musicArtistController: _musicArtistController,
                  enabled: true,
                ),
                const SizedBox(height: 12),
                // External URL
                TextFormField(
                  controller: _externalUrlController,
                  keyboardType: TextInputType.url,
                  style: AppTypography.bodyLarge,
                  cursorColor: AppColors.primary,
                  decoration: const InputDecoration(
                    labelText: 'Link externo (opcional)',
                    hintText: 'https://...',
                    prefixIcon: Icon(Icons.link_rounded,
                        color: AppColors.textSecondary, size: 20),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ----------------------------------------------------------------
          // Marcas
          // ----------------------------------------------------------------
          _sectionLabel('Marcas'),
          const SizedBox(height: 8),
          BrandChipsSelector(
            selectedIds: _selectedBrandIds,
            enabled: true,
            onChanged: (updated) =>
                setState(() => _selectedBrandIds = updated),
          ),

          const SizedBox(height: 20),

          // ----------------------------------------------------------------
          // Venta
          // ----------------------------------------------------------------
          _CollapsibleSection(
            title: 'En venta',
            icon: Icons.sell_outlined,
            isExpanded: _isSale,
            onToggle: () => setState(() => _isSale = !_isSale),
            leadingWidget: Switch(
              value: _isSale,
              onChanged: (v) => setState(() => _isSale = v),
              activeThumbColor: AppColors.accent,
              activeTrackColor: AppColors.accent.withValues(alpha: 0.5),
              inactiveThumbColor: AppColors.textSecondary,
              inactiveTrackColor: AppColors.border,
            ),
            child: _isSale
                ? SaleSection(
                    priceController: _priceController,
                    selectedProductType: _selectedProductType,
                    isFree: _isFree,
                    onProductTypeChanged: (v) =>
                        setState(() => _selectedProductType = v),
                    onIsFreeChanged: (v) => setState(() => _isFree = v),
                    enabled: true,
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 28),

          // ----------------------------------------------------------------
          // Publish button (bottom)
          // ----------------------------------------------------------------
          _PublishBottomButton(
            enabled: _canPublish,
            onPressed: _handleSubmit,
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary),
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
        'Añade una foto o escribe algo para publicar.',
      );
      return;
    }

    int? priceCents;
    if (_isSale && !_isFree) {
      final rawPrice = int.tryParse(_priceController.text.trim());
      if (rawPrice != null) {
        priceCents = rawPrice * 100;
      }
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

// ---------------------------------------------------------------------------
// Publish button in AppBar
// ---------------------------------------------------------------------------

class _PublishAppBarButton extends StatelessWidget {
  const _PublishAppBarButton({
    required this.enabled,
    required this.isLoading,
    required this.onPressed,
  });

  final bool enabled;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: enabled && !isLoading ? onPressed : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Publicar',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Publish button at bottom of scroll
// ---------------------------------------------------------------------------

class _PublishBottomButton extends StatelessWidget {
  const _PublishBottomButton({
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.border,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: Text(
          'Publicar',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: enabled ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Collapsible section wrapper
// ---------------------------------------------------------------------------

class _CollapsibleSection extends StatelessWidget {
  const _CollapsibleSection({
    required this.title,
    required this.icon,
    required this.isExpanded,
    required this.onToggle,
    required this.child,
    this.leadingWidget,
  });

  final String title;
  final IconData icon;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Widget child;
  final Widget? leadingWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: leadingWidget == null ? onToggle : null,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.textSecondary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTypography.labelLarge,
                    ),
                  ),
                  if (leadingWidget != null) leadingWidget!,
                  if (leadingWidget == null)
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: isExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: child,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
