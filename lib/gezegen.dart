import 'cisim.dart';
import 'uzay_kesif_araci.dart';

abstract class Gezegen extends Cisim {
  final int _kaynak;
  bool _kaynakToplandi = false;

  Gezegen(super.isim, super.x, super.y, this._kaynak);

  int get getKaynak => _kaynak;

  void kaynakTopla(UzayKesifAraci arac) {
    if (!_kaynakToplandi && _kaynak > 0) {
      arac.kaynakEkle(_kaynak);
      _kaynakToplandi = true;
    }
  }
}