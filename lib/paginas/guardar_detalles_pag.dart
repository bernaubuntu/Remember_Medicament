import 'package:flutter/material.dart';
import 'package:remember_medicament/database/proveedor_db.dart';
import 'package:remember_medicament/modelos/alarma_detalles.dart';
import 'package:remember_medicament/modelos/alarma_info.dart';
import 'package:remember_medicament/modelos/medicamento.dart';
import 'package:remember_medicament/widgets/alarma_item.dart';

class GuardarDetallesPag extends StatefulWidget {
  static const String ROUTE = '/guardardetalles';

  @override
  _GuardarDetallesPagState createState() => _GuardarDetallesPagState();
}

class _GuardarDetallesPagState extends State<GuardarDetallesPag> {
  final _formkey = GlobalKey<FormState>();

  final tomaController = TextEditingController();

  final observacionController = TextEditingController();

  bool primero = true;

  AlarmaInfo alarmaInfo = AlarmaInfo.vacio();
  var _seleccionadoValor;

  // ignore: deprecated_member_use
  var _medicamentos = List<DropdownMenuItem>();

  _cargarMedicamentos() async {
    List<Medicamento> auxMedicamento = await ProveedorDB.medicamentos();
    for (var elMedicamento in auxMedicamento) {
      setState(() {
        _medicamentos.add(DropdownMenuItem(
          child: Container(
            padding: EdgeInsets.only(left: 5.0),
            width: MediaQuery.of(context).size.width * 0.9,
            child: Text(
              elMedicamento.nombre,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.normal,
                fontFamily: 'Roboto',
                letterSpacing: 0.5,
                fontSize: 12,
              ),
            ),
          ),
          value: elMedicamento.id,
        ));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarMedicamentos();
  }

  @override
  Widget build(BuildContext context) {
    AlarmaDetalles alarmaDetalles = ModalRoute.of(context).settings.arguments;
    if (primero) {
      _iniciar(alarmaDetalles);
      _cargarDatos(alarmaDetalles.idalarm);
      primero = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Guardar Toma Medicamento'),
      ),
      body: GestureDetector(
        onTap: () {
          final FocusScopeNode focus = FocusScope.of(context);
          if (!focus.hasPrimaryFocus && focus.hasFocus) {
            FocusManager.instance.primaryFocus.unfocus();
          }
        },
        child: Container(
          child: _construirForm(alarmaDetalles, alarmaInfo),
        ),
      ),
    );
  }

  _iniciar(AlarmaDetalles alarmaDetalles) {
    if (alarmaDetalles.idmed != null) {
      _seleccionadoValor = alarmaDetalles.idmed;
    }
    if (alarmaDetalles.toma != null) {
      tomaController.text = alarmaDetalles.toma;
    }
    if (alarmaDetalles.observaciones != null) {
      observacionController.text = alarmaDetalles.observaciones;
    }
  }

  Future<void> _cargarDatos(int id) async {
    AlarmaInfo auxAlarmaInfo = await ProveedorDB.getAlarma(id);
    if (this.mounted) {
      setState(() {
        alarmaInfo = auxAlarmaInfo;
      });
    }
  }

  Widget _construirForm(AlarmaDetalles alarmaDetalles, AlarmaInfo alarmaInfo) {
    return Container(
      padding: EdgeInsets.all(5),
      child: ListView(
        scrollDirection: Axis.vertical,
        children: [
          Form(
            key: _formkey,
            child: Column(
              children: <Widget>[
                Container(
                  child: Card(
                    color: Colors.amber,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: alarmaItem(
                        alarmaInfo.hora.toString() == null
                            ? '0'
                            : alarmaInfo.hora.toString(),
                        alarmaInfo.minuto.toString(),
                        context,
                        alarmaInfo),
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Container(
                  padding: EdgeInsets.only(left: 2.0),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1.0),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: DropdownButtonFormField(
                    isExpanded: true,
                    validator: (value) {
                      if (value == null) {
                        return 'El valor no puede estar vacio';
                      }
                      return null;
                    },
                    value: _seleccionadoValor,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 32.0,
                    items: _medicamentos,
                    hint: Text('Medicamento'),
                    onChanged: (value) => {
                      setState(() {
                        _seleccionadoValor = value;
                      })
                    },
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'El valor no puede estar vacio';
                    }
                    return null;
                  },
                  maxLines: 1,
                  controller: tomaController,
                  decoration: InputDecoration(
                      labelText: 'Toma',
                      hintText: 'Escribe la cantidad para la toma',
                      border:
                          OutlineInputBorder() //borderRadius: BorderRadius.all(Radius.circular(20))
                      ),
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                TextFormField(
                  controller: observacionController,
                  decoration: InputDecoration(
                      labelText: 'Observación',
                      hintText: 'Escribe alguna observación',
                      border:
                          OutlineInputBorder() //borderRadius: BorderRadius.all(Radius.circular(20))
                      ),
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    letterSpacing: 0.5,
                  ),
                ),
                ElevatedButton(
                  child: (alarmaDetalles.iddetalles == null)
                      ? Text('Guardar')
                      : Text('Actualizar'),
                  onPressed: () {
                    if (_formkey.currentState.validate()) {
                      if (alarmaDetalles.iddetalles != null) {
                        //actualización
                        alarmaDetalles.idmed = _seleccionadoValor;
                        alarmaDetalles.toma = tomaController.text;
                        alarmaDetalles.observaciones =
                            observacionController.text;
                        ProveedorDB.actualizarAlarmDetalles(alarmaDetalles);
                        Navigator.of(context).pop();
                      } else {
                        //Inserción
                        ProveedorDB.insertarAlarmDetalles(AlarmaDetalles(
                          idalarm: alarmaDetalles.idalarm,
                          idmed: _seleccionadoValor,
                          toma: tomaController.text,
                          observaciones: observacionController.text,
                        ));

                        Navigator.of(context).pop();
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
