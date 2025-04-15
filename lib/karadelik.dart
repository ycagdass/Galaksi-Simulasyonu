import 'dart:math';
import 'cisim.dart';
import 'gezegen.dart';
import 'uzay_kesif_araci.dart';

class Karadelik extends Cisim {
  final double _etkiAlani;

  Karadelik(super.isim, super.x, super.y, this._etkiAlani);

  void karadelikEtkilesimi(UzayKesifAraci arac, List<Gezegen> gezegenler) {
    final random = Random();
    double direncEtkisi = 1.0 - arac.karadelikDirenci;
    int yakitKaybi =
        (random.nextInt(30) + 20 + (_etkiAlani * 0.1).round()) * direncEtkisi.round();
    arac.yakitAzalt(yakitKaybi);

    if (random.nextDouble() < (0.5 + (_etkiAlani * 0.01)) * direncEtkisi) {
      if (gezegenler.isNotEmpty) {
        final hedefGezegen = gezegenler[random.nextInt(gezegenler.length)];
        arac.setKonum(hedefGezegen.getX, hedefGezegen.getY);
      } else {
        arac.setKonum(0, 0);
      }
    }
  }
}