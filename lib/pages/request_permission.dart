import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';
import '../main.dart';

class PermissionPage extends StatefulWidget {
  const PermissionPage({super.key});

  @override
  PermissionPageState createState() => PermissionPageState();
}

class PermissionPageState extends State<PermissionPage> {
  Future<void> requestPermission() async {
    final PermissionStatus status = await Permission.mediaLibrary.request();
    Logger().i('status: $status');
    if (!mounted) return;
    switch (status) {
      case PermissionStatus.granted:
        Logger().w('権限が許可されました');
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const MyApp()));
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
      default:
        Logger().w('例外が発生しました');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('権限の許可'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            requestPermission();
          },
          child: const Text("Request authorization"),
        ),
      ),
    );
  }
}
