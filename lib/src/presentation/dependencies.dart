import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/load_product_status.dart';
import '../application/product_status_repository.dart';
import '../data/static_product_status_repository.dart';
import '../domain/product_status.dart';

final productStatusRepositoryProvider = Provider<ProductStatusRepository>(
  (ref) => const StaticProductStatusRepository(),
);

final productStatusProvider = Provider<ProductStatus>(
  (ref) => LoadProductStatus(ref.watch(productStatusRepositoryProvider))(),
);
