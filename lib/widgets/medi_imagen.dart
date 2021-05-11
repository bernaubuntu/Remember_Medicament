import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:remember_medicament/utilidades/utiles.dart';

Widget mediImagen(String rutaImagen) {
  if (rutaImagen != null) {
    return SizedBox(
      height: 50.0,
      width: 50.0,
      child: _getImagen(rutaImagen),
    );
  } else {
    return Utiles.getImagenNoDisponible();
  }
}

_getImagen(String rutaImagen) {
  try {
    Image imagen = Image.file(File(rutaImagen));
    return imagen;
  } catch (e) {
    return Utiles.getImagenNoDisponible();
  }
}
