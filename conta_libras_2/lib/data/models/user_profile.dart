class UserProfile {
  final String id;
  final String name;
  final String category;
  final int age;
  final String escolaridade;
  final bool usaLibras;
  final String conhecimentoLibras;
  final int? cadastroId;

  const UserProfile({
    required this.id,
    required this.name,
    required this.category,
    required this.age,
    this.escolaridade = '',
    this.usaLibras = false,
    this.conhecimentoLibras = '',
    this.cadastroId,
  });

  UserProfile copyWith({int? cadastroId}) => UserProfile(
        id: id,
        name: name,
        category: category,
        age: age,
        escolaridade: escolaridade,
        usaLibras: usaLibras,
        conhecimentoLibras: conhecimentoLibras,
        cadastroId: cadastroId ?? this.cadastroId,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'age': age,
        'escolaridade': escolaridade,
        'usaLibras': usaLibras,
        'conhecimentoLibras': conhecimentoLibras,
        'cadastroId': cadastroId,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        age: json['age'] as int,
        escolaridade: json['escolaridade'] as String? ?? '',
        usaLibras: json['usaLibras'] as bool? ?? false,
        conhecimentoLibras: json['conhecimentoLibras'] as String? ?? '',
        cadastroId: json['cadastroId'] as int?,
      );
}
