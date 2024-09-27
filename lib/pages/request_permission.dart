import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';
import 'package:go_router/go_router.dart';
// import '../main.dart';

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
        context.push('/');
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
                    context.pop('/');
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
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  Icons.perm_media,
                  size: 100,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                const Text(
                  'メディアライブラリへのアクセス許可が必要です',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('権限を許可する'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: () {
                    requestPermission();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
