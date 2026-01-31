# CLAUDE.md

This file provides guidance for Claude Code when working on this project.

## Project Overview

MarkdownRender is a native macOS CLI tool that opens a window to render Markdown files with Mermaid and Graphviz support. It uses Swift Package Manager (not an Xcode project).

## Build Commands

```bash
# Debug build
swift build

# Release build
swift build -c release

# Run directly
swift run MarkdownRender path/to/file.md

# Run with options
swift run MarkdownRender --watch --theme dark path/to/file.md
```

The release binary is at `.build/release/MarkdownRender`.

## Architecture

```
Sources/MarkdownRender/
├── main.swift                  # CLI entry, argument parsing with ArgumentParser
├── App/
│   └── AppDelegate.swift       # NSApplication delegate, window setup, file watching
└── Rendering/
    ├── MarkdownParser.swift    # Converts Markdown to HTML using swift-markdown
    └── HTMLGenerator.swift     # HTML template, CSS styles, JS initialization
```

### Key Design Decisions

1. **No Xcode project** - Uses SPM only. Open `Package.swift` in Xcode if IDE features are needed.

2. **WKWebView for rendering** - HTML/CSS/JS gives flexibility for diagrams and styling. The WebView loads generated HTML with embedded CSS and CDN scripts.

3. **CDN dependencies** - Mermaid.js, Viz.js, and Highlight.js are loaded from CDN. This keeps the binary small but requires internet.

4. **File watching** - Uses `DispatchSource.makeFileSystemObjectSource` to monitor file changes when `--watch` is enabled.

5. **Theme support** - CSS uses `prefers-color-scheme` media queries. The `--theme` flag sets `NSWindow.appearance` to override system preference.

## Code Patterns

### Adding a new Markdown element

1. Add a `visit*` method in `MarkdownParser.swift` implementing the `MarkupVisitor` protocol
2. Return the appropriate HTML string

### Modifying styles

Edit the CSS in `HTMLGenerator.generateCSS()`. Uses CSS variables for theming:
- `--bg-color`, `--text-color`, `--code-bg`, etc.
- Dark mode overrides in `@media (prefers-color-scheme: dark)`

### Adding a new diagram type

1. In `MarkdownParser.swift`, add detection in `visitCodeBlock()` for the new language
2. Return a div with a class for the diagram type
3. In `HTMLGenerator.swift`, add the JS library and initialization code

## Testing

Run with the included sample files:

```bash
swift run MarkdownRender sample.md           # Basic features
swift run MarkdownRender graphviz-test.md    # Complex Graphviz examples
```

## Common Tasks

### Update minimum macOS version

Edit `Package.swift`:
```swift
platforms: [
    .macOS(.v13)  // Change this
]
```

### Add a new dependency

Edit `Package.swift` and add to both `dependencies` and target `dependencies`.

### Bundle JS libraries locally (offline mode)

1. Download the JS files to `Sources/MarkdownRender/Resources/`
2. Update `Package.swift` to include the resources
3. Modify `HTMLGenerator.swift` to use `Bundle.module.url(forResource:...)` instead of CDN URLs
