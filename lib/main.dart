import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

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
  Future<void> requestPermission() async {
    final PermissionStatus status = await Permission.mediaLibrary.request();
    Logger().i('status: $status');
    switch (status) {
      case PermissionStatus.denied:
        Logger().w('権限が拒否されました...');
        break;
      case PermissionStatus.granted:
        Logger().w('権限が許可されました！');
        break;
      case PermissionStatus.restricted:
        Logger().w('権限が制限されています(iOS)');
        break;
      case PermissionStatus.limited:
        Logger().w('権限が制限されています(iOS)');
        break;
      case PermissionStatus.permanentlyDenied:
        Logger().w('権限が永久に拒否されます(Android)');
        break;
      case PermissionStatus.provisional:
        Logger().w('権限が許可されています(iOS)');
        break;
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
            // Text(result),
            ElevatedButton(
              onPressed: () {
                requestPermission();
              },
              child: const Text("Request authorization"),
            ),
          ],
        ),
      ),
    );
  }
}
