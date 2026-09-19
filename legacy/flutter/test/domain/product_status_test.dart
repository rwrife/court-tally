import 'package:court_tally/src/domain/product_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductStatus.preMvp', () {
    test('identifies a foundation build without scoring features', () {
      expect(ProductStatus.preMvp.stage, ProductStage.preMvp);
      expect(ProductStatus.preMvp.headline, 'Pre-MVP foundation');
      expect(ProductStatus.preMvp.isScoringAvailable, isFalse);
    });
  });
}
