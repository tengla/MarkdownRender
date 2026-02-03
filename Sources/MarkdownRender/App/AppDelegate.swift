import AppKit
import WebKit

class AppDelegate: NSObject, NSApplicationDelegate, NSSearchFieldDelegate {
    var fileURL: URL?
    var watchEnabled: Bool
    var theme: String

    var window: NSWindow!
    var webView: WKWebView!
    var fileWatcher: DispatchSourceFileSystemObject?
    private var hasOpenedFile = false

    // Search UI
    var searchBar: NSView!
    var searchField: NSSearchField!
    var searchResultsLabel: NSTextField!
    var searchBarTopConstraint: NSLayoutConstraint!

    init(fileURL: URL?, watchEnabled: Bool, theme: String) {
        self.fileURL = fileURL
        self.watchEnabled = watchEnabled
        self.theme = theme
        super.init()
    }

    // Handle files opened via "Open With" or drag-and-drop onto app icon
    func application(_ application: NSApplication, open urls: [URL]) {
        guard let url = urls.first else { return }
        hasOpenedFile = true
        openFile(url)
    }

    func openFile(_ url: URL) {
        // Stop existing file watcher
        fileWatcher?.cancel()
        fileWatcher = nil

        fileURL = url
        if window != nil {
            window.title = url.lastPathComponent
            loadMarkdown()
            if watchEnabled {
                setupFileWatcher()
            }
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupWindow()
        setupWebView()
        setupMenu()

        // If we have a file from CLI, load it
        // Otherwise, wait briefly for application(_:open:) or show Open dialog
        if fileURL != nil {
            hasOpenedFile = true
            loadMarkdown()
            if watchEnabled {
                setupFileWatcher()
            }
        } else {
            // Show welcome message while waiting
            showWelcome()
            // Give macOS a moment to call application(_:open:) for "Open With"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                guard let self = self else { return }
                if !self.hasOpenedFile {
                    self.showOpenDialog()
                }
            }
        }

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        // Ensure webView has focus, not search field
        window.makeFirstResponder(webView)
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

        window.title = fileURL?.lastPathComponent ?? "MarkdownRender"
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

        webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false

        // Transparent background to match window
        webView.setValue(false, forKey: "drawsBackground")

        window.contentView?.addSubview(webView)

        // Setup search bar
        setupSearchBar()

        // Layout constraints
        guard let contentView = window.contentView else { return }

        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            webView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            webView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    private func setupSearchBar() {
        guard let contentView = window.contentView else { return }

        // Container view for search bar
        searchBar = NSView()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.wantsLayer = true
        contentView.addSubview(searchBar)

        // Search field
        searchField = NSSearchField()
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.placeholderString = "Search..."
        searchField.sendsSearchStringImmediately = true
        searchField.target = self
        searchField.action = #selector(searchTextChanged)
        searchField.delegate = self
        searchBar.addSubview(searchField)

        // Results label
        searchResultsLabel = NSTextField(labelWithString: "")
        searchResultsLabel.translatesAutoresizingMaskIntoConstraints = false
        searchResultsLabel.font = NSFont.systemFont(ofSize: 11)
        searchResultsLabel.textColor = .secondaryLabelColor
        searchBar.addSubview(searchResultsLabel)

        // Close button
        let closeButton = NSButton(title: "Done", target: self, action: #selector(hideSearchBar))
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.bezelStyle = .inline
        closeButton.setButtonType(.momentaryPushIn)
        searchBar.addSubview(closeButton)

        // Previous/Next buttons
        let prevButton = NSButton(image: NSImage(systemSymbolName: "chevron.up", accessibilityDescription: "Previous")!, target: self, action: #selector(findPrevious))
        prevButton.translatesAutoresizingMaskIntoConstraints = false
        prevButton.bezelStyle = .inline
        prevButton.isBordered = false
        searchBar.addSubview(prevButton)

        let nextButton = NSButton(image: NSImage(systemSymbolName: "chevron.down", accessibilityDescription: "Next")!, target: self, action: #selector(findNext))
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.bezelStyle = .inline
        nextButton.isBordered = false
        searchBar.addSubview(nextButton)

        // Initially hidden - don't allow focus
        searchField.refusesFirstResponder = true

        // Constraints
        searchBarTopConstraint = searchBar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -40)

        NSLayoutConstraint.activate([
            searchBarTopConstraint,
            searchBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 40),

            searchField.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor, constant: 12),
            searchField.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            searchField.widthAnchor.constraint(equalToConstant: 220),

            prevButton.leadingAnchor.constraint(equalTo: searchField.trailingAnchor, constant: 8),
            prevButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),

            nextButton.leadingAnchor.constraint(equalTo: prevButton.trailingAnchor, constant: 4),
            nextButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),

            searchResultsLabel.leadingAnchor.constraint(equalTo: nextButton.trailingAnchor, constant: 12),
            searchResultsLabel.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),

            closeButton.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: -12),
            closeButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor)
        ])
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
        fileMenu.addItem(withTitle: "Open...", action: #selector(openDocument), keyEquivalent: "o")
        fileMenu.addItem(withTitle: "Reload", action: #selector(reloadMarkdown), keyEquivalent: "r")
        fileMenu.addItem(NSMenuItem.separator())
        fileMenu.addItem(withTitle: "Export as PDF...", action: #selector(exportPDF), keyEquivalent: "e")
        fileMenu.addItem(NSMenuItem.separator())
        fileMenu.addItem(withTitle: "Close Window", action: #selector(window.close), keyEquivalent: "w")
        fileMenuItem.submenu = fileMenu
        mainMenu.addItem(fileMenuItem)

        // Edit menu
        let editMenuItem = NSMenuItem()
        let editMenu = NSMenu(title: "Edit")
        editMenu.addItem(withTitle: "Find...", action: #selector(showSearchBar), keyEquivalent: "f")
        editMenu.addItem(withTitle: "Find Next", action: #selector(findNext), keyEquivalent: "g")
        let findPrevItem = editMenu.addItem(withTitle: "Find Previous", action: #selector(findPrevious), keyEquivalent: "g")
        findPrevItem.keyEquivalentModifierMask = [.command, .shift]
        editMenuItem.submenu = editMenu
        mainMenu.addItem(editMenuItem)

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

    @objc private func openDocument() {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.init(filenameExtension: "md")!]
        openPanel.allowsOtherFileTypes = true
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowsMultipleSelection = false
        openPanel.message = "Choose a Markdown file to open"
        openPanel.prompt = "Open"

        openPanel.beginSheetModal(for: window) { [weak self] response in
            guard response == .OK, let url = openPanel.url else { return }
            self?.openFile(url)
        }
    }

    @objc private func exportPDF() {
        guard fileURL != nil else { return }

        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.pdf]
        savePanel.nameFieldStringValue = fileURL!.deletingPathExtension().lastPathComponent + ".pdf"
        savePanel.title = "Export as PDF"
        savePanel.message = "Choose a location to save the PDF"

        savePanel.beginSheetModal(for: window) { [weak self] response in
            guard response == .OK, let url = savePanel.url else { return }
            self?.createPDF(at: url)
        }
    }

    private func createPDF(at url: URL) {
        let printInfo = NSPrintInfo()
        printInfo.paperSize = NSSize(width: 612, height: 792) // US Letter
        printInfo.topMargin = 36
        printInfo.bottomMargin = 36
        printInfo.leftMargin = 36
        printInfo.rightMargin = 36
        printInfo.isHorizontallyCentered = true
        printInfo.isVerticallyCentered = false

        let printOperation = webView.printOperation(with: printInfo)
        printOperation.showsPrintPanel = false
        printOperation.showsProgressPanel = true
        printOperation.pdfPanel = NSPDFPanel()

        // Use the modern PDF creation API
        webView.createPDF(configuration: WKPDFConfiguration()) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    try data.write(to: url)
                    // Open in Finder and select the file
                    NSWorkspace.shared.activateFileViewerSelecting([url])
                } catch {
                    self?.showError("Failed to save PDF: \(error.localizedDescription)")
                }
            case .failure(let error):
                self?.showError("Failed to create PDF: \(error.localizedDescription)")
            }
        }
    }

    private func showError(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "Export Failed"
        alert.informativeText = message
        alert.alertStyle = .critical
        alert.runModal()
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

    // MARK: - Search

    @objc func showSearchBar() {
        guard searchBarTopConstraint.constant < 0 else {
            // Already visible, focus the field
            window.makeFirstResponder(searchField)
            return
        }

        // Allow focus when showing
        searchField.refusesFirstResponder = false

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            searchBarTopConstraint.animator().constant = 0
        } completionHandler: { [weak self] in
            self?.window.makeFirstResponder(self?.searchField)
        }
    }

    @objc func hideSearchBar() {
        // Clear highlighting
        webView.evaluateJavaScript("window.getSelection().removeAllRanges(); document.body.classList.remove('searching');", completionHandler: nil)
        searchField.stringValue = ""
        searchResultsLabel.stringValue = ""

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            searchBarTopConstraint.animator().constant = -40
        } completionHandler: { [weak self] in
            // Prevent focus when hidden
            self?.searchField.refusesFirstResponder = true
            self?.window.makeFirstResponder(self?.webView)
        }
    }

    @objc func searchTextChanged() {
        let searchText = searchField.stringValue
        if searchText.isEmpty {
            searchResultsLabel.stringValue = ""
            webView.evaluateJavaScript("window.getSelection().removeAllRanges();", completionHandler: nil)
            return
        }
        performSearch(searchText, forward: true)
    }

    @objc func findNext() {
        let searchText = searchField.stringValue
        guard !searchText.isEmpty else { return }
        performSearch(searchText, forward: true)
    }

    @objc func findPrevious() {
        let searchText = searchField.stringValue
        guard !searchText.isEmpty else { return }
        performSearch(searchText, forward: false)
    }

    private func performSearch(_ text: String, forward: Bool) {
        // Use window.find() for in-page search with highlighting
        let escapedText = text.replacingOccurrences(of: "\\", with: "\\\\")
                              .replacingOccurrences(of: "'", with: "\\'")
        let direction = forward ? "false" : "true"

        let js = """
        (function() {
            var found = window.find('\(escapedText)', false, \(direction), true, false, false, false);
            return found;
        })();
        """

        webView.evaluateJavaScript(js) { [weak self] result, _ in
            if let found = result as? Bool {
                self?.searchResultsLabel.stringValue = found ? "" : "Not found"
                self?.searchResultsLabel.textColor = found ? .secondaryLabelColor : .systemRed
            }
        }
    }

    // Handle Escape key in search field
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
            hideSearchBar()
            return true
        }
        return false
    }

    private func loadMarkdown() {
        guard let fileURL = fileURL else {
            showWelcome()
            return
        }

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

    private func showWelcome() {
        let welcomeHTML = HTMLGenerator.generateWelcomeHTML(theme: theme)
        webView.loadHTMLString(welcomeHTML, baseURL: nil)
    }

    private func showOpenDialog() {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.init(filenameExtension: "md")!]
        openPanel.allowsOtherFileTypes = true
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowsMultipleSelection = false
        openPanel.message = "Choose a Markdown file to open"
        openPanel.prompt = "Open"

        openPanel.beginSheetModal(for: window) { [weak self] response in
            guard response == .OK, let url = openPanel.url else {
                // User cancelled - quit the app
                NSApp.terminate(nil)
                return
            }
            self?.hasOpenedFile = true
            self?.openFile(url)
        }
    }

    private func setupFileWatcher() {
        guard let fileURL = fileURL else { return }
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
