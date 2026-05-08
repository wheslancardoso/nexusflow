import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Center(
        child: Icon(
          Icons.handyman,
          size: 100,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
