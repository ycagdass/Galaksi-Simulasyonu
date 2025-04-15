import 'dart:math';
import 'cisim.dart';
import 'gezegen.dart';
import 'yasanabilir_gezegen.dart';
import 'gaz_devi.dart';
import 'karadelik.dart';
import 'meteor_alani.dart';
import 'uzay_istasyonu.dart';

class Galaksi {
  List<Cisim> cisimler = [];
  int get cisimSayisi => cisimler.length;

  void cisimEkle(Cisim cisim) {
    if (cisimler.length < 100) {
      cisimler.add(cisim);
    }
  }

  void rastgeleOlay() {
    final random = Random();
    if (random.nextInt(100) < 30) {
      bool konumBulundu = false;
      int x = 0, y = 0;
      int denemeSayisi = 0;

      while (!konumBulundu && denemeSayisi < 10) {
        x = random.nextInt(10);
        y = random.nextInt(10);

        bool konumMusait = true;
        for (var cisim in cisimler) {
          if (cisim.getX == x && cisim.getY == y) {
            konumMusait = false;
            break;
          }
        }

        if (konumMusait) {
          konumBulundu = true;
        }

        denemeSayisi++;
      }

      if (!konumBulundu) {
        return;
      }

      int tip = random.nextInt(5);
      Cisim yeniCisim;
      if (tip == 0) {
        yeniCisim = YasanabilirGezegen('Yeni Gezegen ${cisimler.length}', x, y, 50);
      } else if (tip == 1) {
        yeniCisim = GazDevi('Yeni Gaz Devi ${cisimler.length}', x, y, 30);
      } else if (tip == 2) {
        yeniCisim = Karadelik('Yeni Karadelik ${cisimler.length}', x, y, 75.0);
      } else if (tip == 3) {
        yeniCisim = MeteorAlani('Yeni Meteor Alanı ${cisimler.length}', x, y);
      } else {
        yeniCisim = UzayIstasyonu('Yeni Uzay İstasyonu ${cisimler.length}', x, y);
      }

      cisimEkle(yeniCisim);
    } else if (random.nextInt(3) == 1) {
      var karadelikler = cisimler.whereType<Karadelik>().toList();
      if (karadelikler.isNotEmpty) {
        var karadelik = karadelikler[random.nextInt(karadelikler.length)];
        cisimler.removeWhere((cisim) {
          if (cisim == karadelik) return false;
          int mesafe = (cisim.getX - karadelik.getX).abs() +
              (cisim.getY - karadelik.getY).abs();
          if (mesafe <= 2) {
            return true;
          }
          return false;
        });
      }
    }
  }

  List<Gezegen> gezegenleriGetir() {
    return cisimler.whereType<Gezegen>().toList();
  }

  List<Cisim> get getCisimler => cisimler;
}