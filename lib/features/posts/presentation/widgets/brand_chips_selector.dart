import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_typography.dart';
import '../../data/models/brand.dart';
import '../providers/brands_provider.dart';

class BrandChipsSelector extends ConsumerWidget {
  const BrandChipsSelector({
    super.key,
    required this.selectedIds,
    required this.onChanged,
    required this.enabled,
  });

  final Set<String> selectedIds;
  final void Function(Set<String> updated) onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandsAsync = ref.watch(brandsProvider);

    return brandsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.accent,
            ),
          ),
        ),
      ),
      error: (_, __) => Row(
        children: [
          Text(
            'No se pudieron cargar marcas',
            style:
                AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => ref.refresh(brandsProvider),
            child: Text(
              'Reintentar',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.accent,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
      data: (brands) {
        if (brands.isEmpty) {
          return Text(
            'No hay marcas disponibles',
            style:
                AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          );
        }
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: brands.map((brand) {
            final isSelected = selectedIds.contains(brand.id);
            return _BrandChip(
              brand: brand,
              isSelected: isSelected,
              enabled: enabled,
              onTap: () {
                final updated = Set<String>.from(selectedIds);
                if (isSelected) {
                  updated.remove(brand.id);
                } else {
                  updated.add(brand.id);
                }
                onChanged(updated);
              },
            );
          }).toList(),
        );
      },
    );
  }
}

class _BrandChip extends StatelessWidget {
  const _BrandChip({
    required this.brand,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
  });

  final Brand brand;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        brand.name,
        style: AppTypography.labelMedium.copyWith(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      selected: isSelected,
      onSelected: enabled ? (_) => onTap() : null,
      backgroundColor: AppColors.card,
      selectedColor: AppColors.accent,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? AppColors.accent : AppColors.border,
        width: 1,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }
}
