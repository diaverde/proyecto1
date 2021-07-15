import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:proyecto1_cliente/allBuyers.dart';
import 'package:proyecto1_cliente/singleBuyer.dart';

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
      home: HomePage(),
    );
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
  DateTime? selectedDate;
  final buyerIDController = TextEditingController();
  String? syncState;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    buyerIDController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget _syncIndicator() {
      if (syncState == 'Working') {
        return CircularProgressIndicator();
      } else if (syncState == 'Done') {
        return Text('Datos sincronizados');
      } else {
        return Container();
      }
    }

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
                // Texto de instrucción y fecha escogida
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: SizedBox(
                    width: 150,
                    child: Column(
                      children: [
                        Text(
                          'Sincroniza fecha para obtener la información\n',
                          textAlign: TextAlign.left,
                        ),
                        Text(selectedDate != null
                            ? selectedDate!.toLocal().toString().split(' ')[0]
                            : ''),
                      ],
                    ),
                  ),
                ),
                // Botones de selección de fecha y sincronización
                Container(
                  margin: const EdgeInsets.all(10),
                  alignment: Alignment.centerRight,
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2021, 7),
                              lastDate: DateTime(2021, 8));
                          if (picked != null) {
                            setState(() {
                              selectedDate = picked;
                            });
                            print(picked);
                          }
                        },
                        child: const Text(
                          'Seleccionar fecha',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: selectedDate == null
                              ? Colors.grey
                              : Colors.purple,
                        ),
                        onPressed: () async {
                          if (selectedDate == null) {
                            showSnackbar(
                                'No ha seleccionado una fecha', context);
                          } else {
                            final unixDate =
                                ((selectedDate!.millisecondsSinceEpoch) * 0.001)
                                    .round();
                            print(unixDate);
                            checkSync(unixDate);
                            setState(() {
                              syncState = 'Working';
                            });
                          }
                        },
                        child: const Text(
                          'Sincronizar',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      _syncIndicator(),
                    ],
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BuyersPage()),
                      );
                    },
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
                        TextField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'ID de usuario'),
                          controller: buyerIDController,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      if (buyerIDController.text.isEmpty) {
                        showSnackbar('Ingrese un ID de usuario', context);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BuyerInfoPage(buyerID: buyerIDController.text),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Obtener datos\ndel usuario',
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

  void checkSync(int unixDate) async {
    final result = await synchronize(unixDate);
    if (result) {
      showSnackbar('Datos sincronizados', context);
      setState(() {
        syncState = 'Done';  
      });
    } else {
      showSnackbar(
          'Error al sincronizar.\n'
          'Intente de nuevo más tarde',
          context);
      setState(() {
        syncState = null;
      });
    }
  }
}

// Función para sincronizar base de datos
Future<bool> synchronize(int unixTime) async {
  final url = 'https://verde.loca.lt/sync';
  final data = '{"dateToSync" : ${unixTime.toString()}}';
  final response = await http.post(Uri.parse(url), body: data);
  print(response.body);

  if (response.statusCode == 200) {
    if (response.body.contains('Datos sincronizados')) {
      return true;
    } else {
      return false;
    }
  } else {
    throw Exception('Falla al cargar compradores');
  }
}

// Método para mostrar mensajes al usuario
void showSnackbar(String toShow, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(toShow)));
}
