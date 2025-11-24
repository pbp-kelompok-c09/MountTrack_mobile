import 'package:flutter/material.dart';

class AppNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;
  final Color? backgroundColor;
  final double? elevation;
  final IconThemeData? iconTheme;
  final TextStyle? titleTextStyle;
  final bool? centerTitle;
  final Widget? leading;

  const AppNavBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = true,
    this.backgroundColor,
    this.elevation,
    this.iconTheme,
    this.titleTextStyle,
    this.centerTitle,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: showBack,
      leading: leading,
      title: Text(title, style: titleTextStyle),
      actions: actions,
      backgroundColor: backgroundColor,
      elevation: elevation,
      iconTheme: iconTheme,
      centerTitle: centerTitle,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
