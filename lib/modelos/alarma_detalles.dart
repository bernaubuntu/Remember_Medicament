// Generado desde https://app.quicktype.io/?share=4Ik8Upww0mN33e2CBVmq
//
// To parse this JSON data, do
//
//     final alarmaDetalles = alarmaDetallesFromMap(jsonString);

import 'dart:convert';

class AlarmaDetalles {
  AlarmaDetalles({
    this.iddetalles,
    this.idalarm,
    this.idmed,
    this.toma,
    this.observaciones,
  });

  int iddetalles;
  int idalarm;
  int idmed;
  String toma;
  String observaciones;

  factory AlarmaDetalles.fromJson(String str) =>
      AlarmaDetalles.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory AlarmaDetalles.fromMap(Map<String, dynamic> json) => AlarmaDetalles(
        iddetalles: json["iddetalles"],
        idalarm: json["idalarm"],
        idmed: json["idmed"],
        toma: json["toma"],
        observaciones: json["observaciones"],
      );

  Map<String, dynamic> toMap() => {
        "iddetalles": iddetalles,
        "idalarm": idalarm,
        "idmed": idmed,
        "toma": toma,
        "observaciones": observaciones,
      };
}
