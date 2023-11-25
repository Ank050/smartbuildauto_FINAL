import 'package:flutter/material.dart';

class About extends StatelessWidget {
  const About({Key? key}) : super(key: key);
  static const route = 'about';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'About Smart Build',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'images/icons/logo.png',
              height: 170,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            Text(
              "SmartBuild Automation is on a mission to revolutionize smart home automation, aiming to be the go-to solution for all automation needs. Leveraging a powerful network, innovative products, and a seamless setup process, we are just one glitch away from transforming any home into a smart haven. Our commitment to accessibility, reliability, and affordability drives our vision of becoming a global leader in automation solutions for residential, commercial, and industrial buildings.\n\nFrom our humble beginnings as Melange Systems to the rebranded SmartBuild Automation, we have evolved to offer aesthetically designed touch switchboards, smart sensors, and more. Led by a dedicated team with over a century of combined leadership experience, SmartBuild Automation is poised for continuous growth and excellence in the years to come.",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                height: 1.2,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
