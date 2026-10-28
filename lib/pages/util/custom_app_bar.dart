import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      leading: leading,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      actions: [
        ...?actions,
        IconButton(
          tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          icon: Icon(
            isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            size: 20,
          ),
          onPressed: onToggleTheme,
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}