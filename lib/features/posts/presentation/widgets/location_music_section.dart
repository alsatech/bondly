import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_typography.dart';

/// Grouped fields for location and music metadata.
class LocationMusicSection extends StatelessWidget {
  const LocationMusicSection({
    super.key,
    required this.locationNameController,
    required this.locationAreaController,
    required this.musicNameController,
    required this.musicArtistController,
    required this.enabled,
  });

  final TextEditingController locationNameController;
  final TextEditingController locationAreaController;
  final TextEditingController musicNameController;
  final TextEditingController musicArtistController;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Ubicación', Icons.location_on_outlined),
        const SizedBox(height: 8),
        TextFormField(
          controller: locationNameController,
          enabled: enabled,
          style: AppTypography.bodyLarge,
          cursorColor: AppColors.primary,
          decoration: _inputDecoration(
            label: 'Nombre del lugar',
            hint: 'Ej: Café La Palma',
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: locationAreaController,
          enabled: enabled,
          style: AppTypography.bodyLarge,
          cursorColor: AppColors.primary,
          decoration: _inputDecoration(
            label: 'Barrio / ciudad',
            hint: 'Ej: Polanco, CDMX',
          ),
        ),
        const SizedBox(height: 16),
        _sectionLabel('Música', Icons.music_note_outlined),
        const SizedBox(height: 8),
        TextFormField(
          controller: musicNameController,
          enabled: enabled,
          style: AppTypography.bodyLarge,
          cursorColor: AppColors.primary,
          decoration: _inputDecoration(
            label: 'Canción',
            hint: 'Ej: Blinding Lights',
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: musicArtistController,
          enabled: enabled,
          style: AppTypography.bodyLarge,
          cursorColor: AppColors.primary,
          decoration: _inputDecoration(
            label: 'Artista',
            hint: 'Ej: The Weeknd',
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 18),
        const SizedBox(width: 6),
        Text(
          text,
          style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({required String label, String? hint}) {
    return InputDecoration(labelText: label, hintText: hint);
  }
}
