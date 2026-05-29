class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final bool isSupply;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.isSupply = false,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      isSupply: json['isSupply'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'isSupply': isSupply,
    };
  }
}
