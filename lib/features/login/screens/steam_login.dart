// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:steam_achievement_tracker/services/widgets/my_app_bar.dart';
import 'package:steam_login/steam_login.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SteamLogin extends StatefulWidget {
  const SteamLogin({super.key});

  @override
  State<SteamLogin> createState() => _SteamLoginState();
}

class _SteamLoginState extends State<SteamLogin> {
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    final openId = OpenId.raw('https://steamer', 'https://steamer/', {});
    _webViewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onNavigationRequest: (request) {
                final openId = OpenId.fromUri(Uri.parse(request.url));
                if (openId.mode == 'id_res') {
                  Navigator.of(context).pop(openId.validate());
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(openId.authUrl());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(title: 'STEAMER'),
      body: WebViewWidget(controller: _webViewController),
    );
  }
}
