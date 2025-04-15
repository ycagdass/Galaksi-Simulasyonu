import 'dart:math';
import 'cisim.dart';
import 'uzay_kesif_araci.dart';

class MeteorAlani extends Cisim {
  MeteorAlani(super.isim, super.x, super.y);

  void meteorEtkilesimi(UzayKesifAraci arac) {
    final random = Random();
    int yakitKaybi = random.nextInt(50) + 10;
    arac.yakitAzalt(yakitKaybi);
  }
}