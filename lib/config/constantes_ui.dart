import 'package:flutter/material.dart';

// Constantes reutilizables de UI para el conector.
class ConstantesUI {
  // Colores (alineados con el otro proyecto).
  static const Color colorPrimario = Color.fromRGBO(83, 77, 100, 1);
  static const Color colorSecundario = Color.fromARGB(255, 201, 11, 173);

  // Espaciados base.
  static const double espacio = 12;
  // Espacio reducido para separar elementos muy cercanos.
  static const double espacioPequeno = 8;
  static const double espacioGrande = 16;

  // Anchura recomendada para campos en escritorio.
  static const double anchoCampo = 360;
  // Anchura recomendada para dialogos de creacion/edicion.
  static const double anchoDialogCreacion = 560;

  // Margen general de pantalla.
  static const EdgeInsets paddingPantalla = EdgeInsets.all(16);
}
