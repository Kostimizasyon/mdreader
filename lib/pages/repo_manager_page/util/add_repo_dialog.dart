import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class AddRepoDialog extends StatefulWidget {
  final int currentRepoCount;
  final int maxRepos;
  final Future<void> Function(String input) onAddRepository;

  const AddRepoDialog({
    super.key,
    required this.currentRepoCount,
    this.maxRepos = 3,
    required this.onAddRepository,
  });

  @override
  State<AddRepoDialog> createState() => _AddRepoDialogState();
}

class _AddRepoDialogState extends State<AddRepoDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  bool get _isQuotaReached => widget.currentRepoCount >= widget.maxRepos;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isQuotaReached) return;
    final input = _controller.text.trim();
    if (input.isEmpty) {
      setState(() => _errorMessage = 'Please enter an owner/repo or GitHub URL.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.onAddRepository(input);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final errorColor = isDark ? AppColors.darkErrorRed : AppColors.lightErrorRed;

    return AlertDialog(
      backgroundColor: theme.cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.colorScheme.outline),
      ),
      title: Row(
        children: [
          Icon(Icons.book_outlined, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Add GitHub Repository', style: TextStyle(fontSize: 16)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isQuotaReached)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: errorColor),
              ),
              child: Text(
                'You have reached the maximum limit of ${widget.maxRepos} saved repositories. Please remove an existing repository before adding a new one.',
                style: TextStyle(color: errorColor, fontSize: 13),
              ),
            )
          else ...[
            Text(
              'Enter a public repository in "owner/repo" format or paste its full GitHub URL.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              enabled: !_isLoading,
              autofocus: true,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                hintText: 'e.g. flutter/flutter or https://github.com/...',
                hintStyle: theme.textTheme.bodySmall,
                isDense: true,
                filled: true,
                fillColor: theme.scaffoldBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: errorColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: errorColor),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: errorColor, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: errorColor, fontSize: 12.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        if (!_isQuotaReached)
          ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text('Add Repository'),
          ),
      ],
    );
  }
}