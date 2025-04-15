import 'package:flutter/material.dart';
import 'cisim.dart';
import 'gezegen.dart';
import 'gorev.dart';

class UzayKesifAraci extends ChangeNotifier {
  int _yakitSeviyesi;
  int _kapasite;
  int _mevcutKaynak;
  int _x;
  int _y;
  double _yakitVerimliligi = 1.0;
  double _toplamaHizi = 1.0;
  double _karadelikDirenci = 0.0;
  int _kesfedilenCisimSayisi = 0;
  List<Gorev> gorevler = [];

  UzayKesifAraci(this._yakitSeviyesi, this._kapasite)
      : _mevcutKaynak = 0,
        _x = 0,
        _y = 0;

  int get yakitSeviyesi => _yakitSeviyesi;
  int get kapasite => _kapasite;
  int get mevcutKaynak => _mevcutKaynak;
  int get x => _x;
  int get y => _y;
  double get yakitVerimliligi => _yakitVerimliligi;
  double get toplamaHizi => _toplamaHizi;
  double get karadelikDirenci => _karadelikDirenci;
  int get kesfedilenCisimSayisi => _kesfedilenCisimSayisi;

  void gorevEkle(Gorev gorev) {
    gorevler.add(gorev);
    notifyListeners();
  }

  void yakitEkle(int miktar) {
    _yakitSeviyesi += miktar;
    notifyListeners();
  }

  void yakitAzalt(int miktar) {
    int tuketilenYakit = (miktar * _yakitVerimliligi).round();
    _yakitSeviyesi -= tuketilenYakit;
    if (_yakitSeviyesi < 0) _yakitSeviyesi = 0;
    notifyListeners();
  }

  void kaynakEkle(int miktar) {
    _mevcutKaynak += (miktar * _toplamaHizi).round();
    if (_mevcutKaynak > _kapasite) _mevcutKaynak = _kapasite;
    for (var gorev in gorevler) {
      gorev.kaynakToplandi(miktar, this);
    }
    notifyListeners();
  }

  void kaynakAzalt(int miktar) {
    _mevcutKaynak -= miktar;
    if (_mevcutKaynak < 0) _mevcutKaynak = 0;
    notifyListeners();
  }

  void setKonum(int x, int y) {
    _x = x;
    _y = y;
    notifyListeners();
  }

  void kapasiteArtir(int miktar) {
    _kapasite += miktar;
    notifyListeners();
  }

  void yakitVerimliliginiArtir() {
    _yakitVerimliligi -= 0.1;
    if (_yakitVerimliligi < 0.5) _yakitVerimliligi = 0.5;
    notifyListeners();
  }

  void toplamaHiziniArtir() {
    _toplamaHizi += 0.2;
    notifyListeners();
  }

  void karadelikDirenciniArtir() {
    _karadelikDirenci += 0.1;
    if (_karadelikDirenci > 1.0) _karadelikDirenci = 1.0;
    notifyListeners();
  }

  void cismeGit(Cisim hedefCisim, BuildContext context) {
    int hedefX = hedefCisim.getX;
    int hedefY = hedefCisim.getY;
    int mesafe = (hedefX - _x).abs() + (hedefY - _y).abs();
    int gerekenYakit = yakitTuketiminiHesapla(mesafe);

    if (yeterliYakitVarMi(mesafe)) {
      yakitAzalt(mesafe);
      setKonum(hedefX, hedefY);

      if (!hedefCisim.kesfedildi) {
        hedefCisim.kesfedildi = true;
        _kesfedilenCisimSayisi++;
        for (var gorev in gorevler) {
          gorev.cisimKesfedildi(this);
        }
        notifyListeners();
      }

      if (hedefCisim is Gezegen) {
        _showKaynakToplamaDialog(context, hedefCisim);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Yakıt yetersiz! ${hedefCisim.getIsim} konumuna gitmek için $gerekenYakit yakıt gerekiyor.',
          ),
        ),
      );
    }
  }

  void _showKaynakToplamaDialog(BuildContext context, Gezegen gezegen) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kaynak Toplama'),
        content: Text(
          '${gezegen.getIsim} gezegeninden kaynak toplamak ister misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              gezegen.kaynakTopla(this);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${gezegen.getIsim} gezegeninden kaynak toplandı.',
                  ),
                ),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Evet'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Hayır'),
          ),
        ],
      ),
    );
  }

  bool yeterliYakitVarMi(int mesafe) {
    int gerekenYakit = (mesafe * _yakitVerimliligi).round();
    return _yakitSeviyesi >= gerekenYakit;
  }

  int yakitTuketiminiHesapla(int mesafe) {
    return (mesafe * _yakitVerimliligi).round();
  }
}