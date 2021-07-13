import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:proyecto1_cliente/modelos.dart';

/// Clase principal
class BuyersPage extends StatefulWidget {
  ///  Class Key
  const BuyersPage({Key? key}) : super(key: key);

  @override
  _BuyersPageState createState() => _BuyersPageState();
}

class _BuyersPageState extends State<BuyersPage> {
  Future<List<Buyer>>? futureBuyers;

  @override
  void initState() {
    super.initState();
    futureBuyers = fetchAllBuyers();
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
              'Lista de compradores',
              style: Theme.of(context).textTheme.headline5,
              textAlign: TextAlign.center,
            ),
          ),
          // Datos
          Center(
            child: FutureBuilder<List<Buyer>>(
              future: futureBuyers,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Widget> allData = <Widget>[];
                  for (final item in snapshot.data!) {
                    Widget _singleUser = Container(
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                      decoration: new BoxDecoration(
                        border: new Border.all(color: Colors.grey, width: 0.5),
                        borderRadius: new BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        children: [
                          Text("Id: " + item.id!),
                          Text("Nombre: " + item.name!),
                          Text("Edad: " + item.age.toString()),
                        ],
                      ),
                    );
                    allData.add(_singleUser);
                  }
                  return Column(children: allData);
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

// Función para capturar lista de compradores
Future<List<Buyer>> fetchAllBuyers() async {
  final url = 'https://damn.loca.lt/buyers';
  final response = await http.get(Uri.parse(url));
  //print(response.body);

  //final xresponse = '[{"Id": "666", "Name": "John Connor", "Age": 23}]';
  List<Buyer> allBuyers = <Buyer>[];

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    final dataList = json.decode(response.body);
    if (dataList is List) {
      for (var i = 0; i < dataList.length; i++) {
        Buyer myBuyer = Buyer.fromJson(json.decode(response.body)[i]);
        //print(myBuyer.name);
        allBuyers.add(myBuyer);
      }
    }
    return allBuyers;
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
