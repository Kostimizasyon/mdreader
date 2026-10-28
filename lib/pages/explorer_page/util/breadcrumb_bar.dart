import 'package:flutter/material.dart';

class BreadcrumbBar extends StatelessWidget {
  final String repoName;
  final String currentPath;
  final ValueChanged<String> onPathSelected;

  const BreadcrumbBar({
    super.key,
    required this.repoName,
    required this.currentPath,
    required this.onPathSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final segments = currentPath.split('/').where((s) => s.isNotEmpty).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outline, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () => onPathSelected(''),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: [
                    Icon(
                      Icons.home_outlined,
                      size: 16,
                      color: segments.isEmpty
                          ? theme.textTheme.bodyLarge?.color
                          : theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      repoName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                        segments.isEmpty ? FontWeight.w700 : FontWeight.w500,
                        color: segments.isEmpty
                            ? theme.textTheme.bodyLarge?.color
                            : theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            for (int i = 0; i < segments.length; i++) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '/',
                  style: TextStyle(
                    color: theme.textTheme.bodySmall?.color,
                    fontSize: 13,
                  ),
                ),
              ),
              Builder(
                builder: (context) {
                  final isLast = i == segments.length - 1;
                  final targetPath = segments.sublist(0, i + 1).join('/');
                  return InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: isLast ? null : () => onPathSelected(targetPath),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Text(
                        segments[i],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isLast ? FontWeight.w700 : FontWeight.w500,
                          color: isLast
                              ? theme.textTheme.bodyLarge?.color
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}