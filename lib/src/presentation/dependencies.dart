import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/data_transfer_gateway.dart';
import '../application/load_product_status.dart';
import '../application/match_repository.dart';
import '../application/product_status_repository.dart';
import '../data/court_tally_database.dart';
import '../data/data_ownership_service.dart';
import '../data/drift_match_repository.dart';
import '../data/platform_data_transfer_gateway.dart';
import '../data/static_product_status_repository.dart';
import '../domain/product_status.dart';

final courtTallyDatabaseProvider = Provider<CourtTallyDatabase>((ref) {
  final database = CourtTallyDatabase(openCourtTallyDatabase());
  ref.onDispose(database.close);
  return database;
});

final matchRepositoryProvider = Provider<MatchRepository>(
  (ref) => DriftMatchRepository(ref.watch(courtTallyDatabaseProvider)),
);

final dataOwnershipServiceProvider = Provider<DataOwnershipService>(
  (ref) => DataOwnershipService(ref.watch(matchRepositoryProvider)),
);

final dataTransferGatewayProvider = Provider<DataTransferGateway>(
  (ref) => const PlatformDataTransferGateway(),
);

final productStatusRepositoryProvider = Provider<ProductStatusRepository>(
  (ref) => const StaticProductStatusRepository(),
);

final productStatusProvider = Provider<ProductStatus>(
  (ref) => LoadProductStatus(ref.watch(productStatusRepositoryProvider))(),
);
