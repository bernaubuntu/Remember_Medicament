import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:remember_medicament/paginas/guardar_alarm_pag.dart';
import 'package:remember_medicament/paginas/guardar_detalles_pag.dart';
import 'package:remember_medicament/paginas/listado_actual_pag.dart';
import 'package:remember_medicament/paginas/listado_alarm_detalles_grupo_pag.dart';
import 'package:remember_medicament/paginas/listado_alarm_pag.dart';
import 'package:remember_medicament/paginas/listado_medi_pag.dart';
import 'package:remember_medicament/paginas/guardar_medi_pag.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// The [SharedPreferences] key to access the alarm fire count.
const String countKey = 'count';

/// The name associated with the UI isolate's [SendPort].
const String isolateName = 'isolate';

/// A port used to communicate from a background isolate to the UI isolate.
final ReceivePort port = ReceivePort();

/// Global [SharedPreferences] object.
SharedPreferences prefs;

// Modificacion
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

//const MethodChannel platform = MethodChannel('samples.flutter.dev/remember_medicament');

class ReceivedNotification {
  ReceivedNotification({
    this.id,
    this.title,
    this.body,
    this.payload,
  });

  final int id;
  final String title;
  final String body;
  final String payload;
}

String selectedNotificationPayload;

// Fin modificacion
Future<void> main() async {
  String initialRoute = ListadoMediPag.ROUTE;
  // needed if you intend to initialize in the `main` function
  WidgetsFlutterBinding.ensureInitialized();

  await _configureLocalTimeZone();

  final NotificationAppLaunchDetails notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    selectedNotificationPayload = notificationAppLaunchDetails.payload;
    if (selectedNotificationPayload != null) {
      initialRoute = ListadoActualPag.ROUTE;
    }
    flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  }

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('launcher_icon');

  /// Note: permissions aren't requested here just to demonstrate that can be
  /// done later
  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          onDidReceiveLocalNotification:
              (int id, String title, String body, String payload) async {
            didReceiveLocalNotificationSubject.add(ReceivedNotification(
                id: id, title: title, body: body, payload: payload));
          });
  const MacOSInitializationSettings initializationSettingsMacOS =
      MacOSInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false);
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
    selectedNotificationPayload = payload;
    selectNotificationSubject.add(payload);
  });

  //runApp(MyApp());

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Remember Medicament',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: initialRoute,
      routes: <String, WidgetBuilder>{
        ListadoMediPag.ROUTE: (_) =>
            ListadoMediPag(notificationAppLaunchDetails),
        ListadoActualPag.ROUTE: (_) =>
            ListadoActualPag(selectedNotificationPayload),
        GuardarMediPag.ROUTE: (_) => GuardarMediPag(),
        GuardarDetallesPag.ROUTE: (_) => GuardarDetallesPag(),
        ListadoAlarmPag.ROUTE: (_) =>
            ListadoAlarmPag(notificationAppLaunchDetails),
        GuardarAlarmPag.ROUTE: (_) => GuardarAlarmPag(),
        ListadoAlarmDetallesGrupoPag.ROUTE: (_) =>
            ListadoAlarmDetallesGrupoPag(),
      },
    ),
  );
}

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(currentTimeZone));
}

/*
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
      initialRoute: initialRoute,
      routes: <String, WidgetBuilder>{
        ListadoMediPag.ROUTE: (_) =>
            ListadoMediPag(notificationAppLaunchDetails),
        //SecondPage.routeName: (_) => SecondPage(selectedNotificationPayload)
        GuardarMediPag.ROUTE: (_) => GuardarMediPag(),
        //AlarmManagerExampleApp2.ROUTE: (_) => AlarmManagerExampleApp2(),
        ListadoAlarmPag.ROUTE: (_) =>
            ListadoAlarmPag(notificationAppLaunchDetails),
        GuardarAlarmPag.ROUTE: (_) => GuardarAlarmPag(),
        GuardarAlarm2Pag.ROUTE: (_) =>
            GuardarAlarm2Pag(notificationAppLaunchDetails),
        AlarmaManagerExampleApp2.ROUTE: (_) =>
            AlarmaManagerExampleApp2(notificationAppLaunchDetails),
      },
    );
  }
}
*/
