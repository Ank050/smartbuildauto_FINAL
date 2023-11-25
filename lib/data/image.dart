import 'package:flutter/material.dart';

import 'cluster.dart';

bool open = true;
bool gate = true;
String devid = "ANKITH";
List<Cluster> list = [];
//Cluster('Test', '192.168.1.26', 'deep', hex.decode('3CC1F60600000001'), [])
int n = -1;
const demoboard = {
  0x02: ['HTB1', 'images/bulb 1.png'],
  0x2c: ['HTB2', 'images/2 relay.png'],
  0x05: ['HTB4', 'images/4 relay.png'],
  0x2e: ['HTB4D2', 'images/4+2 relay.png'],
  0x2f: ['HTB5D1', 'images/5+1 relay.png'],
  0x27: ['HTB6', 'images/6 relay.png'],
  0x34: ['HTB8D2', 'images/8+2 relay.png'],
  0x35: ['HTB9D1', 'images/9+1 relay.png'],
  0x36: ['HTB10', 'images/10 relay.png']
};
const fan = [
  'images/fan 0.png',
  'images/fan 1.png',
  'images/fan 2.png',
  'images/fan 3.png',
  'images/fan 4.png',
  'images/fan 5.png',
  'images/fan 6.png',
  'images/fan 7.png'
];
const lampOn = 'images/bulb on.png';
const lampOff = 'images/bulb off.png';
const fanOff = 'images/fan off.png';
const info = 'images/add icon.png';
const dOn = 'images/D tap on.png';
const dOff = 'images/D tap off.png';
const twoWay = 'images/two way.png';
const home = 'images/home network.png';
const internet = 'images/internet.png';
const room = 'images/living_room.jpg';

Widget header() {
  return Padding(
    padding: const EdgeInsets.only(top: 5, left: 5),
    child: Image.asset('images/icons/logo.png'),
  );
}
