import 'dart:convert';

class AlarmaDetallesGrupo {
  AlarmaDetallesGrupo({
    this.iddetalles,
    this.idalarm,
    this.idmed,
    this.toma,
    this.observaciones,
    this.titulo,
    this.hora,
    this.minuto,
    this.nombre,
    this.contenido,
  });

  int iddetalles;
  int idalarm;
  int idmed;
  String toma;
  String observaciones;

  String titulo;
  int hora;
  int minuto;

  String nombre;
  String contenido;

  factory AlarmaDetallesGrupo.fromJson(String str) =>
      AlarmaDetallesGrupo.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory AlarmaDetallesGrupo.fromMap(Map<String, dynamic> json) =>
      AlarmaDetallesGrupo(
        iddetalles: json["iddetalles"],
        idalarm: json["idalarm"],
        idmed: json["idmed"],
        toma: json["toma"],
        observaciones: json["observaciones"],
        titulo: json["titulo"],
        hora: json["hora"],
        minuto: json["minuto"],
        nombre: json["nombre"],
        contenido: json["contenido"],
      );

  Map<String, dynamic> toMap() => {
        "iddetalles": iddetalles,
        "idalarm": idalarm,
        "idmed": idmed,
        "toma": toma,
        "observaciones": observaciones,
        "titulo": titulo,
        "hora": hora,
        "minuto": minuto,
        "nombre": nombre,
        "contenido": contenido,
      };
}
