import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:remember_medicament/database/proveedor_db.dart';
import 'package:remember_medicament/modelos/alarma_info.dart';
import 'package:remember_medicament/utilidades/utiles.dart';
import 'package:remember_medicament/widgets/circulo_dia.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/standalone.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

import '../main.dart';

class GuardarAlarmPag extends StatefulWidget {
  static const String ROUTE = '/guardaralarm2';

  @override
  _GuardarAlarmPagState createState() => _GuardarAlarmPagState();
}

class _GuardarAlarmPagState extends State<GuardarAlarmPag> {
  final _formkey = GlobalKey<FormState>();

  final tituloController = TextEditingController();

  String estadoAlarma;

  TimeOfDay _horaSeleccionada;
  ValueChanged<TimeOfDay> seleccionarHora;
  bool primero;

  @override
  void initState() {
    primero = true;
    _horaSeleccionada = new TimeOfDay(
        hour: TimeOfDay.now().hour, minute: TimeOfDay.now().minute);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AlarmaInfo alarmaInfo = ModalRoute.of(context).settings.arguments;
    if (alarmaInfo.id != null && primero) {
      _horaSeleccionada = new TimeOfDay(
        hour: alarmaInfo.hora,
        minute: alarmaInfo.minuto,
      );
      _iniciar(alarmaInfo);
      primero = false;
    }
    if (primero) {
      _iniciar(alarmaInfo);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Guardar alarma'),
      ),
      body: GestureDetector(
        onTap: () {
          final FocusScopeNode focus = FocusScope.of(context);
          if (!focus.hasPrimaryFocus && focus.hasFocus) {
            FocusManager.instance.primaryFocus.unfocus();
          }
        },
        child: Container(
          child: _construirForm(alarmaInfo),
        ),
      ),
    );
  }

  _iniciar(AlarmaInfo alarmaInfo) {
    if (alarmaInfo.titulo == null) {
      alarmaInfo.titulo = 'Nuevo Título';
    }
    tituloController.text = alarmaInfo.titulo;
    if (alarmaInfo.activo != 0) {
      estadoAlarma = 'activo';
    } else {
      estadoAlarma = 'no activo';
    }
  }

  Widget _construirForm(AlarmaInfo alarmaInfo) {
    return Container(
      padding: EdgeInsets.all(5),
      child: ListView(
        scrollDirection: Axis.vertical,
        children: [
          Form(
            key: _formkey,
            child: Column(
              children: <Widget>[
                SizedBox(height: 10.0),
                TextFormField(
                  maxLines: 2,
                  maxLength: 80,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'El valor no puede estar vacio';
                    }
                    return null;
                  },
                  controller: tituloController,
                  decoration: InputDecoration(
                    labelText: 'Título de la alarma',
                    border:
                        OutlineInputBorder(), //borderRadius: BorderRadius.all(Radius.circular(20))
                  ),
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 10.0,
                    ),
                    GestureDetector(
                      child: Text(
                        //_horaSeleccionada != null
                        //    ? '_horaSeleccionada.format(context)'
                        //    : '_horaSeleccionada',

                        (_horaSeleccionada.hour < 10 ? '0' : '') +
                            _horaSeleccionada.hour.toString() +
                            ':' +
                            (_horaSeleccionada.minute < 10 ? '0' : '') +
                            _horaSeleccionada.minute.toString(),

                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 40.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      onTap: () {
                        _seleccionarHora(context);
                      },
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      estadoAlarma,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Switch(
                      value: (alarmaInfo.activo == 0) ? false : true,
                      onChanged: (value) {
                        setState(() {
                          alarmaInfo.activo = (value) ? 1 : 0;
                          if (alarmaInfo.activo != 0) {
                            estadoAlarma = 'activo';
                          } else {
                            estadoAlarma = 'no activo';
                          }
                        });
                      },
                      activeTrackColor: Theme.of(context).backgroundColor,
                      activeColor: Theme.of(context).accentColor,
                    ),
                  ],
                ),
                SizedBox(
                  height: 5.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    GestureDetector(
                      child: circuloDia('Lun', context, alarmaInfo.lunes),
                      onTap: () {
                        if (alarmaInfo.lunes == 0) {
                          alarmaInfo.lunes = 1;
                        } else {
                          alarmaInfo.lunes = 0;
                        }
                        setState(() {});
                      },
                    ),
                    GestureDetector(
                      child: circuloDia('Mar', context, alarmaInfo.martes),
                      onTap: () {
                        if (alarmaInfo.martes == 0) {
                          alarmaInfo.martes = 1;
                        } else {
                          alarmaInfo.martes = 0;
                        }
                        setState(() {});
                      },
                    ),
                    GestureDetector(
                      child: circuloDia('Mie', context, alarmaInfo.miercoles),
                      onTap: () {
                        if (alarmaInfo.miercoles == 0) {
                          alarmaInfo.miercoles = 1;
                        } else {
                          alarmaInfo.miercoles = 0;
                        }
                        setState(() {});
                      },
                    ),
                    GestureDetector(
                      child: circuloDia('Jue', context, alarmaInfo.jueves),
                      onTap: () {
                        if (alarmaInfo.jueves == 0) {
                          alarmaInfo.jueves = 1;
                        } else {
                          alarmaInfo.jueves = 0;
                        }
                        setState(() {});
                      },
                    ),
                    GestureDetector(
                      child: circuloDia('Vie', context, alarmaInfo.viernes),
                      onTap: () {
                        if (alarmaInfo.viernes == 0) {
                          alarmaInfo.viernes = 1;
                        } else {
                          alarmaInfo.viernes = 0;
                        }
                        setState(() {});
                      },
                    ),
                    GestureDetector(
                      child: circuloDia('Sab', context, alarmaInfo.sabado),
                      onTap: () {
                        if (alarmaInfo.sabado == 0) {
                          alarmaInfo.sabado = 1;
                        } else {
                          alarmaInfo.sabado = 0;
                        }
                        setState(() {});
                      },
                    ),
                    GestureDetector(
                      child: circuloDia('Dom', context, alarmaInfo.domingo),
                      onTap: () {
                        if (alarmaInfo.domingo == 0) {
                          alarmaInfo.domingo = 1;
                        } else {
                          alarmaInfo.domingo = 0;
                        }
                        setState(() {});
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 2.0,
                  child: Container(
                    color: Colors.black38,
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      child: (alarmaInfo.id == null)
                          ? Text('Guardar')
                          : Text('Actualizar'),
                      onPressed: () {
                        if (_formkey.currentState.validate()) {
                          alarmaInfo.titulo = tituloController.text;
                          alarmaInfo.hora = _horaSeleccionada.hour;
                          alarmaInfo.minuto = _horaSeleccionada.minute;
                          if (alarmaInfo.id != null) {
                            //actualización
                            ProveedorDB.actualizarAlarm(alarmaInfo);
                            guardarAlarma(alarmaInfo);
                            Navigator.of(context).pop();
                          } else {
                            //Inserción
                            ProveedorDB.insertarAlarm(alarmaInfo);
                            guardarAlarma(alarmaInfo);
                            Navigator.of(context).pop();
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _seleccionarHora(BuildContext context) async {
    final TimeOfDay seleccionar = await showTimePicker(
      context: context,
      initialTime: _horaSeleccionada,
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child,
        );
      },
    );
    setState(() {
      if (seleccionar != null) {
        _horaSeleccionada = seleccionar;
      }
    });
  }

// prueba para que suene una alarma
  Future<void> _cancelarNotificacion(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> _desactivarAlarma(AlarmaInfo alarmaInfo) async {
    int valorAlarma = await Utiles.valorIdAlarma(alarmaInfo.id);
    if (valorAlarma != null) {
      for (var i = 0; i < 8; i++) {
        await _cancelarNotificacion(valorAlarma + i);
      }
    }
  }

  Future<void> _horarioAlarma(
      TZDateTime scheduledNotificationDateTime, AlarmaInfo alarmaInfo) async {
    await _desactivarAlarma(alarmaInfo);
    int cantidaddias = alarmaInfo.cantidadDias();

    int valorAlarma = await Utiles.valorIdAlarma(alarmaInfo.id);

    String objPayLoad = '{"idalarm":${alarmaInfo.id}}';

    if (alarmaInfo.activo == 1) {
      switch (cantidaddias) {
        case 0: // solo una vez
          await flutterLocalNotificationsPlugin.zonedSchedule(
              valorAlarma, //id,
              alarmaInfo.titulo,
              'solo una vez',
              scheduledNotificationDateTime,
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  'Canal_ID',
                  'Nombre_Canal',
                  'Descripcion_Canal',
                  priority: Priority.high,
                  importance: Importance.high,
                  fullScreenIntent: true,
                  //tag: 'tag0',
                ),
              ),
              androidAllowWhileIdle: true,
              payload: objPayLoad, //'idalarm: ' + alarmaInfo.id.toString(),
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime);
          break;
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6: // solo los dias marcados

          bool diaActivo = false;
          for (var i = 0; i < 7; i++) {
            TZDateTime scheduledDate =
                scheduledNotificationDateTime.add(Duration(days: i));
            int posicion = scheduledDate.weekday;
            if (posicion == DateTime.monday && alarmaInfo.lunes == 1) {
              diaActivo = true;
            } else if (posicion == DateTime.tuesday && alarmaInfo.martes == 1) {
              diaActivo = true;
            } else if (posicion == DateTime.wednesday &&
                alarmaInfo.miercoles == 1) {
              diaActivo = true;
            } else if (posicion == DateTime.thursday &&
                alarmaInfo.jueves == 1) {
              diaActivo = true;
            } else if (posicion == DateTime.friday && alarmaInfo.viernes == 1) {
              diaActivo = true;
            } else if (posicion == DateTime.saturday &&
                alarmaInfo.sabado == 1) {
              diaActivo = true;
            } else if (posicion == DateTime.sunday && alarmaInfo.domingo == 1) {
              diaActivo = true;
            }
            if (diaActivo) {
              await flutterLocalNotificationsPlugin.zonedSchedule(
                  valorAlarma + scheduledDate.weekday, // id,
                  alarmaInfo.titulo,
                  '' + Utiles.diaSemana(scheduledDate.weekday),
                  scheduledDate,
                  const NotificationDetails(
                    android: AndroidNotificationDetails(
                      'Canal_ID',
                      'Nombre_Canal',
                      'Descripcion_Canal',
                      priority: Priority.high,
                      importance: Importance.high,
                      fullScreenIntent: true,
                    ),
                  ),
                  androidAllowWhileIdle: true,
                  payload: objPayLoad, //'idalarm: ' + alarmaInfo.id.toString(),
                  uiLocalNotificationDateInterpretation:
                      UILocalNotificationDateInterpretation.absoluteTime,
                  matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
            }
            diaActivo = false;
            scheduledDate.add(Duration(days: 1));
          }
          break;
        case 7: // todos los dias
          await flutterLocalNotificationsPlugin.zonedSchedule(
              valorAlarma, //id,
              alarmaInfo.titulo,
              'Todos los días',
              scheduledNotificationDateTime,
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  'Canal_ID',
                  'Nombre_Canal',
                  'Descripcion_Canal',
                  priority: Priority.high,
                  importance: Importance.high,
                  fullScreenIntent: true,
                ),
              ),
              androidAllowWhileIdle: true,
              payload: objPayLoad, //'idalarm: ' + alarmaInfo.id.toString(),
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
              matchDateTimeComponents: DateTimeComponents.time);
          break;
        default:
      }
    }
  }

  void guardarAlarma(AlarmaInfo alarmaInfo) async {
    TZDateTime horarioAlarmaFecha;
    final String currentTimeZone =
        await FlutterNativeTimezone.getLocalTimezone();

    final ahora = DateTime.now();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    var nuevaFecha = tz.TZDateTime.local(
        ahora.year, ahora.month, ahora.day, alarmaInfo.hora, alarmaInfo.minuto);
    if (nuevaFecha.isAfter(DateTime.now()))
      horarioAlarmaFecha = nuevaFecha;
    else
      horarioAlarmaFecha = nuevaFecha.add(Duration(days: 1));

    if (alarmaInfo.activo == 1) {
      await _horarioAlarma(horarioAlarmaFecha, alarmaInfo);
    } else {
      await _desactivarAlarma(alarmaInfo);
    }
  }
}
