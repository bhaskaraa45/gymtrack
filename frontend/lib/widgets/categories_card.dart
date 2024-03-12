import 'package:flutter/material.dart';
import 'package:gymtrack/colors/colors.dart';

class CategoriesCard extends StatelessWidget {
  const CategoriesCard(
      {super.key,
      required this.date,
      required this.tag,
      required this.percentage,
      required this.color});
  final String date;
  final String tag;
  final double percentage;
  final Color color;

  Widget processLine() {
    return Container(
      width: double.infinity,
      height: 5.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3.0),
        gradient: LinearGradient(
          colors: [color, MyColors().sec],
          stops: [percentage / 100, percentage / 100,],
          begin: Alignment.topLeft,
          end: Alignment.topRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            offset: const Offset(0, 2),
            blurRadius: 4.0,
          ),
        ]
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 250,
      decoration: BoxDecoration(
          color: MyColors().primary2, borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              date,
              style: TextStyle(
                  color: MyColors().secondary.withOpacity(0.8), fontSize: 15.5),
            ),
            Text(
              tag,
              style: TextStyle(
                color: MyColors().textColor,
                fontSize: 20,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            processLine()
          ],
        ),
      ),
    );
  }
}
