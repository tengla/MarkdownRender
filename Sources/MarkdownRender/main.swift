import AppKit
import ArgumentParser

struct MarkdownRender: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "MarkdownRender",
        abstract: "A beautiful macOS markdown renderer with Mermaid and Graphviz support"
    )

    @Argument(help: "Path to the markdown file to render")
    var file: String?

    @Flag(name: .shortAndLong, help: "Watch file for changes and reload automatically")
    var watch: Bool = false

    @Option(name: .shortAndLong, help: "Theme: 'auto', 'light', or 'dark'")
    var theme: String = "auto"

    mutating func run() throws {
        var initialFileURL: URL? = nil

        if let file = file {
            let fileURL = URL(fileURLWithPath: file).standardizedFileURL

            // Verify file exists
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                throw ValidationError("File not found: \(fileURL.path)")
            }

            // Verify it's a markdown file
            let ext = fileURL.pathExtension.lowercased()
            guard ["md", "markdown", "mdown", "mkd"].contains(ext) else {
                throw ValidationError("File does not appear to be a markdown file: \(fileURL.lastPathComponent)")
            }

            initialFileURL = fileURL
        }

        // Launch the app
        let app = NSApplication.shared
        let delegate = AppDelegate(fileURL: initialFileURL, watchEnabled: watch, theme: theme)
        app.delegate = delegate
        app.setActivationPolicy(.regular)
        app.run()
    }
}

MarkdownRender.main()
