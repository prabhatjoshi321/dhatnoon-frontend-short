import 'package:dhatnoon/providers/approved_requests.dart';
import 'package:dhatnoon/providers/request_select.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../res.dart';

class HomeBoxes extends StatelessWidget {
  HomeBoxes(
      {required this.index,
      required this.onPressed,
      required this.gradient,
      this.selectedCard = true,
      this.darkMode = true,
      this.textMargin = 10,
      required this.image});

  ///[text] card's text
  final int index;

  ///[selectedCard] card's text selected status
  final bool selectedCard;

  ///[selectedCard] card's text selected status
  final bool darkMode;

  ///[text] card's text margin
  final double textMargin;

  ///[onPressed] card's press callback
  final Function() onPressed;

  ///[gradient] card's background gradient
  final LinearGradient gradient;

  ///[image] icon's path
  final String image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 60,
            width: 100,
            margin: EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: darkMode ? Colors.white12 : Colors.black12,
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            child: Stack(
              children: [
                Center(
                  child: SizedBox(
                      child: Image.asset(
                    image,
                    width: 100,
                    height: 100,
                    fit: BoxFit.fitWidth,
                  )),
                ),
                Container(
                  height: 60,
                  width: 100,
                  decoration: BoxDecoration(
                      gradient: selectedCard
                          ? LinearGradient(
                              colors: index != 0
                                  ? [
                                      Colors.orange.withOpacity(0.3),
                                      Colors.orange.withOpacity(0.2),
                                      Colors.orange.withOpacity(0.1),
                                      Colors.orange.withOpacity(0.0),
                                    ]
                                  : [
                                      Colors.blue.withOpacity(0.3),
                                      Colors.blue.withOpacity(0.2),
                                      Colors.blue.withOpacity(0.1),
                                      Colors.blue.withOpacity(0.0),
                                    ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter)
                          : null,
                      borderRadius: BorderRadius.circular(15)),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          SizedBox(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: selectedCard
                  ? Image.asset(
                      Res.tourch,
                      color: darkMode ? null : Colors.blue[400],
                    )
                  : Image.asset(
                      Res.vector_off,
                      color: darkMode ? null : Colors.blue[400],
                    ),
            ),
            width: 100,
            height: 35,
          ),
        ],
      ),
    );
  }
}
