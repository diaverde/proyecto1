// Modelos de datos recibidos

/// Clase Buyer
class Buyer {
  /// ID en base de datos
  String? id;

  /// Nombre del comprador
  String? name;

  /// Edad del comprador
  int? age;

  /// Constructor
  Buyer({this.id, this.name, this.age});

  /// Convertir de json a clase
  Buyer.fromJson(Map<String, dynamic> json)
      : id = json['Id'],
        name = json['Name'],
        age = json['Age'];

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => {
        'Id': id,
        'Name': name,
        'Age': age,
      };
}

/// Clase Product
class Product {
  /// ID en base de datos
  String? id;

  /// Nombre del comprador
  String? name;

  /// Edad del comprador
  double? price;

  /// Constructor
  Product({this.id, this.name, this.price});

  /// Convertir de json a clase
  Product.fromJson(Map<String, dynamic> json)
      : id = json['Id'],
        name = json['Name'],
        price = json['Price'];

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => {
        'Id': id,
        'Name': name,
        'Price': price,
      };
}

/// Clase Transaction
class Transaction {
  /// ID en base de datos
  String? id;

  /// ID del comprador
  String? buyerId;

  /// Dirección ip
  String? ipAddress;

  /// Dispositivo
  String? device;

  /// ID de productos comprados
  List<String>? productIds;

  /// Constructor
  Transaction(
      {this.id, this.buyerId, this.ipAddress, this.device, this.productIds});

  /// Convertir de json a clase
  Transaction.fromJson(Map<String, dynamic> json)
      : id = json['Id'],
        buyerId = json['Buyer_id'],
        ipAddress = json['Ip_address'],
        device = json['Device'],
        productIds = json['Product_ids'];

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => {
        'Id': id,
        'Buyer_id': buyerId,
        'Ip_address': ipAddress,
        'Device': device,
        'Product_ids': productIds,
      };
}
