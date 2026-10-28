import 'package:flutter/material.dart';
import 'pages/util/navigation_shell.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GithubMarkdownExplorerApp());
}

class GithubMarkdownExplorerApp extends StatefulWidget {
  const GithubMarkdownExplorerApp({super.key});

  @override
  State<GithubMarkdownExplorerApp> createState() =>
      _GithubMarkdownExplorerAppState();
}

class _GithubMarkdownExplorerAppState extends State<GithubMarkdownExplorerApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode =
      _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitHub Markdown Explorer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: NavigationShell(
        isDarkMode: _themeMode == ThemeMode.dark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}