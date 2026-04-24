import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_typography.dart';

/// Sale-specific fields shown when [isSale] is true.
class SaleSection extends StatelessWidget {
  const SaleSection({
    super.key,
    required this.priceController,
    required this.selectedProductType,
    required this.isFree,
    required this.onProductTypeChanged,
    required this.onIsFreeChanged,
    required this.enabled,
  });

  final TextEditingController priceController;
  final String? selectedProductType;
  final bool isFree;
  final void Function(String?) onProductTypeChanged;
  final void Function(bool) onIsFreeChanged;
  final bool enabled;

  static const _productTypes = [
    _ProductTypeOption('clothing', 'Ropa'),
    _ProductTypeOption('accessories', 'Accesorios'),
    _ProductTypeOption('tickets', 'Entradas'),
    _ProductTypeOption('other', 'Otro'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        // Price field
        TextFormField(
          controller: priceController,
          enabled: enabled && !isFree,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: AppTypography.bodyLarge,
          cursorColor: AppColors.primary,
          decoration: _inputDecoration(
            label: 'Precio (\$)',
            hint: 'Ej: 150',
            prefixIcon: Icons.attach_money_rounded,
          ),
        ),
        const SizedBox(height: 12),
        // Product type dropdown
        DropdownButtonFormField<String>(
          initialValue: selectedProductType,
          onChanged: enabled ? onProductTypeChanged : null,
          dropdownColor: AppColors.card,
          style: AppTypography.bodyLarge,
          decoration: _inputDecoration(
            label: 'Tipo de producto',
            prefixIcon: Icons.category_outlined,
          ),
          items: _productTypes
              .map(
                (t) => DropdownMenuItem<String>(
                  value: t.value,
                  child: Text(t.label, style: AppTypography.bodyMedium),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 4),
        // Is free toggle
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Gratis', style: AppTypography.bodyMedium),
          subtitle: Text(
            'El artículo no tiene costo',
            style: AppTypography.bodySmall,
          ),
          value: isFree,
          onChanged: enabled ? onIsFreeChanged : null,
          activeThumbColor: AppColors.accent,
          activeTrackColor: AppColors.accent.withValues(alpha: 0.5),
          inactiveThumbColor: AppColors.textSecondary,
          inactiveTrackColor: AppColors.border,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: AppColors.textSecondary, size: 20)
          : null,
    );
  }
}

class _ProductTypeOption {
  const _ProductTypeOption(this.value, this.label);
  final String value;
  final String label;
}
