import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Disc Resource',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Disc Resource'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  String result = "";
  final MethodChannel _methodChannel =
      const MethodChannel('com.hondayt.disc.resource');

  Future<void> requestAuth() async {
    try {
      await _methodChannel.invokeMethod('requestAuth');
    } on PlatformException catch (e) {
      print(e);
    }
  }

  Future<void> checkAuthStatus() async {
    var response = await _methodChannel.invokeMethod('checkAuthStatus');
    setState(() {
      result = response;
    });
  }

  Future<void> checkAndRequestAuth() async {
    checkAuthStatus();
    if (result == "authorized") {
      print("authorized");
    } else {
      await requestAuth();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(result),
            ElevatedButton(
              onPressed: () {
                checkAndRequestAuth();
              },
              child: const Text("Request authorization"),
            ),
          ],
        ),
      ),
    );
  }
}
