class ServiceModel {
  final String id;
  final String name;
  final String? iconName;
  final String? description;
  final bool isActive;

  ServiceModel({
    required this.id,
    required this.name,
    this.iconName,
    this.description,
    this.isActive = true,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      iconName: json['icon_name'] as String?,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon_name': iconName,
      'description': description,
      'is_active': isActive,
    };
  }
}
