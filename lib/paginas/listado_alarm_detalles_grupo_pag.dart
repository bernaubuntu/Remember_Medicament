import 'package:flutter/material.dart';
import 'package:remember_medicament/database/proveedor_db.dart';
import 'package:remember_medicament/modelos/alarma_detalles.dart';
import 'package:remember_medicament/modelos/alarma_detalles_grupo.dart';
import 'package:remember_medicament/modelos/alarma_info.dart';
import 'package:remember_medicament/paginas/guardar_detalles_pag.dart';
import 'package:remember_medicament/widgets/alarma_detalles_item.dart';

class ListadoAlarmDetallesGrupoPag extends StatelessWidget {
  static const String ROUTE = '/alarmadetallesgrupopag';

  @override
  Widget build(BuildContext context) {
    return _MiListadoAlarmDetallesGrupo();
  }
}

class _MiListadoAlarmDetallesGrupo extends StatefulWidget {
  @override
  __MiListadoAlarmDetallesGrupoState createState() =>
      __MiListadoAlarmDetallesGrupoState();
}

class __MiListadoAlarmDetallesGrupoState
    extends State<_MiListadoAlarmDetallesGrupo> {
  List<AlarmaDetallesGrupo> alarmaDetallesGrupo = [];
  AlarmaInfo alarmaInfo;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    alarmaInfo = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.post_add),
        onPressed: () {
          Navigator.pushNamed(
            context,
            GuardarDetallesPag.ROUTE,
            arguments: AlarmaDetalles(idalarm: alarmaInfo.id),
          ).then((value) => setState(() {}));
        },
      ),
      appBar: AppBar(
        title: Text('Listado de Alarmas Detalles'),
      ),
      body: FutureBuilder(
        future: _getAlarmaDetallesGrupo(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text(
              snapshot.error,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w900, color: Colors.grey[500]),
            ));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var listItems = snapshot.data;

          return Container(
            padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
            child: ListView.builder(
              itemCount: listItems.length,
              itemBuilder: (_, i) => _crearElemento(i, listItems),
            ),
          );
        },
      ),
    );
  }

  Future<List<AlarmaDetallesGrupo>> _getAlarmaDetallesGrupo(
      {bool hasError = false, bool hasData = true}) async {
    if (hasError) {
      return Future.error(
          'Se produjo un error al recuperar los datos. Por favor,'
          ' inténtelo de nuevo más tarde.');
    }

    List<AlarmaDetallesGrupo> auxAlarmaDetallesGrupo = [];
    if (!hasData) {
      return auxAlarmaDetallesGrupo;
    }

    return auxAlarmaDetallesGrupo =
        await ProveedorDB.alarmasDetallesGrupo(alarmaInfo);
  }

  _crearElemento(int i, List<AlarmaDetallesGrupo> listaAlarmaDetallesGrupo) {
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
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
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
                      "¿Estás seguro de que quieres eliminar ${listaAlarmaDetallesGrupo[i].toma}?"),
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
                        ProveedorDB.borrarAlarmDetalles(AlarmaDetalles(
                          iddetalles: listaAlarmaDetallesGrupo[i].iddetalles,
                          idalarm: listaAlarmaDetallesGrupo[i].idalarm,
                          idmed: listaAlarmaDetallesGrupo[i].idmed,
                          toma: listaAlarmaDetallesGrupo[i].toma,
                          observaciones:
                              listaAlarmaDetallesGrupo[i].observaciones,
                        ));
                        if (this.mounted) {
                          setState(() {});
                        }
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
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: alarmaDetallesItem(context, listaAlarmaDetallesGrupo[i]),
            ),
            SizedBox(
              width: 40.0,
              child: Column(
                children: <Widget>[
                  MaterialButton(
                    onPressed: () {
                      Navigator.pushNamed(context, GuardarDetallesPag.ROUTE,
                              arguments: listaAlarmaDetallesGrupo.length > 0
                                  ? AlarmaDetalles(
                                      idalarm:
                                          listaAlarmaDetallesGrupo[i].idalarm,
                                      iddetalles: listaAlarmaDetallesGrupo[i]
                                          .iddetalles,
                                      idmed: listaAlarmaDetallesGrupo[i].idmed,
                                      toma: listaAlarmaDetallesGrupo[i].toma,
                                      observaciones: listaAlarmaDetallesGrupo[i]
                                          .observaciones,
                                    )
                                  : null)
                          .then((value) => setState(() {}));
                    },
                    child: Icon(
                      Icons.edit,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
