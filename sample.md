# Welcome to MarkdownRender

A beautiful macOS markdown renderer with **Mermaid** and **Graphviz** support.

## Features

- Native macOS window with WebKit rendering
- Automatic dark/light mode support
- Live file watching with `--watch` flag
- Syntax highlighting for code blocks

## Code Example

Here's some Swift code:

```swift
func greet(name: String) -> String {
    return "Hello, \(name)!"
}

let message = greet(name: "World")
print(message)
```

## Mermaid Diagrams

### Flowchart

```mermaid
flowchart TD
    A[Start] --> B{Is it working?}
    B -->|Yes| C[Great!]
    B -->|No| D[Debug]
    D --> B
    C --> E[End]
```

### Sequence Diagram

```mermaid
sequenceDiagram
    participant User
    participant CLI
    participant Window
    participant WebView

    User->>CLI: Run command
    CLI->>Window: Create window
    Window->>WebView: Load HTML
    WebView-->>User: Display rendered markdown
```

## Graphviz Diagrams

### Simple Graph

```dot
digraph G {
    rankdir=LR;
    node [shape=box, style=rounded];

    Markdown -> Parser -> HTML -> WebView -> Display;
}
```

### Component Diagram

```graphviz
digraph components {
    node [shape=component, style=filled, fillcolor=lightblue];

    subgraph cluster_app {
        label="Application";
        CLI [label="CLI\nEntry Point"];
        AppDelegate [label="App\nDelegate"];
        Window [label="NS\nWindow"];
    }

    subgraph cluster_render {
        label="Rendering";
        Parser [label="Markdown\nParser"];
        Generator [label="HTML\nGenerator"];
        WebView [label="WK\nWebView"];
    }

    CLI -> AppDelegate -> Window;
    Window -> WebView;
    Parser -> Generator -> WebView;
}
```

## Tables

| Feature | Status | Notes |
|---------|--------|-------|
| Markdown | ✅ | Full CommonMark support |
| Mermaid | ✅ | Flowcharts, sequences, etc. |
| Graphviz | ✅ | DOT language support |
| Dark Mode | ✅ | Follows system preference |

## Blockquotes

> "The best way to predict the future is to invent it."
> — Alan Kay

## Task Lists

- [x] Create CLI entry point
- [x] Set up NSWindow
- [x] Implement markdown parsing
- [x] Add Mermaid support
- [x] Add Graphviz support
- [ ] Add PDF export
- [ ] Add print support

---

*Built with Swift, AppKit, and WebKit*
