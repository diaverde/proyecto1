import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:proyecto1_cliente/modelos.dart';

void main() => runApp(MyApp());

/// Clase principal
class MyApp extends StatelessWidget {
  ///  Class Key
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Proyecto Uno',
        theme: ThemeData(
          primarySwatch: Colors.purple,
        ),
        home: HomePage());
  }
}

/// Clase para menú
class HomePage extends StatefulWidget {
  ///  Class Key
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Proyecto Uno'),
      ),
      body: ListView(
        children: [
          // Imagen de bienvenida
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            child: Image.asset(
              'images/kenny.png',
              width: 180,
              fit: BoxFit.cover,
              semanticLabel: 'Bienvenida',
            ),
          ),
          // Texto de bienvenida
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
            child: Column(
              children: [
                Text('Hola', style: Theme.of(context).textTheme.headline4),
                Text(
                  'Bienvenida(o) a mi aplicación\n'
                  '¿Qué deseas hacer?',
                  style: Theme.of(context).textTheme.headline6,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Datos del comprador
          BuyerData(),
          // Sincronización de fecha
          Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: new BoxDecoration(
              border: new Border.all(color: Colors.grey, width: 0.5),
              borderRadius: new BorderRadius.circular(10.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: SizedBox(
                    width: 150,
                    child: Text(
                      'Sincroniza fecha para obtener la información',
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime(2015, 9),
                          firstDate: DateTime(2015, 8),
                          lastDate: DateTime(2021));
                      if (picked != null) {
                        setState(() {
                          //selectedDate = picked;
                        });
                        print(picked);
                      }
                    },
                    child: const Text(
                      'Sincronizar',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Obtener lista de usuarios
          Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: new BoxDecoration(
              border: new Border.all(color: Colors.grey, width: 0.5),
              borderRadius: new BorderRadius.circular(10.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: SizedBox(
                    width: 150,
                    child: Text(
                      'Obtener lista de compradores',
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () async {},
                    child: const Text(
                      'Listar compradores',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Obtener datos de usuario
          Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: new BoxDecoration(
              border: new Border.all(color: Colors.grey, width: 0.5),
              borderRadius: new BorderRadius.circular(10.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: SizedBox(
                    width: 150,
                    child: Column(
                      children: [
                        Text(
                          'Obtenga datos de un comprador específico\n'
                          'Consulte por ID',
                          textAlign: TextAlign.left,
                        ),
                        TextField(),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () async {},
                    child: const Text(
                      'Sincronizar',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BuyerData extends StatefulWidget {
  BuyerData({Key? key}) : super(key: key);

  @override
  _BuyerDataState createState() => _BuyerDataState();
}

class _BuyerDataState extends State<BuyerData> {
  Future<Buyer>? futureBuyers;

  @override
  void initState() {
    super.initState();
    futureBuyers = fetchBuyers();
  }

  Widget titleSection = Container(
    padding: const EdgeInsets.all(20),
    child: Text(
      'Los datos del usuario son:',
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<Buyer>(
        future: futureBuyers,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(children: [
              titleSection,
              Text("Id: " + snapshot.data!.id!),
              Text("Nombre: " + snapshot.data!.name!),
              Text("Edad: " + snapshot.data!.age.toString()),
            ]);
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          // By default, show a loading spinner.
          return CircularProgressIndicator();
        },
      ),
    );
  }
}

Future<Buyer> fetchBuyers() async {
  final response = await http.get(Uri.parse('http://www.haztudron.com'));

  final respons = '[{"Id": "666", "Name": "John Connor", "Age": 23}]';

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    //return Buyer.fromJson(json.decode(response.body));
    return Buyer.fromJson(json.decode(respons)[0]);
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
