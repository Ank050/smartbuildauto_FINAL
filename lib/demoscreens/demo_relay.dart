import 'package:flutter/material.dart';

import '../data/image.dart' as i;
import '../widgets/fan.dart';

class DemoRelay extends StatefulWidget {
  final int bulbNum;
  final int fanNum;

  DemoRelay(this.bulbNum, this.fanNum);

  @override
  _DemoRelayState createState() => _DemoRelayState();
}

class _DemoRelayState extends State<DemoRelay> {
  List<bool> _lamp = List.filled(10, false), _fan = List.filled(2, false);
  List<double> _fanspeed = List.filled(2, 0.0);
  bool _master = false;
  double _h = 0, _w = 0;

  Widget _lampbutton(int n, String type) {
    return Column(
      children: [
        Text('Lamp$n'),
        TextButton(
          onPressed: () {
            setState(() {
              _lamp[n - 1] = !_lamp[n - 1];
              _checkmaster();
            });
          },
          child: Container(
            height: widget.bulbNum < 7 ? _h / 7 : _h / 9.5,
            width: widget.bulbNum < 7 ? _w / 4 : _w / 5.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                  image: AssetImage(_lamp[n - 1] ? i.lampOn : i.lampOff),
                  fit: BoxFit.contain),
            ),
            //child: Image.asset(_lamp[n - 1] ? i.lampOn : i.lampOff)
          ),
          style: TextButton.styleFrom(shape: CircleBorder()),
        ),
      ],
    );
  }

  _fanbutton(int n, String type, BuildContext cont) {
    return TextButton(
      onPressed: () {
        setState(() {
          _fan[n - 1] = !_fan[n - 1];
          _checkmaster();
        });
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
            context: cont,
            builder: (c) => Fan((n == 1) ? _speed1 : _speed2, _fanspeed[n - 1]),
          );
      },
      style: TextButton.styleFrom(shape: CircleBorder()),
    );
  }

  _checkmaster() {
    _master = false;
    for (int k = 0; k < widget.bulbNum; k++) _master = _master || _lamp[k];
    for (int l = 0; l < widget.fanNum; l++) _master = _master || _fan[l];
  }

  _speed1(double val) {
    setState(() {
      _fanspeed[0] = val;
    });
  }

  _speed2(double val) {
    setState(() {
      _fanspeed[1] = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    _h = MediaQuery.of(context).size.height;
    _w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(leading: i.header(), title: Text('Smart Home')),
      body: Column(children: [
        Image.asset(i.room,
            height: _h / 5, width: double.infinity, fit: BoxFit.fill),
        Padding(
          //color: Colors.blueGrey[900],
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            children: [
              if (widget.bulbNum > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Switch(
                          value: _master,
                          onChanged: (newval) {
                            setState(() {
                              for (int k = 0; k < widget.bulbNum; k++)
                                _lamp[k] = newval;
                              for (int l = 0; l < widget.fanNum; l++)
                                _fan[l] = newval;
                              _master = newval;
                            });
                          },
                          activeColor: Theme.of(context).primaryColor,
                        ),
                        Text('Master'),
                        if (!_master)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                for (int k = 0; k < widget.bulbNum; k++)
                                  _lamp[k] = true;
                                for (int l = 0; l < widget.fanNum; l++)
                                  _fan[l] = true;
                                _master = true;
                              });
                            },
                            child: Column(
                              children: [
                                Text('Restore'),
                                Icon(Icons.cached_sharp)
                              ],
                            ),
                          )
                      ],
                    ),
                    if (widget.fanNum > 0)
                      Row(
                        children: [
                          _fanbutton(1, '0c', context),
                          if (widget.fanNum == 2) _fanbutton(2, '10', context)
                        ],
                      )
                  ],
                ),
              SizedBox(height: _h / 30),
              Container(
                height: _h / 2.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _lampbutton(1, '08'),
                        if (widget.bulbNum > 2 && widget.bulbNum < 5)
                          _lampbutton(3, '0a'),
                        if (widget.bulbNum > 4 && widget.bulbNum < 7)
                          _lampbutton(4, '0b'),
                        if (widget.bulbNum > 6) _lampbutton(5, '0d'),
                        if (widget.bulbNum > 8) _lampbutton(9, '12'),
                      ],
                    ),
                    if (widget.bulbNum > 1)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _lampbutton(2, '09'),
                          if (widget.bulbNum == 4) _lampbutton(4, '0b'),
                          if (widget.bulbNum > 4 && widget.bulbNum < 7)
                            _lampbutton(5, '0d'),
                          if (widget.bulbNum > 6) _lampbutton(6, '0e'),
                          if (widget.bulbNum == 10) _lampbutton(10, '13'),
                        ],
                      ),
                    if (widget.bulbNum > 4)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _lampbutton(3, '0a'),
                          if (widget.bulbNum == 6) _lampbutton(6, '0e'),
                          if (widget.bulbNum > 6) _lampbutton(7, '0f'),
                        ],
                      ),
                    if (widget.bulbNum > 6)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _lampbutton(4, '0b'),
                          if (widget.bulbNum > 7) _lampbutton(8, '11'),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
