import 'package:flutter/material.dart';
import 'package:gymtrack/colors/colors.dart';

class WhichDay extends StatelessWidget {
  const WhichDay({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
                letterSpacing: -0.2,
                color: MyColors().textColor,
                fontWeight: FontWeight.w500,
                fontSize: 18),
          ),
          Container(
            height: 0.7,
            width: MediaQuery.of(context).size.width * 0.4,
            color: MyColors().secondary.withOpacity(0.6),
          )
        ],
      ),
    );
  }
}
