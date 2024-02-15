// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:photomatrix/theme/app_theme.dart';

class InviteFriend extends StatefulWidget {
  const InviteFriend({super.key});

  @override
  _InviteFriendState createState() => _InviteFriendState();
}

class _InviteFriendState extends State<InviteFriend> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: isLightMode ? AppTheme.white : AppTheme.nearlyBlack,
        body: const Column(
          children: <Widget>[],
        ),
      ),
    );
  }
}
