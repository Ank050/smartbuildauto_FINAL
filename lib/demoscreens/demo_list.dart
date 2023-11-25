import 'package:flutter/material.dart';

import '../data/image.dart' as i;
import './demo_relay.dart';

class DemoList extends StatelessWidget {
  final relayType = [0x02, 0x2c, 0x05, 0x2e, 0x2f, 0x27, 0x34, 0x35, 0x36];

  _navigate(int ind, BuildContext context) {
    switch (relayType[ind]) {
      case 0x02:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (ctx) => DemoRelay(1, 0)));
        break;
      case 0x2c:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (ctx) => DemoRelay(2, 0)));
        break;
      case 0x05:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (ctx) => DemoRelay(4, 0)));
        break;
      case 0x2e:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (ctx) => DemoRelay(4, 2)));
        break;
      case 0x2f:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (ctx) => DemoRelay(5, 1)));
        break;
      case 0x27:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (ctx) => DemoRelay(6, 0)));
        break;
      case 0x34:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (ctx) => DemoRelay(8, 2)));
        break;
      case 0x35:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (ctx) => DemoRelay(9, 1)));
        break;
      case 0x36:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (ctx) => DemoRelay(10, 0)));
        break;
      default:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: i.header(), title: Text('Smart Home')),
      body: Container(
        color: Colors.blueGrey[900],
        padding: EdgeInsets.symmetric(vertical: 10),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (ctx, index) {
            return TextButton(
              onPressed: () => _navigate(index, context),
              child: Column(
                children: [
                  Text(
                    i.demoboard[relayType[index]]![0],
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(height: 5),
                  Container(
                    height: 78,
                    width: 90,
                    child: Image.asset(i.demoboard[relayType[index]]![1]),
                  ),
                ],
              ),
            );
          },
          itemCount: 9,
        ),
      ),
    );
  }
}
