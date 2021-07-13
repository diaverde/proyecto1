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
      : id = json['id'],
        name = json['name'],
        age = json['age'];

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age': age,
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
      : id = json['id'],
        name = json['name'],
        price = json['price'];

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
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
      : id = json['id'],
        buyerId = json['buyer_id'],
        ipAddress = json['ip_address'],
        device = json['device'],
        productIds = json['product_ids'];

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => {
        'id': id,
        'buyer_id': buyerId,
        'ip_address': ipAddress,
        'device': device,
        'product_ids': productIds,
      };
}

/// Clase BuyerInfo
class BuyerInfo {
  /// Datos del comprador
  List<Buyer>? buyerData;

  /// Datos de productos
  List<Product>? prodData;

  /// Datos de transacciones
  List<Transaction>? transData;

  /// Datos de otros compradores
  List<Buyer>? otherBuyersData;

  /// Datos de otros productos
  List<Product>? otherProdData;

  /// Constructor
  BuyerInfo(
      {this.buyerData,
      this.prodData,
      this.transData,
      this.otherBuyersData,
      this.otherProdData});

  /// Convertir de json a clase
  BuyerInfo.fromJson(Map<String, dynamic> json)
      : buyerData = json['buyer_data'],
        prodData = json['prod_data'],
        transData = json['trans_data'],
        otherBuyersData = json['other_buyers_data'],
        otherProdData = json['other_prod_data'];

  /// Convertir de clase a json
  Map<String, dynamic> toJson() => {
        'buyer_data': buyerData,
        'prod_data': prodData,
        'trans_data': transData,
        'other_buyers_data': otherBuyersData,
        'other_prod_data': otherProdData,
      };
}
