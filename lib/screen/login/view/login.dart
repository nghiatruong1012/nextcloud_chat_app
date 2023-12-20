import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nextcloud_chat_app/repositories/authentication_repository.dart';
import 'package:nextcloud_chat_app/screen/login/bloc/login_bloc.dart';
import 'package:nextcloud_chat_app/utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => LoginPage());
  }

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late String serverURL;
  late String webViewURL;
  late Map<String, String> headers;

  @override
  void initState() {
    super.initState();
    // serverURL = "<server>/index.php/login/flow";
    // webViewURL = "$serverURL?OCS-APIREQUEST=true";
    // headers = {
    //   "Accept-Language": "en-US",
    //   "User-Agent": "YourApp/1.0",
    // };
  }

  // final controller = WebViewController()
  //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
  //   ..setBackgroundColor(const Color(0x00000000))
  //   ..setNavigationDelegate(
  //     NavigationDelegate(
  //       onProgress: (int progress) {
  //         // Update loading bar.
  //         print(progress);
  //       },
  //       onPageStarted: (String url) {
  //         print("start" + url);
  //       },
  //       onPageFinished: (String url) {
  //         print("finish" + url);
  //       },
  //       onWebResourceError: (WebResourceError error) {
  //         print("error" + error.toString());
  //       },
  //       onNavigationRequest: (NavigationRequest request) {
  //         if (request.url.startsWith('nc')) {
  //           print(request);
  //           return NavigationDecision.navigate;
  //         } else {
  //           return NavigationDecision.prevent;
  //         }
  //       },
  //       onUrlChange: (change) {
  //         print("change" + change.url.toString());
  //       },
  //     ),
  //   )
  //   ..loadRequest(Uri.parse("http://192.168.1.86:8080/index.php/login/flow"),
  //       headers: {
  //         "OCS-APIREQUEST": "true",
  //         // "Accept-Language": "en-US",
  //         // "User-Agent":
  //         //     "Mozilla/5.0 (Linux; Android 10; Android SDK built for x86 Build/QSR1.210802.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/74.0.3729.185 Mobile Safari/537.36",
  //       });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
          create: (context) => LoginBloc(
              authenticationRepository:
                  RepositoryProvider.of<AuthenticationRepository>(context)),
          child: LoginWebView()),
    );
  }
}

class LoginWebView extends StatefulWidget {
  const LoginWebView({super.key});

  @override
  State<LoginWebView> createState() => _LoginWebViewState();
}

class _LoginWebViewState extends State<LoginWebView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return InAppWebView(
          initialUrlRequest: URLRequest(
              url: Uri.parse("$localhost/index.php/login/flow"),
              headers: {
                "OCS-APIREQUEST": "true",
                // "Accept-Language": "en-US",
                // "User-Agent":
                //     "Mozilla/5.0 (Linux; Android 10; Android SDK built for x86 Build/QSR1.210802.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/74.0.3729.185 Mobile Safari/537.36",
              }),
          onUpdateVisitedHistory: (controller, url, androidIsReload) {
            if (url.toString().startsWith("nc")) {
              Map<String, String> result = parseInputString(url.toString());
              if (result.containsKey('server') &&
                  result.containsKey('user') &&
                  result.containsKey('password')) {
                String server = result['server']!;
                String username = result['user']!;
                String password = result['password']!;
                print("Server: $server");
                print("Username: $username");
                print("Password: $password");
                context
                    .read<LoginBloc>()
                    .add(SubmitLogin(server, username, password));
                return;
              } else {
                print("Invalid input string format");
              }
            }
          },
        );
      },
    );
  }
}
