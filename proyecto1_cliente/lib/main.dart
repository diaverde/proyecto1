import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Album> fetchAlbum() async {
  final response = await http.get(
      'https://diafanus.azurewebsites.net/api/ObtenerDatosUsuario?card=AA00BB33');

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Album.fromJson(json.decode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class Album {
  final String cardId;
  final String userId;
  final String nombre;
  final String apellido;
  final int saldo;
  final String email;

  Album(
      {this.userId,
      this.cardId,
      this.nombre,
      this.apellido,
      this.saldo,
      this.email});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      cardId: json['card_id'],
      userId: json['Id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      saldo: json['saldo'],
      email: json['email'],
    );
  }
}

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<Album> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
  }

  Widget titleSection = Container(
    padding: const EdgeInsets.all(32),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Los datos del usuario son:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.star,
          color: Colors.red[500],
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Datos Usuario',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Datos de usuario'),
        ),
        body: Center(
          child: FutureBuilder<Album>(
            future: futureAlbum,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(children: [
                  titleSection,
                  Text("Nombre: " + snapshot.data.nombre),
                  Text("Apellido: " + snapshot.data.apellido),
                  Text("Correo electrónico: " + snapshot.data.email),
                  Text("Saldo: " + snapshot.data.saldo.toString()),
                ]);
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              // By default, show a loading spinner.
              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
