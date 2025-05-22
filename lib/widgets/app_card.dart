import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final IconData? icon;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final Color? color;
  final BorderRadius? borderRadius;

  const AppCard({
    Key? key,
    required this.child,
    this.title,
    this.icon,
    this.onTap,
    this.padding,
    this.elevation,
    this.color,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation ?? AppTheme.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius:
            borderRadius ?? BorderRadius.circular(AppTheme.cardRadius),
      ),
      color: color ?? Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            borderRadius ?? BorderRadius.circular(AppTheme.cardRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null || icon != null)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: padding?.horizontal ?? AppTheme.spacingM,
                  vertical: padding?.vertical ?? AppTheme.spacingM,
                ),
                child: Row(
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                    ],
                    if (title != null)
                      Text(
                        title!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                    const Spacer(),
                    if (onTap != null)
                      const Icon(
                        Icons.chevron_right,
                        color: AppTheme.textSecondaryColor,
                      ),
                  ],
                ),
              ),
            Padding(
              padding: padding ?? const EdgeInsets.all(AppTheme.spacingM),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

// Widget para mostrar datos de estadísticas en forma de tarjeta
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing),
            decoration: BoxDecoration(
              color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppTheme.primaryColor,
              size: 30,
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget para mostrar listados con imágenes y acciones
class ListItemCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Widget? leading;
  final List<Widget>? actions;
  final VoidCallback? onTap;
  final bool showBorder;

  const ListItemCard({
    Key? key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.leading,
    this.actions,
    this.onTap,
    this.showBorder = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: showBorder
            ? Border(
                bottom: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              )
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingS,
        ),
        leading: leading ??
            (leadingIcon != null
                ? CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: Icon(
                      leadingIcon,
                      color: AppTheme.primaryColor,
                    ),
                  )
                : null),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: const TextStyle(
                  color: AppTheme.textSecondaryColor,
                ),
              )
            : null,
        trailing: actions != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: actions!,
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
