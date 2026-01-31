import AppKit
import WebKit

class AppDelegate: NSObject, NSApplicationDelegate {
    let fileURL: URL
    let watchEnabled: Bool
    let theme: String

    var window: NSWindow!
    var webView: WKWebView!
    var fileWatcher: DispatchSourceFileSystemObject?

    init(fileURL: URL, watchEnabled: Bool, theme: String) {
        self.fileURL = fileURL
        self.watchEnabled = watchEnabled
        self.theme = theme
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupWindow()
        setupWebView()
        setupMenu()
        loadMarkdown()

        if watchEnabled {
            setupFileWatcher()
        }

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    private func setupWindow() {
        let screenSize = NSScreen.main?.frame.size ?? CGSize(width: 1200, height: 800)
        let windowWidth: CGFloat = min(900, screenSize.width * 0.7)
        let windowHeight: CGFloat = min(700, screenSize.height * 0.8)

        let windowRect = NSRect(
            x: (screenSize.width - windowWidth) / 2,
            y: (screenSize.height - windowHeight) / 2,
            width: windowWidth,
            height: windowHeight
        )

        window = NSWindow(
            contentRect: windowRect,
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        window.title = fileURL.lastPathComponent
        window.minSize = NSSize(width: 400, height: 300)
        window.isReleasedWhenClosed = false
        window.titlebarAppearsTransparent = false

        // Set window appearance based on theme
        switch theme {
        case "light":
            window.appearance = NSAppearance(named: .aqua)
        case "dark":
            window.appearance = NSAppearance(named: .darkAqua)
        default:
            // Auto - follow system
            window.appearance = nil
        }
    }

    private func setupWebView() {
        let config = WKWebViewConfiguration()
        config.preferences.setValue(true, forKey: "developerExtrasEnabled")

        webView = WKWebView(frame: window.contentView!.bounds, configuration: config)
        webView.autoresizingMask = [.width, .height]

        // Transparent background to match window
        webView.setValue(false, forKey: "drawsBackground")

        window.contentView?.addSubview(webView)
    }

    private func setupMenu() {
        let mainMenu = NSMenu()

        // App menu
        let appMenuItem = NSMenuItem()
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "About MarkdownRender", action: #selector(showAbout), keyEquivalent: "")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "Quit MarkdownRender", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appMenuItem.submenu = appMenu
        mainMenu.addItem(appMenuItem)

        // File menu
        let fileMenuItem = NSMenuItem()
        let fileMenu = NSMenu(title: "File")
        fileMenu.addItem(withTitle: "Reload", action: #selector(reloadMarkdown), keyEquivalent: "r")
        fileMenu.addItem(NSMenuItem.separator())
        fileMenu.addItem(withTitle: "Close Window", action: #selector(window.close), keyEquivalent: "w")
        fileMenuItem.submenu = fileMenu
        mainMenu.addItem(fileMenuItem)

        // View menu
        let viewMenuItem = NSMenuItem()
        let viewMenu = NSMenu(title: "View")
        viewMenu.addItem(withTitle: "Actual Size", action: #selector(resetZoom), keyEquivalent: "0")
        viewMenu.addItem(withTitle: "Zoom In", action: #selector(zoomIn), keyEquivalent: "+")
        viewMenu.addItem(withTitle: "Zoom Out", action: #selector(zoomOut), keyEquivalent: "-")
        viewMenuItem.submenu = viewMenu
        mainMenu.addItem(viewMenuItem)

        NSApp.mainMenu = mainMenu
    }

    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "MarkdownRender"
        alert.informativeText = "A beautiful macOS markdown renderer with Mermaid and Graphviz support."
        alert.alertStyle = .informational
        alert.runModal()
    }

    @objc func reloadMarkdown() {
        loadMarkdown()
    }

    @objc private func resetZoom() {
        webView.magnification = 1.0
    }

    @objc private func zoomIn() {
        webView.magnification += 0.1
    }

    @objc private func zoomOut() {
        webView.magnification = max(0.5, webView.magnification - 0.1)
    }

    private func loadMarkdown() {
        do {
            let markdownContent = try String(contentsOf: fileURL, encoding: .utf8)
            let parser = MarkdownParser()
            let htmlBody = parser.parse(markdownContent)
            let fullHTML = HTMLGenerator.generateHTML(body: htmlBody, theme: theme)

            webView.loadHTMLString(fullHTML, baseURL: fileURL.deletingLastPathComponent())
        } catch {
            let errorHTML = HTMLGenerator.generateErrorHTML(error: error.localizedDescription)
            webView.loadHTMLString(errorHTML, baseURL: nil)
        }
    }

    private func setupFileWatcher() {
        let fileDescriptor = open(fileURL.path, O_EVTONLY)
        guard fileDescriptor >= 0 else { return }

        fileWatcher = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: .write,
            queue: .main
        )

        fileWatcher?.setEventHandler { [weak self] in
            // Small delay to ensure file write is complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self?.loadMarkdown()
            }
        }

        fileWatcher?.setCancelHandler {
            close(fileDescriptor)
        }

        fileWatcher?.resume()
    }

    func applicationWillTerminate(_ notification: Notification) {
        fileWatcher?.cancel()
    }
}
