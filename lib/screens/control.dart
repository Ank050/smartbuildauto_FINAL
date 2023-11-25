import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:convert/convert.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/cluster.dart';
import '../data/image.dart' as i;
import 'control_item.dart';
import '../demoscreens/demo_list.dart';

class Control extends StatefulWidget {
  final demo;

  Control(this.demo);

  @override
  _ControlState createState() => _ControlState();
}

class _ControlState extends State<Control> {
  final _formKey = GlobalKey<FormState>();
  final ip = '255.255.255.255';
  Socket? _server, _sock;
  late String _name, _key, _devip;
  late bool _new;
  late double _h;
  late BuildContext _context;
  @override
  void initState() {
    if (!widget.demo) _getData();
    super.initState();
  }

  _searchNew() {
    bool v = true;
    var _address = InternetAddress(ip);

    Timer(
      Duration(seconds: 8),
      () {
        if (v) {
          ScaffoldMessenger.of(_context).showSnackBar(
            SnackBar(
              content: Text('No new networks found'),
              backgroundColor: Colors.red,
            ),
          );
          v = false;
        }
      },
    );
    print("inside 1 ");
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 8888).then(
      (RawDatagramSocket udpSocket) {
        udpSocket.broadcastEnabled = true;
        udpSocket.listen(
          (e) {
            Datagram? dg = udpSocket.receive();
            if (dg != null &&
                dg.data.length > 6 &&
                dg.data[7] == 192 &&
                dg.data[8] == 168) {
              List<int> _s = [];
              for (int x = 0; x < 3; x++) _s.add(dg.data[x + 4]);
              if (String.fromCharCodes(_s) == 'suv') {
                v = false;
                _devip =
                    '${dg.data[7]}.${dg.data[8]}.${dg.data[9]}.${dg.data[10]}';
                udpSocket.close();
                _form();
              }
            }
          },
        );

        if (!v) {
          udpSocket.close();
          return;
        }

        List<int> data = hex.decode('2b090200737576616e61');
        udpSocket.send(data, _address, 8888);
      },
    );
  }

  _form() {
    showDialog(
      context: _context,
      builder: (cont) => AlertDialog(
        content: Container(
          height: 150,
          width: 100,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(hintText: 'IHD name'),
                  onChanged: (val) => _name = val,
                  validator: (val) {
                    if (val!.isEmpty)
                      return 'Name must not be empty';
                    else {
                      int _newIn = i.list.indexWhere((e) => e.title == _name);
                      if (_newIn == -1)
                        return null;
                      else {
                        return 'Name already exists';
                      }
                    }
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(hintText: 'Security key'),
                  obscureText: true,
                  onChanged: (val) {
                    _key = val;
                  },
                  validator: (val) {
                    if (val!.isEmpty)
                      return 'Key can\'t be empty';
                    else
                      return null;
                  },
                )
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                if (_new) {
                  _writeKey();
                } else {
                  _searchEx();
                }
                Navigator.pop(cont);
              }
            },
            child: Text('Submit'),
          )
        ],
      ),
    );
  }

  _connectnew() async {
    _sock = await Socket.connect(_devip, 5555);
  }

  _writeKey() async {
    await _connectnew();
    List<int> data = hex.decode(
        '2b0${(_key.length + 5).toRadixString(16)}5700554b${hex.encode(_key.codeUnits)}');
    _sock!.add(data);
    _sock!.listen((dg) {
      if (dg[6] == 0) {
        _sock!.close();
        _searchEx();
      } else {
        ScaffoldMessenger.of(_context).showSnackBar(SnackBar(
          content: Text('An error occurred. Try again'),
          backgroundColor: Colors.red,
        ));
        _sock!.close();
        return;
      }
    });
  }

  _searchEx([bool check = false, int? index]) {
    var v = 0;
    var _address = InternetAddress(ip);
    List<String> _k = check ? i.list[index!].key.split('') : _key.split('');
    if (!check)
      Timer(Duration(seconds: 8), () {
        if (v == 0) {
          ScaffoldMessenger.of(_context).showSnackBar(SnackBar(
            content: Text('No existing networks found'),
            backgroundColor: Colors.red,
          ));
          v++;
        }
      });

    RawDatagramSocket.bind(InternetAddress.anyIPv4, 8888).then(
      (RawDatagramSocket udpSocket) {
        udpSocket.broadcastEnabled = true;
        udpSocket.listen(
          (e) {
            Datagram? dg = udpSocket.receive();
            if (dg != null && dg.data[7] == 192 && dg.data[8] == 168) {
              if (check) {
                if (i.list[index!].condition(dg.data[18])) {
                  i.gate = true;
                  udpSocket.close();
                  Navigator.of(context).pushNamed(ControlItem.route);
                }
              } else {
                v++;
                List<int> _s = [];
                for (int x = 0; x < 3; x++) {
                  _s.add(dg.data[x + 4]);
                }
                if (String.fromCharCodes(_s) == '${_k[0]}${_k[1]}${_k[2]}') {
                  String _ip =
                      '${dg.data[7]}.${dg.data[8]}.${dg.data[9]}.${dg.data[10]}';
                  List<int> _ieee = [];
                  for (int x = 0; x < 8; x++) {
                    _ieee.add(dg.data[x + 11]);
                  }
                  i.list.add(Cluster(_name, _ip, _key, _ieee, []));
                  _storeData();
                  udpSocket.close();
                  setState(() {});
                }
              }
            }
          },
        );

        if (v != 0) {
          udpSocket.close();
          return;
        }

        List<int> data;
        check
            ? data = hex.decode(
                '2b0${(i.list[index!].key.length + 3).toRadixString(16)}0200${hex.encode(i.list[index].key.codeUnits)}')
            : data = hex.decode(
                '2b0${(_key.length + 3).toRadixString(16)}0200${hex.encode(_key.codeUnits)}');
        udpSocket.send(data, _address, 8888);
      },
    );
  }

  _storeData() async {
    final pref = await SharedPreferences.getInstance();
    final String listJson = json.encode(i.list.map((e) => e.toJson()).toList());
    pref.setString('gateway', listJson);
  }

  _getData() async {
    final pref = await SharedPreferences.getInstance();
    if (pref.containsKey('gateway') && i.open) {
      final String? data = pref.getString('gateway');
      final decodedData = json.decode(data!);
      for (int x = 0; x < decodedData.length; x++) {
        i.list.add(
          Cluster(
            decodedData[x]['title'],
            decodedData[x]['ip'],
            decodedData[x]['key'],
            decodedData[x]['ieee'].cast<int>(),
            [],
          ),
        );
      }
      setState(
        () {
          i.open = false;
        },
      );
    }
  }

  _removeTile(int ind, BuildContext c) async {
    final pref = await SharedPreferences.getInstance();
    final _key = i.list[ind].ieee;
    if (pref.containsKey('board $_key')) {
      pref.remove('board $_key');
    }
    i.list.removeAt(ind);
    _storeData();
    Navigator.pop(c);
    setState(() {});
  }

  Future<bool> _removeData(int ind) async {
    bool rem = false;
    if (widget.demo) return rem;
    showDialog(
      context: _context,
      builder: (c) {
        return AlertDialog(
          content: Text('Do you really want to delete ${i.list[ind].title}?'),
          actions: [
            TextButton(
              onPressed: () {
                rem = true;
                _removeTile(ind, c);
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(c);
              },
              child: Text('No'),
            )
          ],
        );
      },
    );
    return rem;
  }

  _popup() {
    showDialog(
      context: _context,
      builder: (cont) {
        return AlertDialog(
          title: Text('Smart Home'),
          content: Text('Add Gateway Device'),
          actions: [
            TextButton(
                onPressed: () {
                  _new = false;
                  Navigator.pop(cont);
                  _form();
                },
                child: Text('Existing')),
            TextButton(
              onPressed: () {
                _new = true;
                Navigator.pop(cont);
                _searchNew();
              },
              child: Text('New'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _h = MediaQuery.of(context).size.height;
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
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Image.asset(
              i.room,
              height: _h / 4,
              width: double.infinity,
              fit: BoxFit.fill,
            ),
            Expanded(
              child: ListView.builder(
                physics:
                    BouncingScrollPhysics(), // Use BouncingScrollPhysics for a more modern scroll effect
                padding:
                    EdgeInsets.all(16), // Increase padding for better spacing
                itemBuilder: (ctx, index) {
                  return Card(
                    color: Colors.grey[900], // Dark background color
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.white60),
                    ),
                    child: Dismissible(
                      key: ValueKey<int>(index),
                      direction: DismissDirection.endToStart,
                      background: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 247, 135, 127),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 50,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      confirmDismiss: (_) => _removeData(index),
                      onDismissed: (_) {},
                      child: TextButton(
                        onPressed: () {
                          i.n = index;
                          if (widget.demo) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => DemoList(),
                              ),
                            );
                          } else {
                            _searchEx(true, index);
                          }
                        },
                        child: ListTile(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          leading: Container(
                            width:
                                60, // Adjust the width based on your preference
                            height:
                                60, // Adjust the height based on your preference
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  10), // Adjust the border radius for rounded corners
                              image: DecorationImage(
                                image: AssetImage(
                                    'images/smartplug 6.png'), // Replace 'your_image.png' with the path to your image asset
                                fit: BoxFit.cover, // Cover the entire container
                              ),
                            ),
                          ),
                          title: Text(
                            widget.demo ? 'Demo' : i.list[index].title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            // Adding a subtitle for additional information
                            widget.demo ? 'Demo' : "Gateway",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white60,
                            ),
                          ),
                          trailing: Container(
                            width:
                                40, // Adjust the width based on your preference
                            height:
                                40, // Adjust the height based on your preference
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                  'images/arrow.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                itemCount: widget.demo ? 1 : i.list.length,
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOutQuart,
        margin: EdgeInsets.only(top: 16),
        child: SizedBox(
          width: 60, // Adjust the width based on your preference
          height: 60, // Adjust the height based on your preference
          child: FloatingActionButton(
            elevation: 8,
            backgroundColor: Colors.teal,
            child: Image.asset(
              'images/add.png', // Replace 'your_fab_image.png' with the path to your image asset
              height: 32,
              width: 32,
              color: Colors.white,
            ),
            onPressed: () {
              if (!widget.demo) _popup();
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (!widget.demo && !i.gate) _server!.close();
    super.dispose();
  }
}
