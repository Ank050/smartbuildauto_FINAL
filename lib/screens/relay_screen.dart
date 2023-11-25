import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:convert/convert.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/image.dart' as i;
import '../widgets/fan.dart';

class RelayScreen extends StatefulWidget {
  final int bulbNum;
  final int fanNum;
  final int index;

  RelayScreen(this.bulbNum, this.fanNum, this.index);

  @override
  _RelayScreenState createState() => _RelayScreenState();
}

class _RelayScreenState extends State<RelayScreen> {
  final _key = GlobalKey<FormFieldState>();
  List<bool> _load = List.filled(10, false),
      _double = List.filled(10, false),
      _two = List.filled(10, false),
      _fan = [false, false];
  List<double> _fanspeed = [0.0, 0.0];
  late List<int> _masterdata, _masterieee, _masterload = [-1, -1];
  bool _master = false, _doubleConfig = false, _loading = true, _timer = false;
  bool _slaveSelect = false;
  IconData _icon = Icons.brightness_1_outlined;
  Socket? _sock;
  late BuildContext _context;
  String _back = '';
  double _h = 0, _w = 0;
  int _select = 0;
  var _data;

  @override
  void initState() {
    _connect();
    super.initState();
  }

  _connect() async {
    if (i.gate)
      _sock = await Socket.connect(i.list[i.n].ip, 5555);
    else {
      _sock = await Socket.connect('35.200.222.22', 30690);
      setState(() {
        _sock!.add('ANDROIDID:${i.devid.toUpperCase()} 00 100'.codeUnits);
      });
    }
    _setinitial();
  }

  _setinitial() {
    final List<int> _s = hex.decode(
        '${i.gate ? '' : '2b1d47${i.list[i.n].ieee}'}2b1201${i.list[i.n].boards[widget.index].ieee}ffff08fc5001010e');
    _sock!.add(_s);
    setState(
      () {
        _loading = false;
      },
    );
  }

  _control(int numb) {
    final List<int> _s = hex.decode(
        '${i.gate ? '' : '2b2147${i.list[i.n].ieee}'}2b1601${i.list[i.n].boards[widget.index].ieee}ffff08fc500101000300100$numb');
    _sock!.add(_s);
    setState(() {});
  }

  _toggle(String type) {
    final List<int> _s = hex.decode(
        '${i.gate ? '' : '2b1d47${i.list[i.n].ieee}'}2b1201${i.list[i.n].boards[widget.index].ieee}ffff${type}0006010102');
    _sock!.add(_s);
    setState(() {});
  }

  _fanoff(String type) {
    final List<int> _s = hex.decode(
        '${i.gate ? '' : '2b2247${i.list[i.n].ieee}'}2b1701${i.list[i.n].boards[widget.index].ieee}ffff${type}0008110103200121ffff');
    _sock!.add(_s);
    setState(() {});
  }

  _speedchange(String type, int level) {
    final List<int> _s = hex.decode(
        '${i.gate ? '' : '2b2247${i.list[i.n].ieee}'}2b1701${i.list[i.n].boards[widget.index].ieee}ffff${type}0008110100200${level}21ffff');
    _sock!.add(_s);
    setState(() {});
  }

  _backlight(String val) {
    _back = val;
    final List<int> _s = hex.decode(
        '2b1701${i.list[i.n].boards[widget.index].ieee}ffff08fc50110112030010000$val');
    _sock!.add(_s);
    setState(() {});
  }

  _readmaster() {
    final List<int> _s = hex.decode(
        '2b1601${i.list[i.n].boards[widget.index].ieee}ffff08fc5011011003001001');
    _sock!.add(_s);
    //setState(() {});
  }

  _removeslave(String type) {
    final List<int> _s = hex.decode(
        '2d1601${i.list[i.n].boards[widget.index].ieee}ffff${type}fc5000011003000002');
    _sock!.add(_s);
    setState(() {});
  }

  _writemaster() {
    _masterdata[_masterload[1] + 23] = _masterload[1] + 8;
    _masterdata[22] = 0;
    for (int x = 0; x < 4; x++) {
      _masterdata[4 * _masterload[1] + x + 35] = _masterdata[x + 7];
      _masterdata[x + 7] = _masterieee[x + 4];
    }
    _sock!.add(_masterdata);
    setState(() {});
  }

  _writeslave() {
    _masterdata[_masterload[1] + 23] = _masterload[1] + 0x88;
    List<int> _ieee = hex.decode(i.list[i.n].boards[widget.index].ieee);
    for (int x = 0; x < 4; x++) {
      _masterdata[4 * _masterload[1] + x + 35] = _masterdata[x + 7];
      _masterdata[x + 7] = _ieee[x + 4];
    }
    _sock!.add(_masterdata);
  }

  _doubleTap() {
    showDialog(
      context: _context,
      builder: (ctx) => AlertDialog(
        content: Text(
            'Do you want to ${_double[_select] ? 'disable' : 'enable'} double tap for ${i.list[i.n].boards[widget.index].lamps[_select]}?'),
        actions: [
          TextButton(
            onPressed: () {
              String _l = '';
              for (int i = 0; i < widget.bulbNum; i++) {
                if (i == _select) {
                  _l += _double[i] ? '00' : '01';
                  continue;
                }
                _l += _double[i] ? '01' : '00';
              }
              final List<int> _s = hex.decode(
                  '2b${(widget.bulbNum + 22).toRadixString(16)}01${i.list[i.n].boards[widget.index].ieee}ffff08fc5011011103001000$_l');
              _sock!.add(_s);
              Navigator.pop(ctx);
              setState(
                () {
                  _doubleConfig = false;
                },
              );
            },
            child: Text('Yes'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(
                () {
                  _doubleConfig = false;
                },
              );
            },
            child: Text('No'),
          )
        ],
      ),
    );
  }

  _twoWay() {
    showDialog(
      context: _context,
      builder: (ctx) => AlertDialog(
        title:
            Text('Select the device for master', textAlign: TextAlign.center),
        content: Container(
          height: _h / 1.7,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 5,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (ctx, index) {
              return TextButton(
                onPressed: () {
                  _masterload[0] = index;
                  _masterieee = hex.decode(i.list[i.n].boards[index].ieee);
                  _loadselect(ctx);
                },
                child: Column(
                  children: [
                    Text(i.list[i.n].boards[index].name),
                    SizedBox(height: 5),
                    Container(
                      height: _h / 18,
                      width: _w / 3,
                      child: Image.asset(
                        i.demoboard[i.list[i.n].boards[index].type]![1],
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              );
            },
            itemCount: i.list[i.n].boards.length,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _masterieee = [];
              Navigator.of(ctx).pop();
            },
            child: Text('Cancel'),
          )
        ],
      ),
    );
  }

  _loadselect(BuildContext ctx) {
    showDialog(
      context: _context,
      builder: (cont) => AlertDialog(
        title: Text('Select the master load', textAlign: TextAlign.center),
        content: Container(
          height: _h / 1.5,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 5,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (ctx, index) {
              return TextButton(
                onPressed: () {
                  _masterload[1] = index;
                  _writemaster();
                  Navigator.of(cont).pop();
                  Navigator.of(ctx).pop();
                },
                child: Column(
                  children: [
                    Text(i.list[i.n].boards[_masterload[0]].lamps[index]),
                    SizedBox(height: 5),
                    Container(
                      height: _h / 18,
                      width: _w / 3,
                      child: Image.asset(
                        i.lampOn,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              );
            },
            itemCount: i.list[i.n].boards[_masterload[0]].lamps.length,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _masterieee = [];
              Navigator.of(cont).pop();
              Navigator.of(ctx).pop();
            },
            child: Text('Cancel'),
          )
        ],
      ),
    );
  }

  Widget _loadbutton(int n, String type) {
    return Column(
      children: [
        Text(i.list[i.n].boards[widget.index].lamps[n - 1]),
        TextButton(
          onPressed: () {
            if (!_two[n - 1]) {
              if (_doubleConfig) {
                setState(() {
                  _select = n - 1;
                  ScaffoldMessenger.of(_context).hideCurrentSnackBar();
                });
                _doubleTap();
              } else if (_slaveSelect) {
                if (_double[n - 1]) {
                  showDialog(
                    context: _context,
                    builder: (ctx) => AlertDialog(
                      content: Text(
                          'The selected load should not be in any other configuration'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                          child: Text('OK'),
                        )
                      ],
                    ),
                  );
                } else {
                  setState(() {
                    _select = n - 1;
                    _slaveSelect = false;
                    ScaffoldMessenger.of(_context).hideCurrentSnackBar();
                  });
                  _twoWay();
                }
              } else {
                if (_double[n - 1] && !_timer) {
                  showDialog(
                    context: _context,
                    builder: (ctx) => AlertDialog(
                      content: Text(
                          'Do you really want to switch ${_load[n - 1] ? 'off' : 'on'}?'),
                      actions: [
                        TextButton(
                            onPressed: () {
                              _timer = true;
                              Timer(Duration(seconds: 5), () => _timer = false);
                              ScaffoldMessenger.of(_context).showSnackBar(
                                  SnackBar(
                                      content: Text('Press the switch again')));
                              Navigator.pop(ctx);
                            },
                            child: Text('Yes')),
                        TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text('No'))
                      ],
                    ),
                  );
                }
                if (!_double[n - 1] || _timer) {
                  _timer = false;
                  _toggle(type);
                }
              }
            } else if (_slaveSelect) {
              _select = n - 1;
              _slaveSelect = false;
              showDialog(
                context: _context,
                builder: (ctx) => AlertDialog(
                  content: Text(
                      'Do you want to disable two way for ${i.list[i.n].boards[widget.index].lamps[_select]}?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        _removeslave(type);
                        Navigator.of(ctx).pop();
                      },
                      child: Text('Yes'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: Text('No'),
                    )
                  ],
                ),
              );
            }
          },
          onLongPress: () {
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
                        initialValue:
                            i.list[i.n].boards[widget.index].lamps[n - 1],
                        maxLength: 15,
                        onChanged: (val) => _name = val,
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          //i.list[i.n].boards[widget.index] = _name;
                          i.list[i.n].boards[widget.index]
                              .setlamp(n - 1, _name);
                        });
                        Navigator.of(cont).pop();
                        //_storeData();
                      },
                      child: Text("Save"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(cont).pop();
                      },
                      child: Text("Cancel"),
                    )
                  ],
                );
              },
            );
          },
          child: Container(
            height: widget.bulbNum < 7 ? _h / 7 : _h / 9.5,
            width: widget.bulbNum < 7 ? _w / 4 : _w / 5.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                  image: AssetImage(_two[n - 1]
                      ? i.twoWay
                      : (_double[n - 1]
                          ? (_load[n - 1] ? i.dOn : i.dOff)
                          : (_load[n - 1] ? i.lampOn : i.lampOff))),
                  fit: BoxFit.contain),
            ),
          ),
          style: TextButton.styleFrom(shape: CircleBorder()),
        )
      ],
    );
  }

  _fanbutton(int n, String type) {
    return TextButton(
        onPressed: () {
          if (_fan[n - 1])
            _fanoff(type);
          else
            _toggle(type);
        },
        child: Container(
          height: _h / 14,
          width: _w / 8,
          child: _fan[n - 1]
              ? Image.asset(i.fan[_fanspeed[n - 1].toInt()])
              : Image.asset(i.fanOff),
        ),
        onLongPress: () {
          if (_fan[n - 1])
            showDialog(
                context: _context,
                builder: (c) =>
                    Fan((n == 1) ? _speed1 : _speed2, _fanspeed[n - 1]));
        });
  }

  _speed1(double val) {
    _speedchange('0c', val.toInt());
  }

  _speed2(double val) {
    _speedchange('10', val.toInt());
  }

  void _settings(String choice) {
    if (choice == '1') {
      ScaffoldMessenger.of(_context).showSnackBar(SnackBar(
        duration: Duration(seconds: 10),
        content: Text('Select the load to set double tap'),
      ));
      setState(() {
        _doubleConfig = true;
        Timer(Duration(seconds: 30), () {
          setState(() {
            _doubleConfig = false;
          });
        });
      });
    } else if (choice == '2') {
      ScaffoldMessenger.of(_context).showSnackBar(SnackBar(
        duration: Duration(seconds: 10),
        content: Text('Select the slave switch'),
      ));
      setState(() {
        _readmaster();
        _slaveSelect = true;
        Timer(Duration(seconds: 60), () {
          if (_slaveSelect)
            setState(() {
              _slaveSelect = false;
            });
        });
      });
    } else if (choice == '3') {
      showDialog(
        context: _context,
        useSafeArea: true,
        builder: (cont) {
          return AlertDialog(
            title: Center(child: Text('Select a configuration')),
            content: Container(
              height: _h / 4,
              width: _w / 1.5,
              child: ListView(children: [
                Card(
                  color: Colors.grey[300],
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(cont).pop();
                      _backlight('0');
                    },
                    child: Text('Continuous ON'),
                  ),
                ),
                Card(
                  color: Colors.grey[300],
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(cont).pop();
                      _backlight('1');
                    },
                    child: Text('Delayed OFF'),
                  ),
                ),
                Card(
                  color: Colors.grey[300],
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(cont).pop();
                      _backlight('2');
                    },
                    child: Text('Delayed Dim'),
                  ),
                ),
              ]),
            ),
          );
        },
      );
    }
  }

  _storeData() async {
    final pref = await SharedPreferences.getInstance();
    final _key = i.list[i.n].ieee;
    final String listJson =
        json.encode(i.list[i.n].boards.map((e) => e.toJson()).toList());
    pref.setString('board $_key', listJson);
  }

  errormessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occured. Try again')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _ieee = ModalRoute.of(context)!.settings.arguments;
    _context = context;
    _h = MediaQuery.of(context).size.height;
    _w = MediaQuery.of(context).size.width;
    return StreamBuilder(
      stream: _sock,
      builder: (ctx, snap) {
        if (snap.hasData) {
          List _temp = snap.data as List<int>;
          if (!i.gate) _temp = _temp.sublist(11, _temp.length);
          if (_temp != _data) {
            if (_temp[10] == _ieee) {
              if (_temp[18] == 0x01 && _temp.length > 25) {
                for (int k = 0, x = 0; k < widget.bulbNum; k++) {
                  if (k == 4 || k == 7) x++;
                  _load[k] = (_temp[k + x + 20] % 16 != 0);
                  _double[k] = (_temp[k + x + 20] ~/ 16 == 1);
                  _two[k] = (_temp[k + x + 20] ~/ 16 == 2);
                }
                for (int k = 0; k < widget.fanNum; k++) {
                  _fan[k] = (_temp[24 + k * 4] ~/ 16 == 0);
                  _fanspeed[k] =
                      _fan[k] ? _temp[24 + k * 4].toDouble() : _fanspeed[k];
                }
              } else if (_temp[18] == 0x11) {
                if (_temp[22] == 0x00) {
                  try {
                    _double[_select] = !_double[_select];
                    _select = -1;
                  } catch (_) {}
                  if (_back == '0')
                    _icon = Icons.brightness_7;
                  else if (_back == '1')
                    _icon = Icons.brightness_5;
                  else if (_back == '2') _icon = Icons.brightness_6;
                } else
                  errormessage();
              } else if (_temp[18] == 0x10) {
                if (_temp[1] == 0x52 && _masterdata == [])
                  _masterdata = _temp as List<int>;
                else {
                  if (_temp[22] == 0) {
                    if (_two[_select]) {
                      _two[_select] = false;
                    } else {
                      _two[_select] = true;
                      _masterdata = [];
                      _masterload = [-1, -1];
                      _masterieee = [];
                    }
                    _select = -1;
                  } else
                    errormessage();
                }
              }
            } else if (_temp[10] == _masterieee[7]) {
              if (_temp[22] == 0) {
                _writeslave();
              } else
                errormessage();
            }
          }
          _data = _temp;
        }
        if (widget.bulbNum > 1) {
          _master = false;
          for (int k = 0; k < widget.bulbNum; k++)
            _master = (_master || _load[k]);
          for (int k = 0; k < widget.fanNum; k++)
            _master = (_master || _fan[k]);
        }
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
              if (_icon != Icons.brightness_1_outlined)
                Icon(
                  _icon,
                  color: Theme.of(context).iconTheme.color,
                ),
              if (i.gate)
                PopupMenuButton(
                  icon: Icon(
                    Icons.settings,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  itemBuilder: (ctx) {
                    return [
                      PopupMenuItem<String>(
                        child: Text('Double Tap'),
                        value: '1',
                      ),
                      PopupMenuItem<String>(
                        child: Text('Backlight'),
                        value: '3',
                      )
                    ];
                  },
                  onSelected: _settings,
                )
            ],
          ),
          body: _loading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(children: [
                    SizedBox(height: 10),
                    Image.asset(i.room,
                        height: _h / 5,
                        width: double.infinity,
                        fit: BoxFit.fill),
                    SizedBox(height: 5),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          Center(
                            child: Container(
                              width: 400,
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        const Color.fromARGB(255, 106, 107, 107)
                                            .withOpacity(0.7),
                                    spreadRadius: 1,
                                    blurRadius: 1,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "SMART SWITCH BOARD",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal,
                                      color: Color.fromARGB(255, 147, 147, 147),
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "${i.list[i.n].boards[widget.index].name}",
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white,
                                      letterSpacing: 1.2,
                                      shadows: [
                                        BoxShadow(
                                          color: Colors.indigo.withOpacity(0.7),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          if (widget.bulbNum > 1)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Transform.scale(
                                          scale: 1.5,
                                          child: Switch(
                                            value: _master,
                                            onChanged: (newVal) {
                                              setState(() {
                                                _master = newVal;
                                              });
                                              _control(_master ? 1 : 0);
                                            },
                                            activeColor: Colors
                                                .blue, // Customize the active color
                                            activeTrackColor: const Color
                                                .fromARGB(255, 179, 178,
                                                178), // Customize the active track color
                                            inactiveThumbColor: Color.fromARGB(
                                                255,
                                                245,
                                                99,
                                                99), // Customize the inactive thumb color
                                            inactiveTrackColor: Color.fromARGB(
                                                255,
                                                179,
                                                178,
                                                178), // Customize the inactive track color
                                          ),
                                        ),
                                        SizedBox(width: 1),
                                        Text(
                                          'Master',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    if (!_master)
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          _control(2);
                                        },
                                        icon: Icon(Icons.cached_sharp),
                                        label: Text('Restore'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors
                                              .blue, // Choose a color that fits your theme
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                        ),
                                      )
                                  ],
                                ),
                                if (widget.fanNum > 0)
                                  Row(
                                    children: [
                                      _fanbutton(1, '0c'),
                                      if (widget.fanNum == 2)
                                        _fanbutton(2, '10')
                                    ],
                                  )
                              ],
                            ),
                          SizedBox(height: _h / 30),
                          Container(
                            height: _h / 2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    _loadbutton(1, '08'),
                                    if (widget.bulbNum > 2 &&
                                        widget.bulbNum < 5)
                                      _loadbutton(3, '0a'),
                                    if (widget.bulbNum > 4 &&
                                        widget.bulbNum < 7)
                                      _loadbutton(4, '0b'),
                                    if (widget.bulbNum > 6)
                                      _loadbutton(5, '0d'),
                                    if (widget.bulbNum > 8)
                                      _loadbutton(9, '12'),
                                  ],
                                ),
                                if (widget.bulbNum > 1)
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      _loadbutton(2, '09'),
                                      if (widget.bulbNum == 4)
                                        _loadbutton(4, '0b'),
                                      if (widget.bulbNum > 4 &&
                                          widget.bulbNum < 7)
                                        _loadbutton(5, '0d'),
                                      if (widget.bulbNum > 6)
                                        _loadbutton(6, '0e'),
                                      if (widget.bulbNum == 10)
                                        _loadbutton(10, '13'),
                                    ],
                                  ),
                                if (widget.bulbNum > 4)
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      _loadbutton(3, '0a'),
                                      if (widget.bulbNum == 6)
                                        _loadbutton(6, '0e'),
                                      if (widget.bulbNum > 6)
                                        _loadbutton(7, '0f'),
                                    ],
                                  ),
                                if (widget.bulbNum > 6)
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      _loadbutton(4, '0b'),
                                      if (widget.bulbNum > 7)
                                        _loadbutton(8, '11'),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
          floatingActionButton: _doubleConfig || _slaveSelect
              ? FloatingActionButton(
                  backgroundColor: Colors.red,
                  child: Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _doubleConfig = false;
                      _slaveSelect = false;
                      ScaffoldMessenger.of(_context).hideCurrentSnackBar();
                    });
                  },
                )
              : Container(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  @override
  void dispose() {
    if (_sock != null) _sock!.close();
    _storeData();
    super.dispose();
  }
}
