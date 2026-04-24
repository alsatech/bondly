import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../data/brands_repository.dart';
import '../../data/models/brand.dart';

// ---------------------------------------------------------------------------
// Repository provider
// ---------------------------------------------------------------------------

final brandsRepositoryProvider = Provider<BrandsRepository>((ref) {
  return BrandsRepository(dio: ref.watch(dioProvider));
});

// ---------------------------------------------------------------------------
// FutureProvider — loads brands list once; can be refreshed via ref.refresh.
// ---------------------------------------------------------------------------

final brandsProvider = FutureProvider<List<Brand>>((ref) async {
  final repo = ref.watch(brandsRepositoryProvider);
  return repo.fetchBrands();
});
