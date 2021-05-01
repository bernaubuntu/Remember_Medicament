import 'package:flutter/material.dart';
import 'package:remember_medicament/database/proveedor_db.dart';
import 'package:remember_medicament/modelos/alarma_info.dart';
import 'package:remember_medicament/widgets/circulo_dia.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/standalone.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class GuardarAlarmPag extends StatefulWidget {
  static const String ROUTE = '/guardaralarm';

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
  Widget build(BuildContext context) {
    AlarmaInfo alarmaInfo = ModalRoute.of(context).settings.arguments;
    if (alarmaInfo.id != null && primero) {
      _horaSeleccionada = new TimeOfDay(
        hour: alarmaInfo.hora,
        minute: alarmaInfo.minuto,
      );
      primero = false;
    }

    _iniciar(alarmaInfo);

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
                          print('Título: ' + tituloController.text);
                          print(_horaSeleccionada.hour);
                          print(_horaSeleccionada.minute);
                          print('Guardar formulario');
                          print(alarmaInfo.toJson());
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

  void horarioAlarma(
      TZDateTime scheduledNotificationDateTime, AlarmaInfo alarmaInfo) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'alarm_notif',
      'alarm_notif',
      'Channel for Alarm notification',
      icon: 'launcher_icon',
      playSound: true,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('a_long_cold_sting'),
      largeIcon: DrawableResourceAndroidBitmap('launcher_icon'),
      visibility: NotificationVisibility.public,
      fullScreenIntent: true,
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        sound: 'a_long_cold_sting.wav',
        presentAlert: true,
        presentBadge: true,
        presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Oficina',
      alarmaInfo.titulo,
      scheduledNotificationDateTime,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
    );
  }

  void guardarAlarma(AlarmaInfo alarmaInfo) async {
    TZDateTime horarioAlarmaFecha;
    final String currentTimeZone =
        await FlutterNativeTimezone.getLocalTimezone();

    final List<String> availableTimezones =
        await FlutterNativeTimezone.getAvailableTimezones();

    print(currentTimeZone);
    final ahora = DateTime.now();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    var nuevaFecha = tz.TZDateTime.local(
        ahora.year, ahora.month, ahora.day, alarmaInfo.hora, alarmaInfo.minuto);
    if (nuevaFecha.isAfter(DateTime.now()))
      horarioAlarmaFecha = nuevaFecha;
    else
      horarioAlarmaFecha = nuevaFecha.add(Duration(days: 1));

    horarioAlarma(horarioAlarmaFecha, alarmaInfo);
  }
}
