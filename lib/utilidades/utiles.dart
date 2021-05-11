import 'dart:core';
import 'dart:io';
import 'dart:convert' as convert;
import 'dart:typed_data';

import 'package:remember_medicament/database/proveedor_db.dart';
import 'package:flutter/material.dart';

class Utiles {
  static calculoCN(String cadena) {
    RegExp regExp = new RegExp(
      r"^[0-9]{6,7}$",
      caseSensitive: false,
      multiLine: false,
    );
    var diferencia = 0;
    if (regExp.hasMatch(cadena)) {
      var numPar = 0;
      var numImpar = 0;
      var total = 0;
      for (var i = 0; i < 6; i++) {
        var parsed = int.parse(cadena[i]);
        if (i.isEven) {
          numImpar += parsed;
        } else {
          numPar += (parsed * 3);
        }
      }
      total = numPar + numImpar + 27;
      while ((total + diferencia) % 10 != 0) {
        diferencia++;
      }
      if (cadena.length == 7) {
        if (cadena[cadena.length - 1] != diferencia.toString()) {
          return false;
        } else {
          return true;
        }
      }
    } else {
      return false;
    }
    //return regExp.hasMatch(cadena);
    return diferencia;
  }

  static Future<int> valorIdAlarma(int valorAlarma) async {
    int valorMax = await ProveedorDB.valorMaxIDAlarma();
    int valorMin = await ProveedorDB.valorMinIDAlarma();

    if (valorAlarma != null) {
      if (valorMax < 5000) {
        valorAlarma = valorAlarma * 100;
      } else if (valorMax < 10000) {
        valorAlarma = valorAlarma * 10;
      } else if (valorMin > 1000) {
        valorAlarma = valorAlarma * 5;
      }
    } else {
      valorAlarma = valorMax + 1;
    }
    return valorAlarma;
  }

  static diaSemana(int dia) {
    String valor = '';
    switch (dia) {
      case 1:
        valor = 'Lunes';
        break;
      case 2:
        valor = 'Martes';
        break;
      case 3:
        valor = 'Miércoles';
        break;
      case 4:
        valor = 'Jueves';
        break;
      case 5:
        valor = 'Viernes';
        break;
      case 6:
        valor = 'Sábado';
        break;
      case 7:
        valor = 'Domingo';
        break;
      default:
        valor = 'Lunes';
    }
    return valor;
  }

  static getImagenNoDisponible() {
    return Image(
      image: AssetImage('assets/img/Imagen-no-disponible-282x300.png'),
      height: 50.0,
      alignment: Alignment.center,
      fit: BoxFit.contain,
    );
  }
}
