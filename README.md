# GitHub Markdown Explorer (mdreader)

An offline-capable, GitHub-styled Markdown documentation explorer and reader built with Flutter.

Browse, explore, and read Markdown documentation repositories directly from GitHub on your mobile device with native-feeling GitHub dark and light themes, syntax highlighting, and offline support.

---

## Features

- **Repository Management**: Save up to **3 repositories** concurrently using secure encrypted storage (`flutter_secure_storage`). Quickly switch between active repositories.
- **Hierarchical File Explorer**: Traverses GitHub repositories using the Git Trees API, filtering out non-Markdown files and reconstructing the exact directory structure.
- **Interactive Breadcrumb Navigation**: Jump back to any parent folder instantly with interactive breadcrumbs or the classic `..` directory navigation.
- **Rich Markdown Reader**: GitHub-Flavored Markdown (GFM) rendering with:
  - Syntax-highlighted code blocks (`flutter_highlight`)
  - Formatted tables, blockquotes, and headings
  - Image rendering from raw GitHub repository sources
  - Raw Markdown code view toggle
  - Table of Contents bottom sheet parsed dynamically from headings (`#`, `##`, `###`)
  - Adjustable text scaling (70% - 160%)
- **Offline Caching**: Markdown files and tree manifests are stored locally in the device's sandbox for fast, offline-first reading.
- **On-Demand Synchronization**: Pull-to-refresh or tap the refresh action to re-fetch the latest repository tree and document revisions.
- **GitHub Design Language**: Dark (`#0D1117`) and Light (`#FFFFFF`) themes adhering strictly to GitHub's UI palette and rounded-border aesthetics.

---

## Tech Stack & Dependencies

| Package | Purpose |
|---|---|
| [`http`](https://pub.dev/packages/http) | GitHub REST API and raw file fetching |
| [`flutter_secure_storage`](https://pub.dev/packages/flutter_secure_storage) | Encrypted storage for saved repository records |
| [`path_provider`](https://pub.dev/packages/path_provider) | Sandbox access for caching trees and `.md` files |
| [`flutter_markdown`](https://pub.dev/packages/flutter_markdown) | Markdown parser and renderer |
| [`flutter_highlight`](https://pub.dev/packages/flutter_highlight) | Code syntax highlighting |
| [`markdown`](https://pub.dev/packages/markdown) | GitHub Flavored Markdown (GFM) extensions |

---

## Project Structure

```text
lib/
├── data_models/          # GithubRepo, MarkdownDocument, RepoNode
├── pages/
│   ├── explorer_page/    # Hierarchical file browser & breadcrumbs
│   ├── reader_page/      # Markdown viewer, toolbar & TOC sheet
│   ├── repo_manager_page/# Repository switcher & quota manager
│   └── util/             # CustomAppBar, NavigationShell
├── services/             # GitHub API, Cache, Secure Storage, Tree Builder
├── theme/                # GitHub Dark & Light color tokens and ThemeData
└── main.dart             # Application entry point & theme state
