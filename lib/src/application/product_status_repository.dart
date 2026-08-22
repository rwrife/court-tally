import '../domain/product_status.dart';

/// Port used by application services to obtain the current product status.
abstract interface class ProductStatusRepository {
  ProductStatus load();
}
