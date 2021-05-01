// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../main.dart';

String selectedNotificationPayload;

/// Example app for Espresso plugin.
class AlarmaManagerExampleApp2 extends StatefulWidget {
  const AlarmaManagerExampleApp2(
    this.notificationAppLaunchDetails, {
    Key key,
  }) : super(key: key);

  static const String ROUTE = '/alarma3';

  final NotificationAppLaunchDetails notificationAppLaunchDetails;

  bool get didNotificationLaunchApp =>
      notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;

  @override
  _AlarmaHomePageState createState() => _AlarmaHomePageState();
}

class _AlarmaHomePageState extends State<AlarmaManagerExampleApp2> {
  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _configureDidReceiveLocalNotificationSubject();
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

  void _configureDidReceiveLocalNotificationSubject() {
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
                    builder: (BuildContext context) => Text('HOLA'),
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
      await Navigator.pushNamed(context, '/secondPage');
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
    _iniciar();

    return Scaffold(
      appBar: AppBar(
        title: Text('Alarma Manager'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Center(
            child: Column(
              children: [
                PaddedElevatedButton(
                  buttonText: 'Mostrar notificación sencilla con carga útil',
                  onPressed: () async {
                    await _showNotification();
                  },
                ),
                PaddedElevatedButton(
                  buttonText:
                      'Programe una notificación diaria a las 10:00:00 am '
                      'en su zona horaria local',
                  onPressed: () async {
                    await _scheduleDailyTenAMNotification();
                  },
                ),
                PaddedElevatedButton(
                  buttonText: 'Consultar notificaciones pendientes',
                  onPressed: () async {
                    await _checkPendingNotificationRequests();
                  },
                ),
                PaddedElevatedButton(
                  buttonText: 'Cancelar Notificación',
                  onPressed: () async {
                    await _cancelNotification();
                  },
                ),
                PaddedElevatedButton(
                  buttonText: 'Cancela todas las notificaciones',
                  onPressed: () async {
                    await _cancelAllNotifications();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('vuestro canal id', 'vuestro canal name',
            'vuestro canal description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
        0, 'Título simple', 'Cuerpo simple', platformChannelSpecifics,
        payload: 'elemento x');
  }

  Future<void> _cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  Future<void> _cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> _checkPendingNotificationRequests() async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Text(
            '${pendingNotificationRequests.length} solicitudes de notificaciones '
            'pendientes'),
        actions: <Widget>[
          pendingNotificationRequests.length > 0
              ? Text(pendingNotificationRequests[0].toString())
              : Text('No hay'),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _repeatNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('ID de canal repetido',
            'nombre de canal repetido', 'descripción repetida');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.periodicallyShow(0, 'titulo repetido',
        'cuerpo repetido', RepeatInterval.everyMinute, platformChannelSpecifics,
        androidAllowWhileIdle: true);
  }

  Future<void> _scheduleDailyTenAMNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'título de la notificación programada diaria',
        'cuerpo de notificación programado diariamente',
        _nextInstanceOfTenAM(),
        const NotificationDetails(
          android: AndroidNotificationDetails(
              'ID de canal de notificación diaria',
              'nombre del canal de notificación diaria',
              'descripción de la notificación diaria'),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  tz.TZDateTime _nextInstanceOfTenAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 14, 37);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    print('$scheduledDate');
    return scheduledDate;
  }

  _crearElemento(
      int i, List<PendingNotificationRequest> pendingNotificationRequests) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      color: Colors.blue.shade100,
      child: Text(jsonEncode(pendingNotificationRequests)),
    );
  }

  _iniciar() {}

  Widget _construir() {
    return Container(
      padding: EdgeInsets.all(5),
      child: Text(
        'estadoAlarma',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class PaddedElevatedButton extends StatelessWidget {
  const PaddedElevatedButton({
    this.buttonText,
    this.onPressed,
    Key key,
  }) : super(key: key);

  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text(buttonText),
        ),
      );
}
