class Board {
  final String _ieee;
  String name;
  int type;
  List<String> _lamps;

  Board(this._ieee, this.name, this.type, this._lamps);

  Board.fromJson(Map<String, dynamic> json)
      : _ieee = json['ieee'],
        name = json['name'],
        type = json['type'],
        _lamps = json['lamps'];

  Map<String, dynamic> toJson() =>
      {'ieee': _ieee, 'name': name, 'type': type, 'lamps': _lamps};

  String get ieee {
    return _ieee;
  }

  void setlamps(List<String> l) {
    for (int i = 0; i < l.length; i++) _lamps.add(l[i]);
  }

  void setlamp(int n, String name) {
    _lamps[n] = name;
  }

  List<String> get lamps {
    return [..._lamps];
  }
}
