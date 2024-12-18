import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';
import 'package:go_router/go_router.dart';
import '../components/smooth_button.dart';

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
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Colors.grey[900]!],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(
                      Icons.perm_media,
                      size: 100,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'メディアライブラリへの\nアクセス許可が必要です',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Discでは、あなたのApple Musicの再生履歴を\n使用してあなたのフォロワーと共有します。',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 40),
                    SmoothButton(
                      text: '権限を許可する',
                      onPressed: requestPermission,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
