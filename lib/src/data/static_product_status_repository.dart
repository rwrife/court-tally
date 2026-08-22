import '../application/product_status_repository.dart';
import '../domain/product_status.dart';

/// Local, deterministic source used until persisted product state is needed.
final class StaticProductStatusRepository implements ProductStatusRepository {
  const StaticProductStatusRepository();

  @override
  ProductStatus load() => ProductStatus.preMvp;
}
