import 'package:flutter/material.dart';

import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'music_kit_test.dart';

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
    if (!mounted) return; // ウィジェットがマウントされているか確認

    switch (status) {
      case PermissionStatus.granted:
        Logger().w('権限が許可されました');
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const MusicKitTest()));
        break;
      case PermissionStatus.permanentlyDenied:
        Logger().w('権限が拒否されました');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('権限が必要です'),
              content: const Text('設定から権限を許可してください'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        break;
      // case PermissionStatus.denied:
      //   Logger().w('権限が拒否されました');
      //   break;
      // case PermissionStatus.restricted:
      //   Logger().w('権限が制限されています');
      //   break;
      // case PermissionStatus.limited:
      //   Logger().w('権限が制限されています');
      //   break;
      // case PermissionStatus.provisional:
      //   Logger().w('権限が許可されました');
      //   break;
      default:
        Logger().w('例外が発生しました');
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
