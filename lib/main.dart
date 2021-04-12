import 'package:flutter/material.dart';
import 'package:remember_medicament/paginas/listado_medi_pag.dart';
import 'package:remember_medicament/paginas/guardar_medi_pag.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Remember Medicament',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: ListadoMediPag.ROUTE,
      routes: {
        ListadoMediPag.ROUTE: (_) => ListadoMediPag(),
        GuardarMediPag.ROUTE: (_) => GuardarMediPag(),
      },
    );
  }
}
