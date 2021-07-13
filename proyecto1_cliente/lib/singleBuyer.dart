import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:proyecto1_cliente/modelos.dart';

/// Clase principal
class BuyerInfoPage extends StatefulWidget {
  ///  Class Key
  const BuyerInfoPage({Key? key}) : super(key: key);

  @override
  _BuyerInfoPageState createState() => _BuyerInfoPageState();
}

class _BuyerInfoPageState extends State<BuyerInfoPage> {
  Future<BuyerInfo>? futureBuyerData;

  @override
  void initState() {
    super.initState();
    futureBuyerData = fetchBuyer('666');
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
                  // Extraer datos del comprador
                  Widget _userData = Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
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
                    Widget _singlePurchase = Column(
                      children: [
                        Text("Id: " + item.id!),
                        Text("Nombre: " + item.name!),
                        Text("Precio: " + item.price.toString()),
                      ],
                    );
                    purchasesData.add(_singlePurchase);
                  }
                  Widget _purchases = Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    child: Column(
                      children: purchasesData,
                    ),
                  );
                  // Extraer datos de otros compradores con misma IP
                  List<Widget> moreBuyersData = <Widget>[];
                  for (final item in snapshot.data!.otherBuyersData!) {
                    Widget _singlePerson = Column(
                      children: [
                        Text("Id: " + item.id!),
                        Text("Nombre: " + item.name!),
                        Text("Edad: " + item.age.toString()),
                      ],
                    );
                    moreBuyersData.add(_singlePerson);
                  }
                  Widget _otherBuyers = Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    child: Column(
                      children: moreBuyersData,
                    ),
                  );
                  // Extraer datos de otros productos recomendados
                  List<Widget> morePurchasesData = <Widget>[];
                  for (final item in snapshot.data!.otherProdData!) {
                    Widget _singlePurchase = Column(
                      children: [
                        Text("Id: " + item.id!),
                        Text("Nombre: " + item.name!),
                        Text("Precio: " + item.price.toString()),
                      ],
                    );
                    morePurchasesData.add(_singlePurchase);
                  }
                  Widget _otherProducts = Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    child: Column(
                      children: morePurchasesData,
                    ),
                  );
                  return Column(children: [
                    Text("Datos del comprador"),
                    _userData,
                    Divider(),
                    Text("Historial de compras"),
                    _purchases,
                    Divider(),
                    Text("Otros compradores desde su IP"),
                    _otherBuyers,
                    Divider(),
                    Text("Otros productos recomendados"),
                    _otherProducts,
                  ]);
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
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
  //final url = 'https://damn.loca.lt/buyers/';
  final url = 'http://www.haztudron.com/';
  //final response = await http.get(Uri.parse(url + buyerID));
  final response = await http.get(Uri.parse(url));
  print(response.body);

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

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    try {
      return BuyerInfo.fromJson(json.decode(respons));
    } catch (e) {
      print(e);
      throw Exception('Falla al cargar comprador');
    }
    //return BuyerInfo.fromJson(json.decode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Falla al cargar compradores');
  }
}

// Método para mostrar mensajes al usuario
void showSnackbar(String toShow, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(toShow)));
}
