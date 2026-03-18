class TermModel {
  final String id;
  final String title;
  final String category;
  final String definition;
  final String videoUrl;
  final String animationUrl;
  final List<String> relatedTerms;

  const TermModel({
    required this.id,
    required this.title,
    required this.category,
    required this.definition,
    required this.videoUrl,
    required this.animationUrl,
    this.relatedTerms = const [],
  });
}
