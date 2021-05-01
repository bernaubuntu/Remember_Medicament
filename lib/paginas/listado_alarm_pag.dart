import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:remember_medicament/database/proveedor_db.dart';
//import 'package:remember_medicament/modelos/medicamento.dart';
import 'package:remember_medicament/modelos/alarma_info.dart';
import 'package:remember_medicament/modelos/medicamento.dart';
//import 'package:remember_medicament/paginas/alarm_manager_pag.dart';
import 'package:remember_medicament/paginas/guardar_medi_pag.dart';
import 'package:remember_medicament/paginas/guardar_alarm2_pag.dart';
import 'package:remember_medicament/utilidades/utiles.dart';
import 'package:remember_medicament/widgets/alarma_item.dart';

import '../main.dart';
//import 'package:remember_medicament/paginas/alarm_manager_example.dart';

class ListadoAlarmPag extends StatelessWidget {
  static const String ROUTE = '/alarmapag';

  const ListadoAlarmPag(
    this.notificationAppLaunchDetails, {
    Key key,
  }) : super(key: key);

  final NotificationAppLaunchDetails notificationAppLaunchDetails;

  bool get didNotificationLaunchApp =>
      notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;
  @override
  Widget build(BuildContext context) {
    return _MiListadoAlarm();
  }
}

class _MiListadoAlarm extends StatefulWidget {
  @override
  __MiListadoAlarmState createState() => __MiListadoAlarmState();
}

class __MiListadoAlarmState extends State<_MiListadoAlarm> {
  List<AlarmaInfo> alarmaInfo = [];
  Medicamento medicamento;

  MiElementoPopup elemento_seleccionado = elecciones[0];

  _seleccionado(MiElementoPopup elemento) {
    switch (elemento.id) {
      case 0: // Notificaciones pendientes
        _consultarNotificacionesPendientes();
        break;
      case 1: // Cancelar Notificación
        _cancelarNotificacion(0);
        break;
      case 2: // Cancelar Todas las notificaciones
        _cancelarTodasNotificaciones();
        break;
      case 3: // Notificaciones Activas
        _getNotificacionesActivas();
        break;
      default:
    }
    setState(() {
      elemento_seleccionado = elemento;
    });
  }

  @override
  void initState() {
    _cargarDatos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    medicamento = ModalRoute.of(context).settings.arguments;
    _cargarDatos();
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, GuardarAlarm2Pag.ROUTE,
                  arguments: AlarmaInfo.vacioMedi(medicamento))
              .then((value) => setState(() {
                    _cargarDatos();
                  }));
        },
      ),
      appBar: AppBar(
        title: Text('Listado de Alarmas'),
        actions: [
          PopupMenuButton<MiElementoPopup>(
            elevation: 3.2,
            initialValue: elecciones[0],
            onCanceled: () {
              print('Elemento cancelado');
            },
            tooltip: '',
            onSelected: _seleccionado,
            itemBuilder: (BuildContext context) {
              return elecciones.map((MiElementoPopup elegido) {
                return PopupMenuItem<MiElementoPopup>(
                  value: elegido,
                  child: Text(elegido.titulo),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
        child: ListView.builder(
          itemCount: alarmaInfo.length,
          itemBuilder: (_, i) => _crearElemento(i),
        ),
      ),
    );
  }

  Future<void> _consultarNotificacionesPendientes() async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    for (var listado in pendingNotificationRequests) {
      print(listado.id);
      print(listado.title);
      print(listado.body);
      print(listado.payload);
    }

    if (pendingNotificationRequests.length == 0) {
      const String channelId = 'ID de canal de notificación diaria';

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.deleteNotificationChannel(channelId);
    }

    final List<AndroidNotificationChannel> channels =
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            .getNotificationChannels();
    for (var canal in channels) {
      print('*******************');
      print(canal.groupId);
      print(canal.id);
      print(canal.name);
      print(canal.description);
      print(canal.importance.value);
      print('------------------');
    }
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Text(
            '${pendingNotificationRequests.length} solicitudes de notificaciones '
            'pendientes'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelarNotificacion(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> _cancelarTodasNotificaciones() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> _cancelarNotificacionTag(int id, String texto) async {
    await flutterLocalNotificationsPlugin.cancel(id, tag: texto);
  }

  Future<void> _getNotificacionesActivas() async {
    final List<ActiveNotification> activeNotifications =
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            .getActiveNotifications();
    for (var activas in activeNotifications) {
      print('************************');
      print(activas.id);
      print(activas.channelId);
      print(activas.title);
      print(activas.body);
      print('------------------------');
    }
  }

  Future<void> _cargarDatos() async {
    List<AlarmaInfo> auxAlarmaInfo =
        await ProveedorDB.alarmaMedicamentos(medicamento);
    if (this.mounted) {
      setState(() {
        //Your state change code goes here
        alarmaInfo = auxAlarmaInfo;
      });
    }

    //setState(() {});
  }

  Future<void> _desactivarAlarma(AlarmaInfo alarmaInfo) async {
    int valorAlarma = await Utiles.valorIdAlarma(alarmaInfo.id);
    for (var i = 0; i < 8; i++) {
      await _cancelarNotificacion(valorAlarma + i);
    }
  }

  Future<void> _desactivarTodasAlarmasMedi(AlarmaInfo alarmaInfo) async {
    await ProveedorDB.desactivarTodasAlarmasMedi(alarmaInfo.idmed);
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
                      "¿Estás seguro de que quieres eliminar ${alarmaInfo[i].titulo}?"),
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
                        _desactivarAlarma(alarmaInfo[i]);
                        ProveedorDB.borrarAlarm(alarmaInfo[i]);
                        if (this.mounted) {
                          setState(() {
                            //Your state change code goes here
                            _cargarDatos();
                          });
                        }
                        //setState(() {});
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            alarmaItem(alarmaInfo[i].hora.toString(),
                alarmaInfo[i].minuto.toString(), context, alarmaInfo[i]),
            /*
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      alarmaInfo[i].titulo,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Roboto',
                        letterSpacing: 0.5,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      alarmaInfo[i].idmed.toString(),
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
            */
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MaterialButton(
                  //color: Colors.amber,
                  onPressed: () {
                    Navigator.pushNamed(context, GuardarAlarm2Pag.ROUTE,
                            arguments:
                                alarmaInfo.length > 0 ? alarmaInfo[i] : null)
                        .then((value) => setState(() {
                              _cargarDatos();
                            }));
                  },
                  child: Icon(
                    Icons.edit,
                    color: Colors.green,
                  ),
                ),
                /*
                MaterialButton(
                  //color: Colors.amber,
                  onPressed: () {
                    Navigator.pushNamed(context, GuardarAlarm2Pag.ROUTE,
                            arguments:
                                alarmaInfo.length > 0 ? alarmaInfo[i] : null)
                        .then((value) => setState(() {
                              _cargarDatos();
                            }));
                  },
                  child: Icon(
                    Icons.edit,
                    color: Colors.green,
                  ),
                ),
                */
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MiElementoPopup {
  MiElementoPopup({this.titulo, this.id});
  String titulo;
  int id;
}

List<MiElementoPopup> elecciones = <MiElementoPopup>[
  MiElementoPopup(titulo: 'Notificaciones pendientes', id: 0),
  MiElementoPopup(titulo: 'Cancelar Notificación', id: 1),
  MiElementoPopup(titulo: 'Cancelar Todas las notificaciones', id: 2),
  MiElementoPopup(titulo: 'Notificaciones Activas', id: 3),
];
