import 'package:flutter/material.dart';

class Fan extends StatefulWidget {
  final Function speed;
  final double initSpeed;

  Fan(this.speed, this.initSpeed);

  @override
  _FanState createState() => _FanState();
}

class _FanState extends State<Fan> {
  var _fanspeed = 0.0;

  @override
  void initState() {
    _fanspeed = widget.initSpeed;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        height: 30,
        child: Row(
          children: [
            const Text('0'),
            Slider(
              value: _fanspeed,
              divisions: 7,
              min: 0.0,
              max: 7.0,
              label: _fanspeed.toInt().toString(),
              onChanged: (val) {
                setState(() {
                  _fanspeed = val;
                });
              },
              onChangeEnd: (val) {
                setState(() {
                  _fanspeed = val;
                  widget.speed(val);
                });
              },
              activeColor: Theme.of(context).primaryColor,
            ),
            const Text('7')
          ],
        ),
      ),
    );
  }
}
