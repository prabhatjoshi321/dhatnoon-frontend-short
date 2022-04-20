import 'Mainpage/NewMain.dart';
import 'package:flutter/material.dart';
import './Mainpage/Design/utils/DarkThemeProvider.dart';
import './Mainpage/Design/utils/theme.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class MainArrange extends StatefulWidget {
  @override
  _MainArrangeState createState() => _MainArrangeState();
}

class _MainArrangeState extends State<MainArrange> {
  DarkThemeProvider themeChangeProvider = new DarkThemeProvider();

  @override
  void initState() {
    super.initState();
    getCurrentAppTheme();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        return themeChangeProvider;
      },
      child: Consumer<DarkThemeProvider>(
        builder: (BuildContext context, value, Widget? child) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            theme: Styles.themeData(themeChangeProvider.darkTheme, context),
            home: NewMain(),
          );
        },
      ),
    );
  }
}
