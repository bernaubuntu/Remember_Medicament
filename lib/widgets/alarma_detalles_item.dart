import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:remember_medicament/modelos/alarma_detalles_grupo.dart';

Widget alarmaDetallesItem(context, AlarmaDetallesGrupo alarmaDetallesGrupo) {
  return Padding(
    padding: EdgeInsets.all(2.0),
    child: Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 2.0, 2.0),
                      child: Text(
                        alarmaDetallesGrupo.nombre,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 2.0, 2.0),
                      child: Text(
                        alarmaDetallesGrupo.toma,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 2.0, 4.0),
                      child: Text(alarmaDetallesGrupo.observaciones),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
