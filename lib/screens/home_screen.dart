import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import './about.dart';
import './control.dart';
import '../data/image.dart' as i;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> _pages = ['About', 'Control'];
  final List<String> _images = [
    'images/info.png',
    'images/control.png',
  ];
  bool demo = false;

  void navigate(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushNamed(About.route);
        break;
      case 1:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (ctx) => Control(demo)));
        break;
    }
  }

  void demoChange() {
    setState(() {
      demo = !demo;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Scaffold(
              extendBodyBehindAppBar: true,
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
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 5, left: 0, right: 5, bottom: 5),
                    child: SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        onPressed: demoChange,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: demo
                              ? Color.fromARGB(200, 244, 231, 97)
                              : Colors.teal,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              demo
                                  ? 'images/demo_on.png'
                                  : 'images/demo_off.png',
                              height: 35,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(width: 5),
                            Text(
                              demo ? 'DEMO ON' : 'DEMO OFF',
                              style: TextStyle(
                                color: Color(0xFF000000),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              body: Container(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          height: 70,
                        ),
                        for (int index = _pages.length - 1; index >= 0; index--)
                          Container(
                            margin: EdgeInsets.only(bottom: 25),
                            width: screenWidth * 0.7,
                            height: screenWidth * 0.7,
                            child: InkWell(
                              onTap: () => navigate(index),
                              child: Card(
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      _images[index],
                                      width: screenWidth * 0.45,
                                      fit: BoxFit.cover,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      _pages[index],
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 30,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
