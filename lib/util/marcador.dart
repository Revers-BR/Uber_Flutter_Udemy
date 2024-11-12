import 'package:google_maps_flutter/google_maps_flutter.dart';

class Marcador {
  final LatLng localizcao;
  final String icone;
  final String titulo;

  const Marcador(this.icone, this.localizcao, this.titulo);
}