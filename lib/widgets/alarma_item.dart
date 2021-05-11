import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:remember_medicament/modelos/alarma_info.dart';
import 'package:remember_medicament/widgets/circulo_dia.dart';

Widget alarmaItem(hora, minuto, context, AlarmaInfo alarmaInfo) {
  TextStyle _estiloHora = TextStyle(
      color: Colors.black, fontSize: 40.0, fontWeight: FontWeight.bold);

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
                      width: MediaQuery.of(context).size.width * 0.7,
                      padding: const EdgeInsets.fromLTRB(8.0, 2.0, 8.0, 1.0),
                      child: Text(
                        alarmaInfo.titulo,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      (hora.length < 2 ? '0' : '') + hora,
                      textAlign: TextAlign.center,
                      style: _estiloHora,
                    ),
                    Text(
                      ':',
                      style: _estiloHora,
                    ),
                    Text(
                      (minuto.length < 2 ? '0' : '') + minuto,
                      textAlign: TextAlign.center,
                      style: _estiloHora,
                    ),
                    SizedBox(
                      width: 30.0,
                    ),
                    Switch(
                      value: ((alarmaInfo.activo == 0) ? false : true),
                      activeTrackColor: Theme.of(context).backgroundColor,
                      activeColor: Theme.of(context).accentColor,
                      onChanged: (value) {},
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    circuloDia("Lun", context, alarmaInfo.lunes),
                    circuloDia("Mar", context, alarmaInfo.martes),
                    circuloDia("Mie", context, alarmaInfo.miercoles),
                    circuloDia("Jue", context, alarmaInfo.jueves),
                    circuloDia("Vie", context, alarmaInfo.viernes),
                    circuloDia("Sab", context, alarmaInfo.sabado),
                    circuloDia("Dom", context, alarmaInfo.domingo),
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
