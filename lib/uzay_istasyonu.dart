import 'package:flutter/material.dart';
import 'cisim.dart';
import 'uzay_kesif_araci.dart';

class UzayIstasyonu extends Cisim {
  UzayIstasyonu(super.isim, super.x, super.y);

  void istasyonEtkilesimi(UzayKesifAraci arac, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Uzay İstasyonu'),
        content: const Text('Yakıt ikmali yapmak ister misiniz? (Maliyet: 20 kaynak)'),
        actions: [
          TextButton(
            onPressed: () {
              if (arac.mevcutKaynak >= 20) {
                arac.kaynakAzalt(20);
                arac.yakitEkle(50);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Yakıt ikmali yapıldı.')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Yeterli kaynak yok.')),
                );
              }
              Navigator.of(context).pop();
            },
            child: const Text('Evet'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hayır'),
          ),
        ],
      ),
    );
  }
}