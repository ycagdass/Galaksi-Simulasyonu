abstract class Cisim {
  final String _isim;
  int _x;
  int _y;
  bool kesfedildi;

  Cisim(this._isim, this._x, this._y) : kesfedildi = false;

  String get getIsim => _isim;
  int get getX => _x;
  int get getY => _y;

  void setKonum(int x, int y) {
    _x = x;
    _y = y;
  }
}