import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersion extends StatefulWidget {
  const AppVersion({super.key});

  @override
  State<AppVersion> createState() => _AppVersionWidgetState();
}

class _AppVersionWidgetState extends State<AppVersion> {
  String _appVersion = "0.0.0";

  @override
  void initState() {
    super.initState();
    getAppVersion();
  }

  void getAppVersion() async {
    var tmp = await PackageInfo.fromPlatform();
    setState(() => _appVersion = tmp.version);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      alignment: Alignment.center,
      child: Text("Verze $_appVersion", textAlign: TextAlign.center),
    );
  }
}
