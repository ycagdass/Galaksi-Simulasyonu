import 'uzay_kesif_araci.dart';

class Gorev {
  final String aciklama;
  final int hedefKaynak;
  final int hedefCisim;
  final int odulKaynak;
  final int odulYakit;
  int toplananKaynak = 0;
  int kesfedilenCisim = 0;
  bool tamamlandi = false;

  Gorev({
    required this.aciklama,
    required this.hedefKaynak,
    required this.hedefCisim,
    required this.odulKaynak,
    required this.odulYakit,
  });

  void kaynakToplandi(int miktar, UzayKesifAraci arac) {
    if (tamamlandi) return;
    toplananKaynak += miktar;
    if (toplananKaynak >= hedefKaynak && kesfedilenCisim >= hedefCisim) {
      tamamlandi = true;
      arac.kaynakEkle(odulKaynak);
      arac.yakitEkle(odulYakit);
    }
  }

  void cisimKesfedildi(UzayKesifAraci arac) {
    if (tamamlandi) return;
    kesfedilenCisim++;
    if (toplananKaynak >= hedefKaynak && kesfedilenCisim >= hedefCisim) {
      tamamlandi = true;
      arac.kaynakEkle(odulKaynak);
      arac.yakitEkle(odulYakit);
    }
  }
}