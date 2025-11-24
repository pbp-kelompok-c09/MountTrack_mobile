import 'package:flutter/material.dart';
import 'app_navbar.dart';

class BaseScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showBack;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final Color? appBarBackgroundColor;
  final double? appBarElevation;
  final IconThemeData? appBarIconTheme;
  final TextStyle? titleTextStyle;
  final bool? centerTitle;
  final Widget? leading;

  const BaseScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showBack = true,
    this.actions,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.appBarBackgroundColor,
    this.appBarElevation,
    this.appBarIconTheme,
    this.titleTextStyle,
    this.centerTitle,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppNavBar(
        title: title,
        showBack: showBack,
        actions: actions,
        backgroundColor: appBarBackgroundColor,
        elevation: appBarElevation,
        iconTheme: appBarIconTheme,
        titleTextStyle: titleTextStyle,
        centerTitle: centerTitle,
        leading: leading,
      ),
      body: body,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
