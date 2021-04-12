import 'package:remember_medicament/modelos/medicamento.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ProveedorDB {
  static Future<Database> _abrirDB() async {
    //print(join(await getDatabasesPath(), 'medicamentos.db'));
    return openDatabase(join(await getDatabasesPath(), 'medicamentos.db'),
        onCreate: (db, version) async {
      var batch = db.batch();
      // Creamos todas las tablas
      _crearTablaMedicamentosV1(batch);
      await batch.commit();
    }, version: 1);
  }

  static void _crearTablaMedicamentosV1(Batch batch) {
    batch.execute('DROP TABLE IF EXISTS medicamentos');
    batch.execute('''CREATE TABLE medicamentos (
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
    return await batch.commit();
  }

  static Future<void> insertar(Medicamento medicamento) async {
    Database database = await _abrirDB();
    return await database.insert('medicamentos', medicamento.toMap());
  }

  static Future<void> borrar(Medicamento medicamento) async {
    Database database = await _abrirDB();
    return await database
        .delete('medicamentos', where: 'id = ?', whereArgs: [medicamento.id]);
  }

  static Future<void> actualizar(Medicamento medicamento) async {
    Database database = await _abrirDB();
    return await database.update('medicamentos', medicamento.toMap(),
        where: 'id = ?', whereArgs: [medicamento.id]);
  }

  static Future<List<Medicamento>> medicamentos() async {
    Database database = await _abrirDB();

    final List<Map<String, dynamic>> medicamentosMap =
        await database.query('medicamentos');

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
}
