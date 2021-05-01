import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:remember_medicament/database/proveedor_db.dart';
import 'package:remember_medicament/modelos/medicamento.dart';
import 'package:remember_medicament/paginas/alarma_manager_pag.dart';
import 'package:remember_medicament/paginas/guardar_medi_pag.dart';
import 'package:remember_medicament/paginas/listado_actual_pag.dart';

import '../main.dart';
import 'listado_alarm_pag.dart';

class ListadoMediPag extends StatefulWidget {
  static const String ROUTE = '/';

  const ListadoMediPag(
    this.notificationAppLaunchDetails, {
    Key key,
  }) : super(key: key);

  final NotificationAppLaunchDetails notificationAppLaunchDetails;

  bool get didNotificationLaunchApp =>
      notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;

  @override
  _ListadoMediPagState createState() => _ListadoMediPagState();
}

class _ListadoMediPagState extends State<ListadoMediPag> {
  List<Medicamento> medicamentos = [];

  NotificationAppLaunchDetails notificationAppLaunchDetails;

  @override
  void initState() {
    _cargarDatos();
    super.initState();
    notificationAppLaunchDetails = widget.notificationAppLaunchDetails;
    _requestPermissions();
    _configureDidReceiveLocalNotificationSubject(notificationAppLaunchDetails);
    _configureSelectNotificationSubject();
  }

  void _requestPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void _configureDidReceiveLocalNotificationSubject(
      NotificationAppLaunchDetails notificationAppLaunchDetails) {
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body)
              : null,
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                await Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        ListadoActualPag(receivedNotification.payload),
                  ),
                );
              },
              child: const Text('Ok'),
            )
          ],
        ),
      );
    });
  }

  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String payload) async {
      await Navigator.pushNamed(context, ListadoActualPag.ROUTE);
    });
  }

  @override
  void dispose() {
    didReceiveLocalNotificationSubject.close();
    selectNotificationSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
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
    return GestureDetector(
      child: Card(
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
                          ProveedorDB.borrarMedi(medicamentos[i]);
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
            ],
          ),
        ),
      ),
      onTap: () {
        Navigator.pushNamed(context, ListadoAlarmPag.ROUTE,
                arguments: medicamentos.length > 0 ? medicamentos[i] : null)
            .then((value) => setState(() {
                  //_cargarDatos();
                }));
      },
    );
  }
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
                    image: AssetImage(
                        'assets/img/remember_medicament_logo_567.jpg'),
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
            title: Text("Borrar Tablas"),
            onTap: () {
              //ProveedorDB.borrarTablas();
              AlertDialog(
                content: Text(
                    "¿Estás seguro de que quieres eliminar TODAS LAS TABLAS?"),
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
                      ProveedorDB.borrarTablas();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          ),
          new ListTile(
            title: Text("ALARMA"),
            onTap: () {
              Navigator.pushNamed(context, AlarmaManagerExampleApp2.ROUTE);
            },
          )
        ],
      ),
    );
  }
}
