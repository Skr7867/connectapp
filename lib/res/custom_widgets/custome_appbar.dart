import 'package:flutter/material.dart';
import '../fonts/app_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final double elevation;
  final TextStyle? titleStyle;

  const CustomAppBar({
    super.key,
    this.title = '',
    this.automaticallyImplyLeading = false,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.elevation = 4.0,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: titleStyle ??
            TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontFamily: AppFonts.opensansRegular,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
      ),
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions,
      centerTitle: centerTitle,
      elevation: elevation, // ➤ This now shows up
      iconTheme: IconThemeData(
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      backgroundColor: Colors.white, // ✅ Set a solid color
      shadowColor:
          Colors.black.withOpacity(0.25), // Optional: tweak shadow appearance

      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          // gradient: AppColors.exploreGradient,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
