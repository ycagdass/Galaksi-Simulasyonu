import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cisim.dart';
import 'galaksi.dart';
import 'uzay_kesif_araci.dart';
import 'yasanabilir_gezegen.dart';
import 'gaz_devi.dart';
import 'karadelik.dart';
import 'gorev.dart';
import 'meteor_alani.dart';
import 'uzay_istasyonu.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UzayKesifAraci(100, 50),
      child: MaterialApp(
        title: 'Galaksi Simülasyonu Oyunu',
        theme: ThemeData.dark().copyWith(
          primaryColor: Colors.blueGrey,
          scaffoldBackgroundColor: Colors.black,
        ),
        home: const GameScreen(),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late Galaksi galaksi;
  late AnimationController _animationController;
  late AnimationController _blackHolePulseController;
  late AnimationController _notificationController;
  late Animation<double> _blackHolePulseAnimation;
  late Animation<double> _notificationAnimation;
  late Animation<Offset> _positionAnimation;
  Offset _currentPosition = const Offset(0, 0);
  late Timer _eventTimer;
  int skor = 0;
  String _notificationMessage = '';

  @override
  void initState() {
    super.initState();
    galaksi = Galaksi();
    galaksi.cisimEkle(YasanabilirGezegen('Dünya', 5, 7, 100));
    galaksi.cisimEkle(GazDevi('Jüpiter', 4, 8, 50));
    galaksi.cisimEkle(Karadelik('Karadelik-1', 3, 9, 75.0));
    galaksi.cisimEkle(YasanabilirGezegen('Mars', 2, 6, 70));
    galaksi.cisimEkle(GazDevi('Satürn', 5, 8, 30));
    galaksi.cisimEkle(MeteorAlani('Meteor Alanı-1', 1, 1));
    galaksi.cisimEkle(UzayIstasyonu('Uzay İstasyonu-1', 8, 2));

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _positionAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _blackHolePulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _blackHolePulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _blackHolePulseController,
        curve: Curves.easeInOut,
      ),
    );

    _notificationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _notificationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _notificationController,
        curve: Curves.easeInOut,
      ),
    );

    _eventTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      setState(() {
        galaksi.rastgeleOlay();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arac = Provider.of<UzayKesifAraci>(context, listen: false);
      arac.gorevEkle(Gorev(
        aciklama: '100 kaynak topla ve 3 cisim keşfet',
        hedefKaynak: 100,
        hedefCisim: 3,
        odulKaynak: 50,
        odulYakit: 20,
      ));
      arac.gorevEkle(Gorev(
        aciklama: '200 kaynak topla ve 5 cisim keşfet',
        hedefKaynak: 200,
        hedefCisim: 5,
        odulKaynak: 100,
        odulYakit: 50,
      ));
      arac.addListener(() {
        setState(() {
          skor = arac.mevcutKaynak * 10 +
              arac.gorevler.where((g) => g.tamamlandi).length * 100;
          for (var gorev in arac.gorevler) {
            if (gorev.tamamlandi && !_notificationController.isAnimating) {
              _notificationMessage = 'Görev Tamamlandı: ${gorev.aciklama}';
              _notificationController.forward(from: 0);
            }
          }
        });
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _blackHolePulseController.dispose();
    _notificationController.dispose();
    _eventTimer.cancel();
    super.dispose();
  }

  void _animateToPosition(int x, int y) {
    setState(() {
      _positionAnimation = Tween<Offset>(
        begin: _currentPosition,
        end: Offset(x * 60.0, y * 60.0),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
      _currentPosition = Offset(x * 60.0, y * 60.0);
    });
    _animationController.forward(from: 0);
  }

  bool _tuketKaynak(UzayKesifAraci arac, int miktar, String islemAdi) {
    if (arac.mevcutKaynak >= miktar) {
      arac.kaynakAzalt(miktar);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$islemAdi işlemi tamamlandı.')),
      );
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yeterli kaynak yok.')),
      );
      return false;
    }
  }

  void _showInputDialog({
    required String title,
    required String labelText,
    required Function(int) onConfirm,
    String confirmButtonText = 'Tamam',
  }) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: labelText),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final value = controller.text;
              try {
                int miktar = int.parse(value);
                if (miktar <= 0) {
                  throw const FormatException('Değer pozitif olmalıdır');
                }
                onConfirm(miktar);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Lütfen geçerli bir pozitif sayı girin.')),
                );
              }
              Navigator.of(context).pop();
            },
            child: Text(confirmButtonText),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UzayKesifAraci>(
      builder: (context, arac, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Galaksi Simülasyonu Oyunu'),
            actions: [
              IconButton(
                icon: const Icon(Icons.assignment),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Görevler'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: arac.gorevler.map((gorev) {
                          return ListTile(
                            title: Text(gorev.aciklama),
                            subtitle: Text(
                              'Kaynak: ${gorev.toplananKaynak}/${gorev.hedefKaynak}, '
                                  'Keşfedilen Cisim: ${gorev.kesfedilenCisim}/${gorev.hedefCisim}, '
                                  'Tamamlandı: ${gorev.tamamlandi ? "Evet" : "Hayır"}',
                            ),
                          );
                        }).toList(),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Kapat'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          body: arac.yakitSeviyesi > 0
              ? Stack(
            children: [
              _buildSpaceBackground(),
              _buildGalaksiHaritasi(context, arac),
              SlideTransition(
                position: _positionAnimation,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromRGBO(255, 255, 255, 0.3),
                  ),
                  child: const Icon(
                    Icons.rocket_launch,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildAracDurumu(arac),
              ),
              Positioned(
                top: 120,
                right: 10,
                child: Text(
                  'Skor: $skor',
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              Positioned(
                top: 150,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _notificationAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: const Color.fromRGBO(255, 255, 255, 0.1),
                    child: Text(
                      _notificationMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildEylemMenusu(context, arac),
              ),
            ],
          )
              : const Center(child: Text('Yakıt bitti. Görev sonlandırıldı.')),
        );
      },
    );
  }

  Widget _buildSpaceBackground() {
    return CustomPaint(
      painter: SpaceBackgroundPainter(),
      child: Container(),
    );
  }

  Widget _buildGalaksiHaritasi(BuildContext context, UzayKesifAraci arac) {
    return Stack(
      children: galaksi.getCisimler.map((cisim) {
        return Positioned(
          left: cisim.getX * 60.0,
          top: cisim.getY * 60.0,
          child: GestureDetector(
            onTap: () {
              if (cisim is MeteorAlani) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Uyarı'),
                    content: const Text(
                        'Meteor alanına girmek yakıt kaybına neden olabilir. Devam etmek istiyor musunuz?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          arac.cismeGit(cisim, context);
                          _animateToPosition(cisim.getX, cisim.getY);
                          cisim.meteorEtkilesimi(arac);
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
              } else if (cisim is Karadelik) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Uyarı'),
                    content: const Text(
                        'Kara deliğe girmek tehlikeli olabilir. Devam etmek istiyor musunuz?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          arac.cismeGit(cisim, context);
                          _animateToPosition(cisim.getX, cisim.getY);
                          cisim.karadelikEtkilesimi(arac, galaksi.gezegenleriGetir());
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
              } else {
                arac.cismeGit(cisim, context);
                _animateToPosition(cisim.getX, cisim.getY);
                for (var digerCisim in galaksi.getCisimler) {
                  if (digerCisim != cisim &&
                      digerCisim.getX == cisim.getX &&
                      digerCisim.getY == cisim.getY) {
                    if (digerCisim is UzayIstasyonu) {
                      digerCisim.istasyonEtkilesimi(arac, context);
                    }
                  }
                }
              }
            },
            child: _buildCisimWidget(cisim),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCisimWidget(Cisim cisim) {
    Widget icon;
    if (cisim is YasanabilirGezegen) {
      icon = const Icon(Icons.public, color: Colors.green, size: 30);
    } else if (cisim is GazDevi) {
      icon = const Icon(Icons.cloud, color: Colors.orange, size: 30);
    } else if (cisim is Karadelik) {
      return ScaleTransition(
        scale: _blackHolePulseAnimation,
        child: const Icon(Icons.blur_circular, color: Colors.purple, size: 30),
      );
    } else if (cisim is MeteorAlani) {
      icon = const Icon(Icons.dangerous, color: Colors.red, size: 30);
    } else if (cisim is UzayIstasyonu) {
      icon = const Icon(Icons.store, color: Colors.blue, size: 30);
    } else {
      icon = const Icon(Icons.star, color: Colors.yellow, size: 30);
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color.fromRGBO(0, 255, 0, 0.8),
          ),
        ),
        icon,
      ],
    );
  }

  Widget _buildAracDurumu(UzayKesifAraci arac) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blueGrey,
      child: Column(
        children: [
          Text('Yakıt Seviyesi: ${arac.yakitSeviyesi}'),
          Text('Kaynak Miktarı: ${arac.mevcutKaynak}/${arac.kapasite}'),
          Text('Konum: (${arac.x}, ${arac.y})'),
          Text('Yakıt Verimliliği: ${(arac.yakitVerimliligi * 100).round()}%'),
          Text('Toplama Hızı: ${(arac.toplamaHizi * 100).round()}%'),
          Text('Karadelik Direnci: ${(arac.karadelikDirenci * 100).round()}%'),
        ],
      ),
    );
  }

  Widget _buildEylemMenusu(BuildContext context, UzayKesifAraci arac) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              _showInputDialog(
                title: 'Kapasite Artırma',
                labelText: 'Miktar',
                onConfirm: (int miktar) {
                  int gerekenKaynak = miktar * 2;
                  if (_tuketKaynak(arac, gerekenKaynak, 'Kapasite artırma')) {
                    arac.kapasiteArtir(miktar);
                  }
                },
              );
            },
            child: const Text('Kapasite Artır'),
          ),
          ElevatedButton(
            onPressed: () {
              _showInputDialog(
                title: 'Yakıt Ekle',
                labelText: 'Yakıt Miktarı',
                onConfirm: (int miktar) {
                  if (_tuketKaynak(arac, miktar, 'Yakıt ekleme')) {
                    arac.yakitEkle(miktar);
                  }
                },
              );
            },
            child: const Text('Yakıt Ekle'),
          ),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Yükseltme Menüsü'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('Yakıt Verimliliği (+0.1)'),
                        subtitle: const Text('Maliyet: 20 kaynak'),
                        onTap: () {
                          if (arac.mevcutKaynak >= 20) {
                            arac.kaynakAzalt(20);
                            arac.yakitVerimliliginiArtir();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Yakıt verimliliği artırıldı.')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Yeterli kaynak yok.')),
                            );
                          }
                          Navigator.of(context).pop();
                        },
                      ),
                      ListTile(
                        title: const Text('Toplama Hızı (+0.2)'),
                        subtitle: const Text('Maliyet: 30 kaynak'),
                        onTap: () {
                          if (arac.mevcutKaynak >= 30) {
                            arac.kaynakAzalt(30);
                            arac.toplamaHiziniArtir();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Toplama hızı artırıldı.')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Yeterli kaynak yok.')),
                            );
                          }
                          Navigator.of(context).pop();
                        },
                      ),
                      ListTile(
                        title: const Text('Karadelik Direnci (+0.1)'),
                        subtitle: const Text('Maliyet: 40 kaynak'),
                        onTap: () {
                          if (arac.mevcutKaynak >= 40) {
                            arac.kaynakAzalt(40);
                            arac.karadelikDirenciniArtir();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Karadelik direnci artırıldı.')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Yeterli kaynak yok.')),
                            );
                          }
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Kapat'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Yükseltmeler'),
          ),
          ElevatedButton(
            onPressed: () {
              arac.yakitAzalt(arac.yakitSeviyesi);
            },
            child: const Text('Oyunu Bitir'),
          ),
        ],
      ),
    );
  }
}

class SpaceBackgroundPainter extends CustomPainter {
  static final List<Star> stars = _generateStars();
  static const int starCount = 100;

  static List<Star> _generateStars() {
    final random = Random();
    List<Star> generatedStars = [];
    for (int i = 0; i < starCount; i++) {
      generatedStars.add(Star(
        position: Offset(
          random.nextDouble() * 1000,
          random.nextDouble() * 1000,
        ),
        size: random.nextDouble() * 2,
      ));
    }
    return generatedStars;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    for (var star in stars) {
      if (star.position.dx < size.width && star.position.dy < size.height) {
        canvas.drawCircle(star.position, star.size, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class Star {
  final Offset position;
  final double size;
  Star({required this.position, required this.size});
}