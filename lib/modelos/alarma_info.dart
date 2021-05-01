// Generado desde https://app.quicktype.io/?share=4Ik8Upww0mN33e2CBVmq
// To parse this JSON data, do
//
//     final alarmaInfo = alarmaInfoFromMap(jsonString);

import 'dart:convert';

import 'package:remember_medicament/modelos/medicamento.dart';

class AlarmaInfo {
  AlarmaInfo({
    this.id,
    this.idmed,
    this.titulo,
    this.hora,
    this.minuto,
    this.lunes,
    this.martes,
    this.miercoles,
    this.jueves,
    this.viernes,
    this.sabado,
    this.domingo,
    this.activo,
  });

  AlarmaInfo.vacio();
  AlarmaInfo.vacioMedi(Medicamento medicamento) {
    this.idmed = medicamento.id;
    this.hora = 1;
    this.minuto = 0;
    this.lunes = 0;
    this.martes = 0;
    this.miercoles = 0;
    this.jueves = 0;
    this.viernes = 0;
    this.sabado = 0;
    this.domingo = 0;
    this.activo = 1;
  }

  int id;
  int idmed;
  String titulo;
  int hora;
  int minuto;
  int lunes;
  int martes;
  int miercoles;
  int jueves;
  int viernes;
  int sabado;
  int domingo;
  int activo;

  factory AlarmaInfo.fromJson(String str) =>
      AlarmaInfo.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory AlarmaInfo.fromMap(Map<String, dynamic> json) => AlarmaInfo(
        id: json["id"],
        idmed: json["idmed"],
        titulo: json["titulo"],
        hora: json["hora"],
        minuto: json["minuto"],
        lunes: json["lunes"],
        martes: json["martes"],
        miercoles: json["miercoles"],
        jueves: json["jueves"],
        viernes: json["viernes"],
        sabado: json["sabado"],
        domingo: json["domingo"],
        activo: json["activo"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "idmed": idmed,
        "titulo": titulo,
        "hora": hora,
        "minuto": minuto,
        "lunes": lunes,
        "martes": martes,
        "miercoles": miercoles,
        "jueves": jueves,
        "viernes": viernes,
        "sabado": sabado,
        "domingo": domingo,
        "activo": activo,
      };

  int cantidadDias() {
    int cantidad = 0;
    if (lunes == 1) cantidad++;
    if (martes == 1) cantidad++;
    if (miercoles == 1) cantidad++;
    if (jueves == 1) cantidad++;
    if (viernes == 1) cantidad++;
    if (sabado == 1) cantidad++;
    if (domingo == 1) cantidad++;

    return cantidad;
  }
}
