import '../domain/product_status.dart';
import 'product_status_repository.dart';

/// Application service that retrieves status without knowing its data source.
final class LoadProductStatus {
  const LoadProductStatus(this._repository);

  final ProductStatusRepository _repository;

  ProductStatus call() => _repository.load();
}
