import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:remember_medicament/database/proveedor_db.dart';
import 'package:remember_medicament/modelos/medicamento.dart';
import 'package:remember_medicament/paginas/guardar_medi_pag.dart';
import 'package:remember_medicament/paginas/listado_actual_pag.dart';
import 'package:remember_medicament/paginas/listado_alarm_pag.dart';
import 'package:remember_medicament/widgets/medi_imagen.dart';

import '../main.dart';

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
  var estadoStorage;

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
    _preguntarPermisos();
  }

  void _preguntarPermisos() async {
    /*
    // para comprobar varios permisos al mismo tiempo
    Map statuses = await [
      Permission.camera,
      Permission.storage,
    ].request();

    print(statuses[Permission.storage]);

    if (await Permission.storage.request().isGranted) {
      // Permiso concedido
    }
    */
    estadoStorage = await Permission.storage.status;
    var estadoCamara = await Permission.camera.status;
    print('Estado Storage: ' + estadoStorage.toString());
    print('Estado Camara: ' + estadoCamara.toString());

    if (estadoStorage != PermissionStatus.granted) {
      final snackBar = SnackBar(
        content: Text("Es necesario dar permiso al storage"),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(5.00),
          ),
        ),
        action: SnackBarAction(
          textColor: Colors.white,
          label: 'Settings',
          onPressed: () {
            openAppSettings();
          },
        ), //behavior: SnackBarBehavior.floating,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
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
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(2.0, 4.0, 2.0, 1.0),
            width: MediaQuery.of(context).size.width,
            height: 58.0,
            child: _contenedorEstatico(),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height >
                    MediaQuery.of(context).size.width
                ? MediaQuery.of(context).size.height * .8
                : MediaQuery.of(context).size.height * .63,
            padding: EdgeInsets.fromLTRB(5, 1, 5, 5),
            child: ListView.builder(
              itemCount: medicamentos.length,
              itemBuilder: (_, i) => _crearElemento(i),
            ),
          ),
        ],
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
                    mediImagen(medicamentos[i].rutaImagen),
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
    );
  }

  _contenedorEstatico() {
    if (estadoStorage != PermissionStatus.granted) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Card(
            color: Colors.green,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: MaterialButton(
                onPressed: () {
                  Navigator.pushNamed(context, ListadoAlarmPag.ROUTE);
                },
                child: Icon(
                  Icons.access_alarms,
                  color: Colors.white,
                  size: 48,
                )),
          ),
          Card(
            color: Colors.green[400],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: MaterialButton(
                onPressed: () {
                  openAppSettings();
                },
                child: Icon(
                  Icons.settings_applications,
                  color: Colors.white,
                  size: 48,
                )),
          ),
        ],
      );
    }

    return Center(
      child: Card(
        color: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: MaterialButton(
            onPressed: () {
              Navigator.pushNamed(context, ListadoAlarmPag.ROUTE);
            },
            child: Icon(
              Icons.access_alarms,
              color: Colors.white,
              size: 48,
            )),
      ),
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
                "Medicamentos",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pushNamed(context, ListadoMediPag.ROUTE);
              },
            ),
          ),
          new ListTile(
            title: Text("Alarmas"),
            onTap: () {
              Navigator.pushNamed(context, ListadoAlarmPag.ROUTE);
            },
          ),
          /*
          new ListTile(
            title: Text("Pruebas"),
            onTap: () {
              openAppSettings();
            },
          ),
          */
        ],
      ),
    );
  }
}
