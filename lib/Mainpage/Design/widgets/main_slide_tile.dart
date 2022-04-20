import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dhatnoon/constants.dart';
import '../utils/theme.dart';

import 'item_view.dart';

/// the MainSlideTile slider item
class MainSlideTile extends StatelessWidget {
  MainSlideTile(
      {required this.list, required this.pageindex, required this.index});

  final int index;
  final int pageindex;
  final List<dynamic> list;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: pageindex == 0
            ? ItemView(
                pageindex: pageindex,
                index: index,
                list: list,
                allowdenyfunc: () {},
                onView: () => {},
              )
            : ItemView(
                pageindex: pageindex,
                index: index,
                list: list,
                allowdenyfunc: () {},
                onView: () => {},
              ));
  }
}
