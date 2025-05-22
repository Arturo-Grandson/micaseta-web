import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micaseta_web/providers/theme_provider.dart';

class ThemeToggleWidget extends ConsumerWidget {
  final bool showIcon;
  final bool showText;
  final double iconSize;
  final Color? lightModeColor;
  final Color? darkModeColor;

  const ThemeToggleWidget({
    Key? key,
    this.showIcon = true,
    this.showText = true,
    this.iconSize = 24.0,
    this.lightModeColor,
    this.darkModeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final isDarkMode = themeNotifier.isDarkMode(context);

    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () => themeNotifier.toggleTheme(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon)
              Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: isDarkMode
                    ? darkModeColor ?? Colors.amber
                    : lightModeColor ?? Colors.amber,
                size: iconSize,
              ),
            if (showIcon && showText) const SizedBox(width: 8),
            if (showText)
              Text(
                isDarkMode ? 'Modo oscuro' : 'Modo claro',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ThemeToggleSwitch extends ConsumerWidget {
  final double width;
  final double height;
  final Duration animationDuration;

  const ThemeToggleSwitch({
    Key? key,
    this.width = 70,
    this.height = 35,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final isDarkMode = themeNotifier.isDarkMode(context);

    return GestureDetector(
      onTap: () => themeNotifier.toggleTheme(),
      child: AnimatedContainer(
        duration: animationDuration,
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height / 2),
          color: isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Iconos de sol y luna
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: height * 0.2),
                child: Icon(
                  Icons.wb_sunny,
                  color: isDarkMode ? Colors.grey : Colors.amber,
                  size: height * 0.6,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: height * 0.2),
                child: Icon(
                  Icons.nightlight_round,
                  color: isDarkMode ? Colors.amber : Colors.grey,
                  size: height * 0.6,
                ),
              ),
            ),
            // Círculo deslizante
            AnimatedAlign(
              duration: animationDuration,
              alignment:
                  isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.all(height * 0.1),
                child: Container(
                  width: height - height * 0.2,
                  height: height - height * 0.2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
