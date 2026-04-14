// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:steam_achievement_tracker/services/utils/colors.dart';
import 'package:steam_achievement_tracker/services/widgets/my_app_bar.dart';
import 'package:steam_login/steam_login.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SteamLogin extends StatefulWidget {
  const SteamLogin({super.key});

  @override
  State<SteamLogin> createState() => _SteamLoginState();
}

class _SteamLoginState extends State<SteamLogin> {
  static const String _callbackHost = 'steamer';

  late final WebViewController _webViewController;
  bool _isLoading = true;
  bool _isCompletingLogin = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _webViewController =
        WebViewController()
          ..setBackgroundColor(KColors.backgroundColor)
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (_) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
              },
              onPageFinished: (url) {
                if (!mounted || _isCallbackUrl(url)) {
                  return;
                }
                setState(() {
                  _isLoading = false;
                });
              },
              onProgress: (progress) {
                if (!mounted || _isCompletingLogin) {
                  return;
                }
                if (progress >= 100) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              onNavigationRequest: (request) {
                if (_isCallbackUrl(request.url)) {
                  unawaited(_completeSteamLogin(request.url));
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
              onUrlChange: (change) {
                final url = change.url;
                if (url == null || !_isCallbackUrl(url)) {
                  return;
                }
                unawaited(_completeSteamLogin(url));
              },
              onWebResourceError: (error) {
                if (!mounted || _isCallbackUrl(error.url ?? '')) {
                  return;
                }

                setState(() {
                  _isLoading = false;
                  _errorMessage =
                      'Steam sign-in could not be loaded. Please try again.';
                });
              },
            ),
          )
          ..loadRequest(_buildOpenId().authUrl());
  }

  OpenId _buildOpenId() => OpenId.raw(
    'https://$_callbackHost',
    'https://$_callbackHost/',
    const {},
  );

  bool _isCallbackUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri?.host == _callbackHost;
  }

  Future<void> _completeSteamLogin(String url) async {
    if (_isCompletingLogin) {
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null || uri.host != _callbackHost) {
      return;
    }

    _isCompletingLogin = true;

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final openId = OpenId.fromUri(uri);

      if (openId.mode != 'id_res') {
        if (mounted) {
          Navigator.of(context).pop('');
        }
        return;
      }

      final steamId = await openId.validate();
      if (mounted) {
        Navigator.of(context).pop(steamId);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage =
            'Steam sign-in failed before the login could finish. Please try again.';
      });
    } finally {
      _isCompletingLogin = false;
    }
  }

  Future<void> _retrySteamLogin() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await _webViewController.loadRequest(_buildOpenId().authUrl());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.backgroundColor,
      appBar: myAppBar(title: 'STEAMER'),
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (_isLoading)
            Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(
                  color: KColors.backgroundColor.withValues(alpha: 0.94),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: KColors.activeTextColor,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Opening Steam sign-in...',
                          style: TextStyle(
                            color: KColors.activeTextColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (_errorMessage != null)
            Positioned.fill(
              child: ColoredBox(
                color: KColors.backgroundColor.withValues(alpha: 0.96),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: KColors.lightBackgroundColor,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.public_off_outlined,
                            color: KColors.activeTextColor,
                            size: 32,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Steam sign-in is unavailable',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: KColors.activeTextColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: KColors.inactiveTextColor,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _retrySteamLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: KColors.buttonColor,
                                foregroundColor: KColors.activeTextColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text('Try Again'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
