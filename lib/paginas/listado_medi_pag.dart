import 'dart:io';

import 'package:flutter/material.dart';
import 'package:remember_medicament/database/proveedor_db.dart';
import 'package:remember_medicament/modelos/medicamento.dart';
import 'package:remember_medicament/paginas/guardar_medi_pag.dart';

class ListadoMediPag extends StatelessWidget {
  static const String ROUTE = '/';
  @override
  Widget build(BuildContext context) {
    return _MiListadoMedi();
  }
}

class _MiListadoMedi extends StatefulWidget {
  @override
  __MiListadoMediState createState() => __MiListadoMediState();
}

class __MiListadoMediState extends State<_MiListadoMedi> {
  List<Medicamento> medicamentos = [];

  @override
  void initState() {
    _cargarDatos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, GuardarMediPag.ROUTE,
                  arguments: Medicamento.vacio())
              .then((value) => setState(() {
                    _cargarDatos();
                  }));
        },
      ),
      appBar: AppBar(
        title: Text('Listado de Medicamentos'),
      ),
      drawer: MenuLateral(),
      body: Container(
        padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
        child: ListView.builder(
          itemCount: medicamentos.length,
          itemBuilder: (_, i) => _crearElemento(i),
        ),
      ),
    );
  }

  _cargarDatos() async {
    List<Medicamento> auxMedicamento = await ProveedorDB.medicamentos();

    setState(() {
      medicamentos = auxMedicamento;
    });
  }

  _crearElemento(int i) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      color: Colors.blue.shade100,
      child: Dismissible(
        key: Key(i.toString()),
        direction: DismissDirection.horizontal,
        background: Container(
          color: Colors.red,
          padding: EdgeInsets.only(left: 5),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Icon(Icons.delete, color: Colors.white),
          ),
        ),
        secondaryBackground: Container(
          color: Colors.red,
          padding: EdgeInsets.only(right: 5),
          child: Align(
            alignment: Alignment.centerRight,
            child: Icon(Icons.delete, color: Colors.white),
          ),
        ),
        confirmDismiss: (direction) async {
          final bool res = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Text(
                      "¿Estás seguro de que quieres eliminar ${medicamentos[i].nombre}?"),
                  actions: <Widget>[
                    TextButton(
                      child: Text(
                        "Cancelar",
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text(
                        "Borrar",
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () {
                        ProveedorDB.borrar(medicamentos[i]);
                        setState(() {
                          _cargarDatos();
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              });
          return res;
        },
        onDismissed: (direccion) {
          //ProveedorDB.borrar(medicamentos[i]);
        },
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                children: <Widget>[
                  // Sección izquierda
                  medicamentos[i].rutaImagen != null
                      ? SizedBox(
                          height: 50.0,
                          width: 50.0,
                          child: Image.file(File(medicamentos[i].rutaImagen)))
                      : Image(
                          image: AssetImage(
                              'assets/img/Imagen-no-disponible-282x300.png'),
                          height: 50.0,
                          alignment: Alignment.topLeft,
                        ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      medicamentos[i].nombre,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Roboto',
                        letterSpacing: 0.5,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      medicamentos[i].contenido,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Roboto',
                        letterSpacing: 0.5,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MaterialButton(
                    onPressed: () {
                      Navigator.pushNamed(context, GuardarMediPag.ROUTE,
                              arguments: medicamentos.length > 0
                                  ? medicamentos[i]
                                  : null)
                          .then((value) => setState(() {
                                _cargarDatos();
                              }));
                    },
                    child: Icon(
                      Icons.edit,
                      color: Colors.green,
                    ))
              ],
            ),

            /*
                Align(
                  alignment: Alignment.centerLeft,
                  child: Image(
                    image:
                        AssetImage('assets/img/Imagen-no-disponible-282x300.png'),
                    height: 50.0,
                    alignment: Alignment.topLeft,
                  ),
                ),
                Column(
                  verticalDirection:
                      VerticalDirection.down /* o VerticalDirection.up */,
                  children: <Widget>[
                    Text(
                      'Vertical Direction 1',
                      style: TextStyle(fontSize: 22.0),
                    ),
                    Text(
                      'Vertical',
                      style: TextStyle(fontSize: 22.0),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text('Hola como estás'),
                      Text('Estoy fatal'),
                    ],
                  ),
                ),
              */
          ],
        ),
      ),
    );
  }
  /*
  _crearElemento(int i) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      color: Colors.blue.shade100,
      child: Dismissible(
        key: Key(i.toString()),
        direction: DismissDirection.horizontal,
        background: Container(
          color: Colors.red,
          padding: EdgeInsets.only(left: 5),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Icon(Icons.delete, color: Colors.white),
          ),
        ),
        secondaryBackground: Container(
          color: Colors.red,
          padding: EdgeInsets.only(right: 5),
          child: Align(
            alignment: Alignment.centerRight,
            child: Icon(Icons.delete, color: Colors.white),
          ),
        ),
        confirmDismiss: (direction) async {
          //if (direction == DismissDirection.endToStart) {
          final bool res = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Text(
                      "¿Estás seguro de que quieres eliminar ${medicamentos[i].nombre}?"),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(
                        "Cancelar",
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: Text(
                        "Borrar",
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () {
                        ProveedorDB.borrar(medicamentos[i]);
                        setState(() {
                          _cargarDatos();
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              });
          return res;
          //} else {
          // 
          //}
        },
        onDismissed: (direccion) {
          //ProveedorDB.borrar(medicamentos[i]);
        },
        child: Container(
          padding: EdgeInsets.all(5),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    medicamentos[i].rutaImagen != null
                        ? SizedBox(
                            height: 50.0,
                            width: 50.0,
                            child: Image.file(File(medicamentos[i].rutaImagen)))
                        : Image(
                            image: AssetImage(
                                'assets/img/Imagen-no-disponible-282x300.png'),
                            height: 50.0,
                            alignment: Alignment.topLeft,
                          ),
                    SizedBox(width: 5),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      verticalDirection:
                          VerticalDirection.down /* o VerticalDirection.up */,
                      children: <Widget>[
                        Text(
                          medicamentos[i].nombre,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Roboto',
                            letterSpacing: 0.5,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          medicamentos[i].contenido,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Roboto',
                            letterSpacing: 0.5,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: MaterialButton(
                          onPressed: () {
                            Navigator.pushNamed(context, GuardarMediPag.ROUTE,
                                    arguments: medicamentos.length > 0
                                        ? medicamentos[i]
                                        : null)
                                .then((value) => setState(() {
                                      _cargarDatos();
                                    }));
                          },
                          child: Icon(
                            Icons.edit,
                            color: Colors.black,
                          )),
                    ),
                  ],
                ),
                /*
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      medicamentos[i].nombre,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Roboto',
                        letterSpacing: 0.5,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      medicamentos[i].contenido,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Roboto',
                        letterSpacing: 0.5,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                */
                /*
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MaterialButton(
                        onPressed: () {
                          Navigator.pushNamed(context, GuardarMediPag.ROUTE,
                                  arguments: medicamentos.length > 0
                                      ? medicamentos[i]
                                      : null)
                              .then((value) => setState(() {
                                    _cargarDatos();
                                  }));
                        },
                        child: Icon(
                          Icons.edit,
                          color: Colors.black,
                        )),
                  ],
                ),
                */
                /*
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        medicamentos[i].nombre,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Roboto',
                          letterSpacing: 0.5,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        medicamentos[i].contenido,
                        //textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Roboto',
                          letterSpacing: 0.5,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                */
              ],
            ),
          ),
        ),
      ),
    );
  }
  */
}

class MenuLateral extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Drawer(
      child: ListView(
        children: <Widget>[
          new UserAccountsDrawerHeader(
            accountName: Text(
              "Remember Medicament",
              style: TextStyle(color: Colors.black),
            ),
            accountEmail: Text(
              "@gmail.com",
              style: TextStyle(color: Colors.black),
            ),
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/img/google_logo.png'),
                    fit: BoxFit.contain)),
          ),
          Ink(
            color: Colors.green,
            child: new ListTile(
              title: Text(
                "MENU 1",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          new ListTile(
            title: Text("MENU 2"),
            onTap: () {},
          ),
          new ListTile(
            title: Text("MENU 3"),
          ),
          new ListTile(
            title: Text("MENU 4"),
          )
        ],
      ),
    );
  }
}
