import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:proyecto1_cliente/modelos.dart';

/// Clase principal
class BuyerInfoPage extends StatefulWidget {
  ///  Class Key
  const BuyerInfoPage({Key? key, required this.buyerID}) : super(key: key);
  final String buyerID;

  @override
  _BuyerInfoPageState createState() => _BuyerInfoPageState();
}

class _BuyerInfoPageState extends State<BuyerInfoPage> {
  Future<BuyerInfo>? futureBuyerData;

  @override
  void initState() {
    super.initState();
    futureBuyerData = fetchBuyer(widget.buyerID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Proyecto Uno'),
      ),
      body: ListView(
        children: [
          // Título
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
            child: Text(
              'Datos del comprador',
              style: Theme.of(context).textTheme.headline5,
              textAlign: TextAlign.center,
            ),
          ),
          // Datos
          Center(
            child: FutureBuilder<BuyerInfo>(
              future: futureBuyerData,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.buyerData!.isEmpty) {
                    return Text(
                        "No se encontraron datos para este ID de ususario");
                  } else {
                    // Extraer datos del comprador
                    Widget _userData = Container(
                      width: 250,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 2),
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueAccent)),
                      child: Column(
                        children: [
                          Text("Id: " + snapshot.data!.buyerData![0].id!),
                          Text("Nombre: " + snapshot.data!.buyerData![0].name!),
                          Text("Edad: " +
                              snapshot.data!.buyerData![0].age.toString()),
                        ],
                      ),
                    );
                    // Extraer datos de compras
                    List<Widget> purchasesData = <Widget>[];
                    for (final item in snapshot.data!.prodData!) {
                      Widget _singlePurchase = Container(
                        width: 400,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueAccent)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Id: " + item.id!),
                            Text("Nombre: " + item.name!),
                            Text("Precio: " + item.price.toString()),
                          ],
                        ),
                      );
                      purchasesData.add(_singlePurchase);
                    }
                    Widget _purchases = Column(
                      children: purchasesData,
                    );
                    // Extraer datos de otros compradores con misma IP
                    List<Widget> moreBuyersData = <Widget>[];
                    for (final item in snapshot.data!.otherBuyersData!) {
                      Widget _singlePerson = Container(
                        width: 200,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueAccent)),
                        child: Column(
                          children: [
                            Text("Id: " + item.id!),
                            Text("Nombre: " + item.name!),
                            Text("Edad: " + item.age.toString()),
                          ],
                        ),
                      );
                      moreBuyersData.add(_singlePerson);
                    }
                    Widget _otherBuyers = Column(
                      children: moreBuyersData,
                    );
                    // Extraer datos de otros productos recomendados
                    List<Widget> morePurchasesData = <Widget>[];
                    for (final item in snapshot.data!.otherProdData!) {
                      Widget _singlePurchase = Container(
                        width: 400,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueAccent)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Id: " + item.id!),
                            Text("Nombre: " + item.name!),
                            Text("Precio: " + item.price.toString()),
                          ],
                        ),
                      );
                      morePurchasesData.add(_singlePurchase);
                    }
                    Widget _otherProducts = Column(
                      children: morePurchasesData,
                    );
                    return Column(children: [
                      Text(
                        "Datos del comprador",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      _userData,
                      Divider(),
                      Text(
                        "Historial de compras",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      _purchases,
                      Divider(),
                      Text(
                        "Otros compradores desde su IP",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      _otherBuyers,
                      Divider(),
                      Text(
                        "Otros productos recomendados",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      _otherProducts,
                    ]);
                  }
                } else if (snapshot.hasError) {
                  if (snapshot.error.toString().contains('No hay datos')) {
                    return Text(
                        "No se encontraron datos para este ID de ususario");
                  } else {
                    print(snapshot.error);
                    return Text(
                        'Error de conexión. Verifique e intente de nuevo.');
                  }
                }
                // By default, show a loading spinner.
                return CircularProgressIndicator();
              },
            ),
          ),
          // Botón de regreso
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Volver',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Función para obtener datos de un comprador
Future<BuyerInfo>? fetchBuyer(String buyerID) async {
  final url = 'https://verde.loca.lt/buyers/';
  //final url = 'http://www.haztudron.com/';
  final response = await http.get(Uri.parse(url + buyerID));
  //final response = await http.get(Uri.parse(url));
  //print(response.body);

  /*
  final respons = '{'
      '"buyer_data": [{"id": "666", "name": "John Connor", "age": 23}],'
      '"prod_data": ['
      '{"id": "466", "name": "Pasta", "price": 23.5},'
      '{"id": "467", "name": "Pizza", "price": 13.0}'
      '],'
      '"other_buyers_data": ['
      '{"id": "667", "name": "John Wayne", "age": 13},'
      '{"id": "668", "name": "Mary Mount", "age": 15}'
      '],'
      '"other_prod_data": ['
      '{"id": "468", "name": "Burger", "price": 5.0},'
      '{"id": "469", "name": "Peanuts", "price": 3.0}'
      ']'
      '}';
  */
  if (response.statusCode == 200) {
    try {
      //return BuyerInfo.fromJson(json.decode(respons));
      return BuyerInfo.fromJson(json.decode(response.body));
    } catch (e) {
      print(e);
      throw Exception('No hay datos de comprador');
    }
    //return BuyerInfo.fromJson(json.decode(response.body));
  } else {
    throw Exception('Falla al cargar compradores');
  }
}

// Método para mostrar mensajes al usuario
void showSnackbar(String toShow, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(toShow)));
}
