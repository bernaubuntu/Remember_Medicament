import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:remember_medicament/database/proveedor_db.dart';
import 'package:remember_medicament/modelos/alarma_detalles_grupo.dart';
import 'package:remember_medicament/modelos/alarma_info.dart';
import 'package:remember_medicament/widgets/alarma_detalles_item.dart';
import 'package:remember_medicament/widgets/alarma_item.dart';

class ListadoActualPag extends StatefulWidget {
  const ListadoActualPag(
    this.payload, {
    Key key,
  }) : super(key: key);

  static const String ROUTE = '/listadoactual';
  final String payload;

  @override
  _ListadoActualPagState createState() => _ListadoActualPagState();
}

class _ListadoActualPagState extends State<ListadoActualPag> {
  String _payload;
  List<AlarmaDetallesGrupo> alarmaDetallesGrupo = [];
  AlarmaInfo alarmaInfo = AlarmaInfo.vacio();
  Map<String, dynamic> map;

  @override
  void initState() {
    super.initState();
    _payload = widget.payload;
    map = jsonDecode(_payload);
    _cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hora de tomar Medicamentos'),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(2.0, 4.0, 2.0, 1.0),
            width: MediaQuery.of(context).size.width,
            height: 150.0,
            child: Card(
              color: Colors.amber,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: alarmaItem(alarmaInfo.hora.toString(),
                  alarmaInfo.minuto.toString(), context, alarmaInfo),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height >
                    MediaQuery.of(context).size.width
                ? MediaQuery.of(context).size.height * .68
                : MediaQuery.of(context).size.height * .40,
            child: ListView.builder(
              itemCount: alarmaDetallesGrupo.length,
              itemBuilder: (_, i) => _crearElemento(i),
            ),
          ),
        ],
      ),
    );
  }

  _cargarDatos() async {
    List<AlarmaDetallesGrupo> auxAlarmaDetallesGrupo = [];
    AlarmaInfo auxAlarmaInfo = AlarmaInfo.vacio();
    if (map.containsKey('idalarm')) {
      auxAlarmaDetallesGrupo =
          await ProveedorDB.getMedicamentosDetalles(map['idalarm']);
      auxAlarmaInfo = await ProveedorDB.getAlarma(map['idalarm']);
    }
    setState(() {
      alarmaDetallesGrupo = auxAlarmaDetallesGrupo;
      alarmaInfo = auxAlarmaInfo;
    });
  }

  _crearElemento(int i) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      color: Colors.blue.shade100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: alarmaDetallesItem(context, alarmaDetallesGrupo[i]),
          ),
        ],
      ),
    );
  }
}
