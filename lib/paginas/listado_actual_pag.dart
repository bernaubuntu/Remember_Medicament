import 'dart:io';

import 'package:flutter/material.dart';
import 'package:remember_medicament/database/proveedor_db.dart';
import 'package:remember_medicament/modelos/alarma_info.dart';
import 'package:remember_medicament/modelos/medicamento.dart';

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
  List<Medicamento> medicamentos = [];

  @override
  void initState() {
    _cargarDatos();
    super.initState();
    _payload = widget.payload;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: Text('Listado actual: ${_payload ?? ''}'),
        title: Text('Listado actual'),
        //automaticallyImplyLeading: false,
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
        child: ListView.builder(
          itemCount: medicamentos.length,
          itemBuilder: (_, i) => _crearElemento(i),
        ),
      ),
    );
  }

  _cargarDatos() async {
    List<Medicamento> auxMedicamentos = await ProveedorDB.medicamentosActual();
    List<Medicamento> nuevosmedicamentos = [];
    DateTime ahora = DateTime.now();
    for (var unMedicamento in auxMedicamentos) {
      List<AlarmaInfo> auxAlarmas =
          await ProveedorDB.alarmaMedicamentos(unMedicamento);
      for (var unAlarma in auxAlarmas) {
        bool coincide = false;
        if (unAlarma.cantidadDias() > 0 && unAlarma.cantidadDias() < 8) {
          switch (ahora.weekday) {
            case 1:
              if (unAlarma.lunes == 1) {
                coincide = true;
              }
              break;
            case 2:
              if (unAlarma.martes == 1) {
                coincide = true;
              }
              break;
            case 3:
              if (unAlarma.miercoles == 1) {
                coincide = true;
              }
              break;
            case 4:
              if (unAlarma.jueves == 1) {
                coincide = true;
              }
              break;
            case 5:
              if (unAlarma.viernes == 1) {
                coincide = true;
              }
              break;
            case 6:
              if (unAlarma.sabado == 1) {
                coincide = true;
              }
              break;
            case 7:
              if (unAlarma.domingo == 1) {
                coincide = true;
              }
              break;
            default:
          }
        } else {
          if (ahora.hour > unAlarma.hora) {
            coincide = true;
          } else if (ahora.hour == unAlarma.hora &&
              unAlarma.minuto >= ahora.minute) {
            coincide = true;
          }
        }
        if (coincide) {
          if (!nuevosmedicamentos.contains(unMedicamento)) {
            nuevosmedicamentos.add(unMedicamento);
          }
        }
      }
    }
    setState(() {
      medicamentos = nuevosmedicamentos;
    });
  }

  _crearElemento(int i) {
    return GestureDetector(
      child: Card(
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
              child: Icon(Icons.delete, color: Colors.white),
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
                        "¿Estás seguro de que quieres eliminar ${medicamentos[i].nombre}?"),
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
                          ProveedorDB.borrarMedi(medicamentos[i]);
                          setState(() {
                            _cargarDatos();
                          });
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
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  children: <Widget>[
                    // Sección izquierda
                    medicamentos[i].rutaImagen != null
                        ? SizedBox(
                            height: 50.0,
                            width: 50.0,
                            child: Image.file(File(medicamentos[i].rutaImagen)))
                        : Image(
                            image: AssetImage(
                                'assets/img/Imagen-no-disponible-282x300.png'),
                            height: 50.0,
                            alignment: Alignment.topLeft,
                          ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        medicamentos[i].nombre,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Roboto',
                          letterSpacing: 0.5,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        medicamentos[i].contenido,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Roboto',
                          letterSpacing: 0.5,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  MaterialButton(
                      onPressed: () {},
                      child: Icon(
                        Icons.edit,
                        color: Colors.green,
                      ))
                ],
              ),
            ],
          ),
        ),
      ),
      onTap: () {},
    );
  }
}
