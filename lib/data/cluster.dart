import 'package:convert/convert.dart';

import 'board.dart';

class Cluster {
  final String title;
  final String ip;
  final String key;
  final List<int> _ieee;
  List<Board> _boards;

  Cluster(this.title, this.ip, this.key, this._ieee, this._boards);

  Cluster.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        ip = json['ip'],
        key = json['key'],
        _ieee = json['ieee'],
        _boards = json['boards'];

  Map<String, dynamic> toJson() =>
      {'title': title, 'ip': ip, 'key': key, 'ieee': _ieee, 'boards': _boards};

  List<Board> get boards {
    return [..._boards];
  }

  String get ieee {
    return hex.encode(_ieee);
  }

  bool condition(int value) {
    if (_ieee[7] == value)
      return true;
    else
      return false;
  }

  void deleteBoard(int index) {
    _boards.removeAt(index);
  }

  void addBoard(Board board) {
    if (_boards.indexWhere((e) => e.ieee == board.ieee) == -1 &&
        board.type != 0) _boards.add(board);
  }

  void removeBoards() {
    for (int i = 0; i < _boards.length; i++) {
      if (_boards[i].type == 0) {
        deleteBoard(i);
        i--;
      }
    }
  }

  void getBoards(List<int> data) {
    int _numb = (data[5] * 10) + data[6];
    print("NUMBER OF DEVICES :  $_numb");
    for (int i = 0; i < _numb; i++) {
      final _ieee = '3cc1f6060000${hex.encode([
            data[10 + (i * 4) - 1]
          ])}${hex.encode([data[10 + (i * 4)]])}';
      print("_IEEE :  $_ieee");
      if (_boards.indexWhere((e) => e.ieee == _ieee) == -1) {
        //print("OHHHHHHHHHHHHH NOOOOOOOOOOOOOOOOOOOO");
        _boards.add(
          Board(_ieee, '', 0, []),
        );
      }
    }
  }
}
