import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './screens/home_screen.dart';
import './screens/about.dart';
import './screens/control_item.dart';

void main() {
  runApp(
    const MyApp(),
  );
}

const Map<int, Color> color = {
  50: Color.fromRGBO(255, 255, 255, .1),
  100: Color.fromRGBO(255, 255, 255, .2),
  200: Color.fromRGBO(255, 255, 255, .3),
  300: Color.fromRGBO(255, 255, 255, .4),
  400: Color.fromRGBO(255, 255, 255, .5),
  500: Color.fromRGBO(255, 255, 255, .6),
  600: Color.fromRGBO(255, 255, 255, .7),
  700: Color.fromRGBO(255, 255, 255, .8),
  800: Color.fromRGBO(255, 255, 255, .9),
  900: Color.fromRGBO(255, 255, 255, 1),
};

class MyApp extends StatelessWidget {
  const MyApp({key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Home Demo',
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          toolbarTextStyle: const TextTheme(
            titleLarge: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ).bodyMedium,
          titleTextStyle: const TextTheme(
            titleLarge: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ).titleLarge,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        primarySwatch: const MaterialColor(0xFF000000, color),
        primaryColor: Colors.green,
        fontFamily: 'Ubuntu',
        primaryTextTheme:
            const TextTheme(titleLarge: TextStyle(color: Colors.white)),
      ),
      routes: {
        About.route: (ctx) => const About(),
        ControlItem.route: (ctx) => ControlItem()
      },
    );
  }
}
