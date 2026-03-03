enum OfferTargetType { category, product, all }

class OfferModel {
  final String id;
  final String title;
  final double discount;
  final OfferTargetType targetType;
  final String? targetId;

  OfferModel({
    required this.id,
    required this.title,
    required this.discount,
    required this.targetType,
    this.targetId,
  });
}
