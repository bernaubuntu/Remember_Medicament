import 'package:remember_medicament/modelos/alarma_info.dart';
import 'package:remember_medicament/modelos/medicamento.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ProveedorDB {
  static final nombreBBDD = 'medicamentos';
  static final nombreTablaMedi = 'medicamentos';
  static final nombreTablaAlarm = 'alarma';

  static Future<Database> _abrirDB() async {
    //print(join(await getDatabasesPath(), 'medicamentos.db'));
    return openDatabase(join(await getDatabasesPath(), nombreBBDD + '.db'),
        onCreate: (db, version) async {
      var batch = db.batch();
      // Creamos todas las tablas
      _crearTablaMedicamentosV1(batch);
      _crearTablaAlarmaV1(batch);
      await batch.commit();
    }, version: 1);
  }

  static void _crearTablaMedicamentosV1(Batch batch) {
    batch.execute('DROP TABLE IF EXISTS $nombreTablaMedi');
    batch.execute('''CREATE TABLE $nombreTablaMedi (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    cn TEXT,
    nombre TEXT,
    contenido TEXT,
    rutaImagen TEXT
)''');
  }

  static Future<void> borrarTablas() async {
    Database database = await _abrirDB();
    var batch = database.batch();
    _crearTablaMedicamentosV1(batch);
    _crearTablaAlarmaV1(batch);
    return await batch.commit();
  }

  static Future<void> insertarMedi(Medicamento medicamento) async {
    Database database = await _abrirDB();
    return await database.insert(nombreTablaMedi, medicamento.toMap());
  }

  static Future<void> borrarMedi(Medicamento medicamento) async {
    Database database = await _abrirDB();
    return await database
        .delete(nombreTablaMedi, where: 'id = ?', whereArgs: [medicamento.id]);
  }

  static Future<void> actualizarMedi(Medicamento medicamento) async {
    Database database = await _abrirDB();
    return await database.update(nombreTablaMedi, medicamento.toMap(),
        where: 'id = ?', whereArgs: [medicamento.id]);
  }

  static Future<List<Medicamento>> medicamentos() async {
    Database database = await _abrirDB();

    final List<Map<String, dynamic>> medicamentosMap =
        await database.query(nombreTablaMedi);

    //for (var n in medicamentosMap) {
    //print('____' + n['nombre']);
    //}

    return List.generate(
        medicamentosMap.length,
        (i) => Medicamento(
            id: medicamentosMap[i]['id'],
            cn: medicamentosMap[i]['cn'],
            nombre: medicamentosMap[i]['nombre'],
            contenido: medicamentosMap[i]['contenido'],
            rutaImagen: medicamentosMap[i]['rutaImagen']));
  }

  static Future<List<Medicamento>> medicamentosActual() async {
    Database database = await _abrirDB();

    final List<Map<String, dynamic>> medicamentosMap = await database.rawQuery(
        'SELECT M.* FROM ' +
            nombreTablaMedi +
            ' M JOIN ' +
            nombreTablaAlarm +
            ' A ON M.id = A.idmed WHERE A.activo = 1');

    return List.generate(
        medicamentosMap.length,
        (i) => Medicamento(
            id: medicamentosMap[i]['id'],
            cn: medicamentosMap[i]['cn'],
            nombre: medicamentosMap[i]['nombre'],
            contenido: medicamentosMap[i]['contenido'],
            rutaImagen: medicamentosMap[i]['rutaImagen']));
  }

  static Future<int> valorMaxIDMedi() async {
    Database database = await _abrirDB();
    return Sqflite.firstIntValue(
        await database.rawQuery('SELECT MAX(id) FROM ' + nombreTablaMedi));
  }

  static Future<int> valorMinIDMedi() async {
    Database database = await _abrirDB();
    return Sqflite.firstIntValue(
        await database.rawQuery('SELECT MIN(id) FROM ' + nombreTablaMedi));
  }

  ///////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////
  static void _crearTablaAlarmaV1(Batch batch) {
    batch.execute('DROP TABLE IF EXISTS $nombreTablaAlarm');
    batch.execute('''CREATE TABLE $nombreTablaAlarm (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    idmed INTEGER not null,
    titulo TEXT not null,
    hora INTEGER not null,
    minuto INTEGER not null,
    lunes INTEGER,
    martes INTEGER,
    miercoles INTEGER,
    jueves INTEGER,
    viernes INTEGER,
    sabado INTEGER,
    domingo INTEGER,
    activo INTEGER,
    foreign key(idmed) references $nombreTablaMedi(id)
)''');
  }

  static Future<void> insertarAlarm(AlarmaInfo alarmaInfo) async {
    Database database = await _abrirDB();
    return await database.insert('$nombreTablaAlarm', alarmaInfo.toMap());
  }

  static Future<void> borrarAlarm(AlarmaInfo alarmaInfo) async {
    Database database = await _abrirDB();
    return await database.delete('$nombreTablaAlarm',
        where: 'id = ?', whereArgs: [alarmaInfo.id]);
  }

  static Future<void> actualizarAlarm(AlarmaInfo alarmaInfo) async {
    Database database = await _abrirDB();
    return await database.update('$nombreTablaAlarm', alarmaInfo.toMap(),
        where: 'id = ?', whereArgs: [alarmaInfo.id]);
  }

  static Future<List<AlarmaInfo>> alarmasTodas() async {
    Database database = await _abrirDB();

    final List<Map<String, dynamic>> alarmaMap =
        await database.query('$nombreTablaAlarm');

    //for (var n in alarmaMap) {
    //print('____' + n['titulo']);
    //}

    return List.generate(
        alarmaMap.length,
        (i) => AlarmaInfo(
            id: alarmaMap[i]['id'],
            idmed: alarmaMap[i]['idmed'],
            titulo: alarmaMap[i]['titulo'],
            lunes: alarmaMap[i]['lunes'],
            martes: alarmaMap[i]['martes'],
            miercoles: alarmaMap[i]['miercoles'],
            jueves: alarmaMap[i]['jueves'],
            viernes: alarmaMap[i]['viernes'],
            sabado: alarmaMap[i]['sabado'],
            domingo: alarmaMap[i]['domingo'],
            activo: alarmaMap[i]['activo']));
  }

  static Future<int> valorMaxIDAlarma() async {
    Database database = await _abrirDB();
    return Sqflite.firstIntValue(
        await database.rawQuery('SELECT MAX(id) FROM ' + nombreTablaAlarm));
  }

  static Future<int> valorMinIDAlarma() async {
    Database database = await _abrirDB();
    return Sqflite.firstIntValue(
        await database.rawQuery('SELECT MIN(id) FROM ' + nombreTablaAlarm));
  }

  static Future<List<AlarmaInfo>> alarmaMedicamentos(
      Medicamento medicamento) async {
    Database database = await _abrirDB();
    int valor = -1;
    if (medicamento != null) {
      valor = medicamento.id;
    }
    final List<Map<String, dynamic>> alarmaMap = await database
        .query('$nombreTablaAlarm', where: 'idmed = ?', whereArgs: [valor]);

    //for (var n in alarmaMap) {
    //print('____' + n['titulo']);
    //}

    return List.generate(
        alarmaMap.length,
        (i) => AlarmaInfo(
            id: alarmaMap[i]['id'],
            idmed: alarmaMap[i]['idmed'],
            titulo: alarmaMap[i]['titulo'],
            hora: alarmaMap[i]['hora'],
            minuto: alarmaMap[i]['minuto'],
            lunes: alarmaMap[i]['lunes'],
            martes: alarmaMap[i]['martes'],
            miercoles: alarmaMap[i]['miercoles'],
            jueves: alarmaMap[i]['jueves'],
            viernes: alarmaMap[i]['viernes'],
            sabado: alarmaMap[i]['sabado'],
            domingo: alarmaMap[i]['domingo'],
            activo: alarmaMap[i]['activo']));
  }

  static Future<void> desactivarTodasAlarmas() async {
    Database database = await _abrirDB();
    var map2 = {"activo": 0};
    return await database.update('$nombreTablaAlarm', map2);
  }

  static Future<void> desactivarTodasAlarmasMedi(int id) async {
    Database database = await _abrirDB();
    var map2 = {"activo": 0};
    return await database
        .update('$nombreTablaAlarm', map2, where: 'idmed = ?', whereArgs: [id]);
  }
}
