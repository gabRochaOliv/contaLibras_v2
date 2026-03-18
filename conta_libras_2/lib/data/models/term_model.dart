class TermModel {
  final String id;
  final String title;
  final String category;
  final String concept;
  final String example;
  final String observation;
  final String imageLbsUrl;
  final String imageRvUrl;
  final String videoUrl;
  final String animationUrl;
  final List<String> relatedTerms;

  const TermModel({
    required this.id,
    required this.title,
    required this.category,
    required this.concept,
    required this.example,
    this.observation = '',
    this.imageLbsUrl = '',
    this.imageRvUrl = '',
    required this.videoUrl,
    required this.animationUrl,
    this.relatedTerms = const [],
  });
}
