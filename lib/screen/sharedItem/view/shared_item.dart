import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SharedItem extends StatefulWidget {
  const SharedItem({super.key});

  @override
  State<SharedItem> createState() => _SharedItemState();
}

class _SharedItemState extends State<SharedItem> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}
