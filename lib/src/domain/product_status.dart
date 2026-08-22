/// Delivery stages that can be represented without depending on Flutter.
enum ProductStage { preMvp }

/// User-facing product availability derived from the current delivery stage.
final class ProductStatus {
  const ProductStatus({
    required this.stage,
    required this.headline,
    required this.description,
    required this.isScoringAvailable,
  });

  static const preMvp = ProductStatus(
    stage: ProductStage.preMvp,
    headline: 'Pre-MVP foundation',
    description:
        'Scoring features are not available yet. This build establishes the '
        'tested, offline-first application foundation.',
    isScoringAvailable: false,
  );

  final ProductStage stage;
  final String headline;
  final String description;
  final bool isScoringAvailable;
}
