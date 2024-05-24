import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ConnectPage extends StatefulWidget {
  const ConnectPage({super.key});
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const ConnectPage());
  }

  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF0082c9),
        child: Center(
          child: Column(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: SvgPicture.asset('assets/app.svg'),
              ),
              TextField(
                decoration: InputDecoration(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
