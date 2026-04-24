import 'package:equatable/equatable.dart';

class Brand extends Equatable {
  const Brand({
    required this.id,
    required this.name,
    this.logoUrl,
  });

  final String id;
  final String name;
  final String? logoUrl;

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      logoUrl: json['logo_url'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name, logoUrl];
}
