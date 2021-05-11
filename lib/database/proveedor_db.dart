import 'package:remember_medicament/modelos/alarma_detalles.dart';
import 'package:remember_medicament/modelos/alarma_detalles_grupo.dart';
import 'package:remember_medicament/modelos/alarma_info.dart';
import 'package:remember_medicament/modelos/medicamento.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ProveedorDB {
  static final nombreBBDD = 'medicamentos';
  static final nombreTablaMedi = 'medicamentos';
  static final nombreTablaAlarm = 'alarma';
  static final nombreTablaAlarmDeta = 'alarmadetalles';

  /// Let's use FOREIGN KEY constraints
  static Future onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  static Future<Database> _abrirDB() async {
    //print(join(await getDatabasesPath(), 'medicamentos.db'));
    return openDatabase(
      join(await getDatabasesPath(), nombreBBDD + '.db'),
      onCreate: (db, version) async {
        var batch = db.batch();
        // Creamos todas las tablas
        _crearTablaMedicamentosV2(batch);
        _crearTablaAlarmaV2(batch);
        _crearTablaAlarmaDetallesV2(batch);
        await batch.commit();
      },
      version: 2,
      onConfigure: onConfigure,
      onUpgrade: (db, oldVersion, newVersion) async {
        var batch = db.batch();
        if (oldVersion == 1) {
          // We update existing table and create the new tables
          _actualizaTablaAlarmaV1toV2(batch);
          _crearTablaAlarmaV2(batch);
          //_crearTablaMedicamentosV2(batch);
          _crearTablaAlarmaDetallesV2(batch);
        }
        await batch.commit();
      },
      onDowngrade: onDatabaseDowngradeDelete,
    );
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

  static void _crearTablaMedicamentosV2(Batch batch) {
    batch.execute('DROP TABLE IF EXISTS $nombreTablaMedi');
    batch.execute('''CREATE TABLE $nombreTablaMedi (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    cn TEXT,
    nombre TEXT,
    contenido TEXT,
    rutaImagen TEXT
)''');
  }

  static Future<void> borrarTablasSolo() async {
    Database database = await _abrirDB();
    var batch = database.batch();
    batch.execute('DROP TABLE $nombreTablaAlarmDeta');
    batch.execute('DROP TABLE $nombreTablaAlarm');
    batch.execute('DROP TABLE $nombreTablaMedi');
    return await batch.commit();
  }

  static Future<void> borrarTablas() async {
    Database database = await _abrirDB();
    var batch = database.batch();
    //_crearTablaMedicamentosV1(batch);
    //_crearTablaAlarmaV1(batch);
    _crearTablaMedicamentosV2(batch);
    _crearTablaAlarmaV2(batch);
    _crearTablaAlarmaDetallesV2(batch);
    return await batch.commit();
  }

  static Future<void> listarTablas() async {
    Database database = await _abrirDB();
    var batch = database.batch();
    List<Map> rec;
    List<Map> rec2;
    List<String> listaTablas;
    //rec = await tableNames();
    //rec2 = await tableColumns('medicamentos');
    listaTablas = await tableList();
    //print(rec.asMap());
    //print(rec2.asMap());
    print(listaTablas.asMap());
    if (listaTablas.contains(nombreTablaMedi)) {
      print('Existe $nombreTablaMedi');
      rec2 = await tableColumns('$nombreTablaMedi');
      print(rec2);
    } else {
      print('No existe $nombreTablaMedi');
      //_crearTablaMedicamentosV2(batch);
    }
    if (listaTablas.contains(nombreTablaAlarm)) {
      print('Existe $nombreTablaAlarm');
      rec2 = await tableColumns('$nombreTablaAlarm');
      print(rec2);
    } else {
      print('No existe $nombreTablaAlarm');
      //_crearTablaAlarmaV2(batch);
    }
    if (listaTablas.contains(nombreTablaAlarmDeta)) {
      print('Existe $nombreTablaAlarmDeta');
      rec2 = await tableColumns('$nombreTablaAlarmDeta');
      print(rec2);
    } else {
      print('No existe $nombreTablaAlarmDeta');
      //_crearTablaAlarmaDetallesV2(batch);
    }
    return await batch.commit();
  }

  static Future<List<Map<String, dynamic>>> tableNames() async {
    Database database = await _abrirDB();
    return database
        .rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
  }

  static Future<List<Map<String, dynamic>>> tableColumns(String table) async {
    Database database = await _abrirDB();
    return database.rawQuery("pragma table_info('$table')");
  }

  static Future<List<String>> tableList() async {
    final List<Map<String, dynamic>> tables = await tableNames();

    final List<String> list = [];

    // Include android metadata table as well with 0; iOS then works.
    for (var i = 0; i < tables.length; i++) {
      list.add(tables[i]['name']);
    }
    return list;
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
              rutaImagen: medicamentosMap[i]['rutaImagen'],
            ));
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

  static Future<Medicamento> getMedicamento(int id) async {
    Database database = await _abrirDB();
    final List<Map<String, dynamic>> medicamentosMap = await database
        .query('$nombreTablaMedi', where: 'id = ?', whereArgs: [id]);

    //for (var n in alarmaMap) {
    //print('____' + n['titulo']);
    //}

    if (medicamentosMap.length == 1) {
      return Medicamento(
        id: medicamentosMap[0]['id'],
        cn: medicamentosMap[0]['cn'],
        nombre: medicamentosMap[0]['nombre'],
        contenido: medicamentosMap[0]['contenido'],
        rutaImagen: medicamentosMap[0]['rutaImagen'],
      );
    } else {
      return Medicamento.vacio();
    }
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

  static void _crearTablaAlarmaV2(Batch batch) {
    batch.execute('DROP TABLE IF EXISTS $nombreTablaAlarm');
    batch.execute('''CREATE TABLE $nombreTablaAlarm (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
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
    activo INTEGER
)''');
  }

  static void _actualizaTablaAlarmaV1toV2(Batch batch) {
    batch.execute('ALTER TABLE $nombreTablaAlarm RENAME TO alarma_anterior');
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

  static Future<AlarmaInfo> getAlarma(int id) async {
    Database database = await _abrirDB();
    final List<Map<String, dynamic>> alarmaMap = await database
        .query('$nombreTablaAlarm', where: 'id = ?', whereArgs: [id]);

    //for (var n in alarmaMap) {
    //print('____' + n['titulo']);
    //}

    if (alarmaMap.length == 1) {
      return AlarmaInfo(
        id: alarmaMap[0]['id'],
        titulo: alarmaMap[0]['titulo'],
        hora: alarmaMap[0]['hora'],
        minuto: alarmaMap[0]['minuto'],
        lunes: alarmaMap[0]['lunes'],
        martes: alarmaMap[0]['martes'],
        miercoles: alarmaMap[0]['miercoles'],
        jueves: alarmaMap[0]['jueves'],
        viernes: alarmaMap[0]['viernes'],
        sabado: alarmaMap[0]['sabado'],
        domingo: alarmaMap[0]['domingo'],
        activo: alarmaMap[0]['activo'],
      );
    } else {
      return AlarmaInfo.vacio();
    }
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
            //idmed: alarmaMap[i]['idmed'], // campo V1
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

/*
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
            //idmed: alarmaMap[i]['idmed'], //campo V1
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
*/
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

  static Future<void> desactivarAlarmas(int id) async {
    Database database = await _abrirDB();
    var map2 = {"activo": 0};
    return await database
        .update('$nombreTablaAlarm', map2, where: 'id = ?', whereArgs: [id]);
  }

  ///////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////
  /////modificado el on update cascade y on delete cascade
  static void _crearTablaAlarmaDetallesV2(Batch batch) {
    batch.execute('DROP TABLE IF EXISTS $nombreTablaAlarmDeta');
    batch.execute('''CREATE TABLE $nombreTablaAlarmDeta (
    iddetalles INTEGER PRIMARY KEY AUTOINCREMENT,
    idalarm INTEGER not null,
    idmed INTEGER not null,
    toma TEXT,
    observaciones TEXT,
    foreign key(idalarm) references $nombreTablaAlarm(id)
      ON UPDATE CASCADE
      ON DELETE CASCADE,
    foreign key(idmed) references $nombreTablaMedi(id)
      ON UPDATE CASCADE
      ON DELETE CASCADE
)''');
  }

  static Future<void> insertarAlarmDetalles(
      AlarmaDetalles alarmaDetalles) async {
    Database database = await _abrirDB();
    return await database.insert(
        '$nombreTablaAlarmDeta', alarmaDetalles.toMap());
  }

  static Future<void> borrarAlarmDetalles(AlarmaDetalles alarmaDetalles) async {
    Database database = await _abrirDB();
    return await database.delete('$nombreTablaAlarmDeta',
        where: 'iddetalles = ?', whereArgs: [alarmaDetalles.iddetalles]);
  }

  static Future<void> actualizarAlarmDetalles(
      AlarmaDetalles alarmaDetalles) async {
    Database database = await _abrirDB();
    return await database.update(
        '$nombreTablaAlarmDeta', alarmaDetalles.toMap(),
        where: 'iddetalles = ?', whereArgs: [alarmaDetalles.iddetalles]);
  }

  static Future<List<AlarmaDetalles>> alarmasDetalles(
      AlarmaInfo alarmaInfo) async {
    Database database = await _abrirDB();

    int valor = -1;
    if (alarmaInfo != null) {
      valor = alarmaInfo.id;
    }

    final List<Map<String, dynamic>> alarmaMap = await database.query(
      '$nombreTablaAlarmDeta',
      where: 'idalarm = ?',
      whereArgs: [valor],
    );

    //for (var n in alarmaMap) {
    //print('____' + n['titulo']);
    //}

    return List.generate(
        alarmaMap.length,
        (i) => AlarmaDetalles(
            iddetalles: alarmaMap[i]['iddetalles'],
            idalarm: alarmaMap[i]['idalarm'],
            idmed: alarmaMap[i]['idmed'],
            toma: alarmaMap[i]['toma'],
            observaciones: alarmaMap[i]['observaciones']));
  }

  static Future<List<AlarmaDetalles>> alarmasDetallesTodas() async {
    Database database = await _abrirDB();

    final List<Map<String, dynamic>> alarmaMap = await database.query(
      '$nombreTablaAlarmDeta',
    );

    //for (var n in alarmaMap) {
    //print('____' + n['titulo']);
    //}

    return List.generate(
        alarmaMap.length,
        (i) => AlarmaDetalles(
            iddetalles: alarmaMap[i]['iddetalles'],
            idalarm: alarmaMap[i]['idalarm'],
            idmed: alarmaMap[i]['idmed'],
            toma: alarmaMap[i]['toma'],
            observaciones: alarmaMap[i]['observaciones']));
  }

  static Future<List<AlarmaDetallesGrupo>> alarmasDetallesGrupo(
      AlarmaInfo alarmaInfo) async {
    Database database = await _abrirDB();

    List<AlarmaDetallesGrupo> auxAlarmaDetallesGrupo = [];
    int valor = -1;
    if (alarmaInfo != null) {
      valor = alarmaInfo.id;
    }

    final List<Map<String, dynamic>> alarmaDetaMap = await database.query(
      '$nombreTablaAlarmDeta',
      where: 'idalarm = ?',
      whereArgs: [valor],
    );

    for (var miAlarmaDeta in alarmaDetaMap) {
      List<Map<String, dynamic>> medicamentoMap = await database.query(
        '$nombreTablaMedi',
        where: 'id = ?',
        whereArgs: [miAlarmaDeta['idmed']],
      );
      if (medicamentoMap.length == 1) {
        auxAlarmaDetallesGrupo.add(AlarmaDetallesGrupo(
            iddetalles: miAlarmaDeta['iddetalles'],
            idalarm: miAlarmaDeta['idalarm'],
            idmed: miAlarmaDeta['idmed'],
            toma: miAlarmaDeta['toma'],
            observaciones: miAlarmaDeta['observaciones'],
            titulo: alarmaInfo.titulo,
            hora: alarmaInfo.hora,
            minuto: alarmaInfo.minuto,
            nombre: medicamentoMap[0]['nombre'],
            contenido: medicamentoMap[0]['contenido']));
      }
    }

    //for (var n in alarmaMap) {
    //print('____' + n['titulo']);
    //}
    return auxAlarmaDetallesGrupo;
    /*
    return List.generate(
        alarmaDetaMap.length,
        (i) => AlarmaDetallesGrupo(
            iddetalles: alarmaDetaMap[i]['iddetalles'],
            idalarm: alarmaDetaMap[i]['idalarm'],
            idmed: alarmaDetaMap[i]['idmed'],
            toma: alarmaDetaMap[i]['toma'],
            observaciones: alarmaDetaMap[i]['observaciones'],
            titulo: alarmaInfo.titulo,
            hora: alarmaInfo.hora,
            minuto: alarmaInfo.minuto));
    */
  }

  static Future<List<AlarmaDetallesGrupo>> getMedicamentosDetalles(
      int idalarma) async {
    Database database = await _abrirDB();

    List<AlarmaDetallesGrupo> auxAlarmaDetallesGrupo = [];
    int valor = idalarma;

    AlarmaInfo alarmaInfo = await getAlarma(valor);
    final List<Map<String, dynamic>> alarmaDetaMap = await database.query(
      '$nombreTablaAlarmDeta',
      where: 'idalarm = ?',
      whereArgs: [valor],
    );

    for (var miAlarmaDeta in alarmaDetaMap) {
      List<Map<String, dynamic>> medicamentoMap = await database.query(
        '$nombreTablaMedi',
        where: 'id = ?',
        whereArgs: [miAlarmaDeta['idmed']],
      );
      if (medicamentoMap.length == 1) {
        auxAlarmaDetallesGrupo.add(AlarmaDetallesGrupo(
            iddetalles: miAlarmaDeta['iddetalles'],
            idalarm: miAlarmaDeta['idalarm'],
            idmed: miAlarmaDeta['idmed'],
            toma: miAlarmaDeta['toma'],
            observaciones: miAlarmaDeta['observaciones'],
            titulo: alarmaInfo.titulo,
            hora: alarmaInfo.hora,
            minuto: alarmaInfo.minuto,
            nombre: medicamentoMap[0]['nombre'],
            contenido: medicamentoMap[0]['contenido']));
      }
    }
    return auxAlarmaDetallesGrupo;
  }
}
