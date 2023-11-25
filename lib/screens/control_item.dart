// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:convert/convert.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/image.dart' as i;
import './relay_screen.dart';
import '../data/board.dart';

const lamplist = {
  0x02: ['Lamp1'],
  0x2c: ['Lamp1', 'Lamp2'],
  0x05: ['Lamp1', 'Lamp2', 'Lamp3', 'Lamp4'],
  0x2e: ['Lamp1', 'Lamp2', 'Lamp3', 'Lamp4'],
  0x2f: ['Lamp1', 'Lamp2', 'Lamp3', 'Lamp4', 'Lamp5'],
  0x27: ['Lamp1', 'Lamp2', 'Lamp3', 'Lamp4', 'Lamp5', 'Lamp6'],
  0x34: [
    'Lamp1',
    'Lamp2',
    'Lamp3',
    'Lamp4',
    'Lamp5',
    'Lamp6',
    'Lamp7',
    'Lamp8'
  ],
  0x35: [
    'Lamp1',
    'Lamp2',
    'Lamp3',
    'Lamp4',
    'Lamp5',
    'Lamp6',
    'Lamp7',
    'Lamp8',
    'Lamp9'
  ],
  0x36: [
    'Lamp1',
    'Lamp2',
    'Lamp3',
    'Lamp4',
    'Lamp5',
    'Lamp6',
    'Lamp7',
    'Lamp8',
    'Lamp9',
    'Lamp10'
  ]
};

class ControlItem extends StatefulWidget {
  static final route = 'controlitem';

  @override
  _ControlItemState createState() => _ControlItemState();
}

class _ControlItemState extends State<ControlItem> {
  bool _searching = false;
  Socket? _sock;
  late BuildContext _context;
  bool _loading = true;
  final _key = GlobalKey<FormFieldState>();
  var _data;

  @override
  void initState() {
    _connect();
    _getData();
    super.initState();
  }

  _connect() async {
    _sock = await Socket.connect(i.list[i.n].ip, 5555);
    print("IP");
    print(i.list[i.n].ip);
  }

  _search() {
    if (i.gate) {
      setState(() {
        _searching = true;
      });

      final List<int> _s = hex.decode('2b0502007274');
      print("_S : ");
      print(_s);
      _sock!.add(_s);
      Future.delayed(
        Duration(seconds: 3),
        () {
          setState(
            () {
              _searching = false;
            },
          );
        },
      );
    }
  }

  _type(int ind) {
    final List<int> _s =
        hex.decode('2b1401${i.list[i.n].boards[ind].ieee}ffff0800000001000005');
    print("TYPE : $_s");
    print("IEEE ADD : ${hex.decode(i.list[i.n].boards[ind].ieee)}");
    _sock!.add(_s);
    setState(
      () {},
    );
  }

  _navigate(int ind) {
    final _element = i.list[i.n].boards[ind];
    i.list[i.n].removeBoards();
    ind = i.list[i.n].boards.indexOf(_element);
    final _ieee = hex.decode(i.list[i.n].boards[ind].ieee)[7];
    switch (i.list[i.n].boards[ind].type) {
      case 0x02:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => RelayScreen(1, 0, ind),
            settings: RouteSettings(arguments: _ieee),
          ),
        );
        break;
      case 0x2c:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => RelayScreen(2, 0, ind),
            settings: RouteSettings(arguments: _ieee),
          ),
        );
        break;
      case 0x05:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => RelayScreen(4, 0, ind),
            settings: RouteSettings(arguments: _ieee),
          ),
        );
        break;
      case 0x2e:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => RelayScreen(4, 2, ind),
            settings: RouteSettings(arguments: _ieee),
          ),
        );
        break;
      case 0x2f:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => RelayScreen(5, 1, ind),
            settings: RouteSettings(arguments: _ieee),
          ),
        );
        break;
      case 0x27:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => RelayScreen(6, 0, ind),
            settings: RouteSettings(arguments: _ieee),
          ),
        );
        break;
      case 0x34:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => RelayScreen(8, 2, ind),
            settings: RouteSettings(arguments: _ieee),
          ),
        );
        break;
      case 0x35:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => RelayScreen(9, 1, ind),
            settings: RouteSettings(arguments: _ieee),
          ),
        );
        break;
      case 0x36:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => RelayScreen(10, 0, ind),
            settings: RouteSettings(arguments: _ieee),
          ),
        );
        break;
      default:
        print("TYPE 0");
    }
  }

  _longpress(int ind) {
    String _name = '';
    showDialog(
      context: _context,
      builder: (cont) {
        return AlertDialog(
          content: Container(
            child: Form(
              key: _key,
              child: TextFormField(
                decoration: InputDecoration(labelText: "Name"),
                autofocus: true,
                initialValue: i.list[i.n].boards[ind].name,
                maxLength: 15,
                onChanged: (val) => _name = val,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  i.list[i.n].boards[ind].name = _name;
                });
                _storeData();
                Navigator.of(cont).pop();
              },
              child: Text("Save"),
            ),
            TextButton(
              onPressed: () {
                i.list[i.n].deleteBoard(ind);
                Navigator.of(cont).pop();
                _storeData();
                setState(() {});
              },
              child: Text(
                "Delete",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
              ),
            )
          ],
        );
      },
    );
  }

  _storeData() async {
    final pref = await SharedPreferences.getInstance();
    final _key = i.list[i.n].ieee;
    final String listJson =
        json.encode(i.list[i.n].boards.map((e) => e.toJson()).toList());
    pref.setString('board $_key', listJson);
    print("LIST : $listJson");
  }

  _getData() async {
    print("GETDATA IS CALLED");
    final pref = await SharedPreferences.getInstance();
    final _key = i.list[i.n].ieee;
    if (pref.containsKey('board $_key')) {
      final String? boards = pref.getString('board $_key');
      final decodedType = json.decode(boards!);
      for (int x = 0; x < decodedType.length; x++) {
        i.list[i.n].addBoard(
          Board(
            decodedType[x]['ieee'],
            decodedType[x]['name'],
            decodedType[x]['type'],
            decodedType[x]['lamps'].cast<String>(),
          ),
        );
      }
    }
    setState(
      () {
        _loading = false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
      appBar: AppBar(
        leading: i.header(),
        title: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            'Smart Build',
            style: GoogleFonts.montserrat(
              fontSize: 30,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Image.asset(i.gate ? i.home : i.internet),
          ),
          IconButton(
            icon: Icon(
              Icons.search_sharp,
              color: Theme.of(context).iconTheme.color,
              size: 30,
            ),
            onPressed: () => _search(),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
      body: _loading
          ? Center(
              child: _searching
                  ? CircularProgressIndicator()
                  : CircularProgressIndicator(),
            )
          : StreamBuilder(
              stream: _sock,
              builder: (ctx, snap) {
                print(
                    "-----------------------------------------------------------------------------");
                print(snap.data);

                if (snap.hasData && snap.data != _data) {
                  print("INSIDE1");
                  List<int> temp = snap.data as List<int>;
                  if (temp[2] == 0x82) {
                    print("INSIDE2");
                    i.list[i.n].getBoards(temp);
                  }
                  _storeData();
                  if (temp.length > 24) {
                    if (temp[18] == 0x01 &&
                        (temp[15] + temp[16]) == 0 &&
                        lamplist.containsKey(temp[24])) {
                      print("INSIDE3");
                      String _b = hex.encode([temp[10]]);
                      String _g = hex.encode([temp[9]]);
                      final String _c = '3cc1f6060000$_g$_b';
                      final _index =
                          i.list[i.n].boards.indexWhere((e) => e.ieee == _c);
                      if (_index != -1) {
                        print("INSIDE4");
                        i.list[i.n].boards[_index].type = temp[24];
                        i.list[i.n].boards[_index].setlamps(
                          lamplist[temp[24]]!,
                        );
                        i.list[i.n].boards[_index].name =
                            i.demoboard[temp[24]]![0];
                        _storeData();
                      }
                    }
                  }
                  _data = snap.data;
                  print("DATA : $_data");
                }
                return Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width /
                            1.04, // Set width to half the screen width
                        height: 80,
                        child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.black), // Border color
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color.fromARGB(255, 106, 107, 107)
                                          .withOpacity(0.7),
                                  spreadRadius: 1,
                                  blurRadius: 1,
                                  offset: Offset(0, 3),
                                )
                              ], // Border radius
                              color: Colors.black, // Background color
                            ),
                            padding: EdgeInsets.all(
                                10), // Padding inside the container
                            child: Column(
                              children: [
                                Text(
                                  'GATEWAY',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                SizedBox(
                                    height:
                                        5), // Add some space between the texts
                                Text(
                                  i.list[i.n].title,
                                  style: GoogleFonts.bebasNeue(
                                    fontSize: 30,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.05,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemBuilder: (ctx, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 237, 236, 236)
                                      .withOpacity(1),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color.fromARGB(
                                              255, 190, 189, 189)
                                          .withOpacity(1),
                                      spreadRadius: 2,
                                      blurRadius: 3,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextButton(
                                  onLongPress: () {
                                    if (i.list[i.n].boards.isNotEmpty &&
                                        i.list[i.n].boards[index].type != 0) {
                                      print("LONGPRESS");
                                      _longpress(index);
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text("Warning"),
                                            content: Text(
                                                "Cannot perform a long press on an empty or invalid item."),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text("OK"),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  },
                                  onPressed: () {
                                    if (i.list[i.n].boards.isEmpty ||
                                        i.list[i.n].boards[index].type == 0) {
                                      _type(index);
                                    } else {
                                      _navigate(index);
                                    }
                                  },
                                  child: (i.list[i.n].boards.isEmpty ||
                                          i.list[i.n].boards[index].type == 0)
                                      ? Column(
                                          children: [
                                            Text(
                                              "FOUND",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Image.asset(
                                              "images/found.png",
                                              scale: 0.6,
                                              width:
                                                  100, // Adjust the width as needed
                                              height:
                                                  100, // Adjust the height as needed
                                            ),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            Text(
                                              i.list[i.n].boards[index].name,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 25,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            Container(
                                              height: 100,
                                              width: 100,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: Image.asset(
                                                  (i.list[i.n].boards[index]
                                                              .type ==
                                                          2)
                                                      ? 'images/smartplug 6.png' // replace with the actual path
                                                      : i.demoboard[i
                                                          .list[i.n]
                                                          .boards[index]
                                                          .type]![1],
                                                  fit: BoxFit
                                                      .contain, // Change BoxFit.cover to BoxFit.contain
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              );
                            },
                            itemCount: i.list[i.n].boards.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    i.list[i.n].removeBoards();
    _sock!.close();
    super.dispose();
  }
}
