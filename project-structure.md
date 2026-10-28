# Project Structure & Architecture Log

## 1. Project Status Overview
- **Project**: GitHub Markdown File Explorer Mobile App
- **Status**: Production-Ready / All Modules Implemented (Chunks 1–6)
- **Architecture**: Modular, service-oriented architecture with persistent local caching and secure storage

---

## 2. Directory Tree

```text
.
├── project-structure.md                  # Living architecture and structure log
├── pubspec.yaml                          # Package dependencies and asset configuration
├── test/
│   └── widget_test.dart                  # Navigation shell & theme toggle smoke tests
└── lib/
    ├── main.dart                         # App entry point, MaterialApp configuration, theme state
    ├── data_models/
    │   ├── github_repo.dart              # Model for saved repositories (owner, name, branch, active status)
    │   ├── markdown_document.dart        # Model for markdown metadata, raw content, and local cache state
    │   └── repo_node.dart                # Recursive node tree representation for folders and markdown files
    ├── pages/
    │   ├── explorer_page/
    │   │   ├── explorer_page.dart         # Main file browser view with folder drill-down and refresh
    │   │   └── util/
    │   │       ├── breadcrumb_bar.dart    # Interactive directory path navigation bar
    │   │       ├── file_tree_item.dart    # Directory/file list item with status indicators and size tags
    │   │       └── repo_header_card.dart  # Active repository card with branch chip and quick-switcher
    │   ├── reader_page/
    │   │   ├── reader_page.dart           # Full-screen GitHub-styled Markdown reader with syntax highlighting
    │   │   └── util/
    │   │       ├── markdown_toolbar.dart  # Reader controls (zoom, raw view toggle, copy link, sync)
    │   │       └── reader_toc_sheet.dart  # Table of Contents bottom sheet parsed from headings
    │   ├── repo_manager_page/
    │   │   ├── repo_manager_page.dart     # Repository list and quota management view
    │   │   └── util/
    │   │       ├── add_repo_dialog.dart   # Repository input dialog with quota validation and URL parsing
    │   │       └── repo_list_card.dart    # Repository list card with sync and delete actions
    │   └── util/
    │       ├── custom_app_bar.dart        # GitHub-styled top application bar with light/dark toggle
    │       └── navigation_shell.dart      # Persistent navigation shell coordinating screens and state
    ├── services/
    │   ├── cache_service.dart            # Local device storage manager for offline tree and document caching
    │   ├── github_service.dart           # GitHub REST API client for trees, branches, and raw content
    │   ├── secure_storage_service.dart   # Encrypted persistent storage for saved repositories (max 3 quota)
    │   └── tree_builder_service.dart     # Transforms flat Git tree payloads into hierarchical node structures
    └── theme/
        ├── app_colors.dart               # GitHub design system color tokens (Dark and Light palettes)
        └── app_theme.dart                # Material 3 ThemeData definitions with GitHub visual styling
