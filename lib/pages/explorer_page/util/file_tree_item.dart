import 'package:flutter/material.dart';
import '../../../data_models/repo_node.dart';
import '../../../theme/app_colors.dart';

class FileTreeItem extends StatelessWidget {
  final RepoNode node;
  final VoidCallback onTap;

  const FileTreeItem({
    super.key,
    required this.node,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final folderColor =
    isDark ? AppColors.darkFolderIcon : AppColors.lightFolderIcon;
    final fileColor =
    isDark ? AppColors.darkMarkdownIcon : AppColors.lightMarkdownIcon;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              node.isDirectory ? Icons.folder : Icons.description_outlined,
              size: 20,
              color: node.isDirectory ? folderColor : fileColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                node.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight:
                  node.isDirectory ? FontWeight.w600 : FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: Text(
                node.formattedSize,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: theme.textTheme.bodySmall?.color,
            ),
          ],
        ),
      ),
    );
  }
}