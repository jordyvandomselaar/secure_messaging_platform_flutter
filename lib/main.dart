import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Page(
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Column(
              children: [
                Text(
                  "Send an encrypted message",
                  style: Theme.of(context).textTheme.headline3,
                ),
                Text(
                    "Send any message safe and secure. Because your message is encrypted on your device, your private data can only be read by the intended recipient.")
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Container(
                color: Colors.white.withOpacity(.3),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        decoration: InputDecoration(hintText: "Your Message"),
                        minLines: 10,
                        maxLines: null,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: ElevatedButton(
                            onPressed: () {}, child: Text("Encrypt Message")),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class Page extends StatelessWidget {
  final Widget child;

  Page({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Color.fromRGBO(117, 121, 255, 1),
            Color.fromRGBO(178, 36, 239, 1),
          ])),
          child: FractionallySizedBox(
            widthFactor: .8,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 40, bottom: 100),
                  child: Text(
                    "Secure Messaging Platform",
                    style: Theme.of(context).textTheme.headline3,
                  ),
                ),
                child
              ],
            ),
          ),
        ),
      ),
    );
  }
}
