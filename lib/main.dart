import 'package:flutter/material.dart';
import 'package:location_permissions/location_permissions.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String message = 'unknown';
  PermissionStatus permission = PermissionStatus.unknown;
  bool openedSettings = false;
  bool shownBottomSheet = false;

  checkPermission() async {
    permission = await LocationPermissions().checkPermissionStatus();
    print(
        '0. permission checked at (${DateTime.now().minute}:${DateTime.now().second}.${DateTime.now().millisecond}): $permission');

    //MARK[blue]: PermissionStatus.unknown
    if (permission == PermissionStatus.unknown) {
      if (shownBottomSheet) {
        Navigator.pop(context);
      }
      try {
        print(
            '1. trying to request permission at (${DateTime.now().minute}:${DateTime.now().second}.${DateTime.now().millisecond})');
        permission = await LocationPermissions().requestPermissions();
        print(
            '1. permission requested at (${DateTime.now().minute}:${DateTime.now().second}.${DateTime.now().millisecond}): $permission');
      } catch (e) {
        print('LocationPermissions().requestPermissions() error: $e');
      }
    }

    //MARK[red]: PermissionStatus.denied
    if (permission == PermissionStatus.denied) {
      print('1. permission denied');
      if (!shownBottomSheet) {
        shownBottomSheet = true;
        showModalBottomSheet(
            isDismissible: false,
            enableDrag: false,
            context: context,
            builder: (BuildContext context) => Container(
                  height: 500,
                  child: FlatButton(
                    onPressed: () async {
                      openedSettings =
                          await LocationPermissions().openAppSettings();
                      print('isOpened happened');
                      checkPermission();
                    },
                    child: Text('2. Enable Location'),
                  ),
                ));
      } else {
        await Future.delayed(Duration(milliseconds: 100));
        checkPermission();
      }
    }

    //MARK[green]: PermissionStatus.granted
    if (permission == PermissionStatus.granted) {
      if (shownBottomSheet) {
        Navigator.pop(context);
      }
      setState(() {
        message = 'Granted. Yay!!!';
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    checkPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(message),
      ),
    );
  }
}
