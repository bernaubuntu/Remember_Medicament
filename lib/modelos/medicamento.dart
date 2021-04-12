// Generado desde https://app.quicktype.io/?share=4Ik8Upww0mN33e2CBVmq
import 'dart:convert';

class Medicamento {
  Medicamento({
    this.id,
    this.cn,
    this.nombre,
    this.contenido,
    this.rutaImagen,
  });

  Medicamento.vacio();

  int id;
  String cn;
  String nombre;
  String contenido;
  String rutaImagen;

  factory Medicamento.fromJson(String str) =>
      Medicamento.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Medicamento.fromMap(Map<String, dynamic> json) => Medicamento(
        id: json["id"],
        cn: json["cn"],
        nombre: json["nombre"],
        contenido: json["contenido"],
        rutaImagen: json["rutaImagen"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "cn": cn,
        "nombre": nombre,
        "contenido": contenido,
        "rutaImagen": rutaImagen,
      };
}
