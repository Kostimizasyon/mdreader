import 'package:flutter/material.dart';

class TocHeading {
  final int level;
  final String text;

  const TocHeading({
    required this.level,
    required this.text,
  });
}

class ReaderTocSheet extends StatelessWidget {
  final List<TocHeading> headings;
  final ValueChanged<TocHeading> onSelectHeading;

  const ReaderTocSheet({
    super.key,
    required this.headings,
    required this.onSelectHeading,
  });

  static List<TocHeading> parseHeadings(String markdown) {
    final List<TocHeading> results = [];
    final lines = markdown.split('\n');
    bool inCodeFence = false;

    final headingRegex = RegExp(r'^(#{1,3})\s+(.+)$');

    for (final rawLine in lines) {
      final line = rawLine.trimRight();
      if (line.startsWith('```')) {
        inCodeFence = !inCodeFence;
        continue;
      }
      if (inCodeFence) continue;

      final match = headingRegex.firstMatch(line);
      if (match != null) {
        final level = match.group(1)!.length;
        final text = match.group(2)!.replaceAll(RegExp(r'[#*`_]'), '').trim();
        if (text.isNotEmpty) {
          results.add(TocHeading(level: level, text: text));
        }
      }
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.toc, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Table of Contents', style: theme.textTheme.titleMedium),
                const Spacer(),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          if (headings.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No headings (#, ##, ###) found in this document.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: headings.length,
                itemBuilder: (context, index) {
                  final heading = headings[index];
                  final leftIndent = 16.0 + (heading.level - 1) * 16.0;
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      onSelectHeading(heading);
                    },
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(leftIndent, 10, 16, 10),
                      child: Text(
                        heading.text,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: heading.level == 1
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: heading.level == 1
                              ? theme.textTheme.bodyLarge?.color
                              : theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}