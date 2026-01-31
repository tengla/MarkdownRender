import XCTest
@testable import MarkdownRender

final class HTMLGeneratorTests: XCTestCase {

    // MARK: - HTML Structure

    func testGeneratesValidHTML() {
        let html = HTMLGenerator.generateHTML(body: "<p>Test</p>", theme: "auto")

        XCTAssertTrue(html.contains("<!DOCTYPE html>"))
        XCTAssertTrue(html.contains("<html"))
        XCTAssertTrue(html.contains("<head>"))
        XCTAssertTrue(html.contains("<body>"))
        XCTAssertTrue(html.contains("</html>"))
    }

    func testIncludesBody() {
        let body = "<h1>Hello World</h1>"
        let html = HTMLGenerator.generateHTML(body: body, theme: "auto")

        XCTAssertTrue(html.contains(body))
    }

    func testIncludesMarkdownBodyClass() {
        let html = HTMLGenerator.generateHTML(body: "", theme: "auto")

        XCTAssertTrue(html.contains("class=\"markdown-body\""))
    }

    // MARK: - CSS

    func testIncludesCSS() {
        let html = HTMLGenerator.generateHTML(body: "", theme: "auto")

        XCTAssertTrue(html.contains("<style>"))
        XCTAssertTrue(html.contains("</style>"))
    }

    func testCSSHasDarkModeSupport() {
        let css = HTMLGenerator.generateCSS()

        XCTAssertTrue(css.contains("prefers-color-scheme: dark"))
        XCTAssertTrue(css.contains("--bg-color"))
        XCTAssertTrue(css.contains("--text-color"))
    }

    func testCSSHasTypography() {
        let css = HTMLGenerator.generateCSS()

        XCTAssertTrue(css.contains("font-family"))
        XCTAssertTrue(css.contains("line-height"))
        XCTAssertTrue(css.contains("h1"))
        XCTAssertTrue(css.contains("h2"))
    }

    func testCSSHasCodeStyles() {
        let css = HTMLGenerator.generateCSS()

        XCTAssertTrue(css.contains("pre"))
        XCTAssertTrue(css.contains("code"))
        XCTAssertTrue(css.contains("--code-bg"))
    }

    func testCSSHasDiagramStyles() {
        let css = HTMLGenerator.generateCSS()

        XCTAssertTrue(css.contains(".mermaid"))
        XCTAssertTrue(css.contains(".graphviz"))
    }

    // MARK: - JavaScript Libraries

    func testIncludesMermaid() {
        let html = HTMLGenerator.generateHTML(body: "", theme: "auto")

        XCTAssertTrue(html.contains("mermaid"))
        XCTAssertTrue(html.contains("mermaid.initialize"))
    }

    func testIncludesVizJS() {
        let html = HTMLGenerator.generateHTML(body: "", theme: "auto")

        XCTAssertTrue(html.contains("viz"))
        XCTAssertTrue(html.contains("graphviz"))
    }

    func testIncludesHighlightJS() {
        let html = HTMLGenerator.generateHTML(body: "", theme: "auto")

        XCTAssertTrue(html.contains("highlight"))
        XCTAssertTrue(html.contains("hljs"))
    }

    // MARK: - Error HTML

    func testErrorHTML() {
        let errorMessage = "File not found"
        let html = HTMLGenerator.generateErrorHTML(error: errorMessage)

        XCTAssertTrue(html.contains("<!DOCTYPE html>"))
        XCTAssertTrue(html.contains(errorMessage))
        XCTAssertTrue(html.contains("error"))
    }

    func testErrorHTMLHasStyling() {
        let html = HTMLGenerator.generateErrorHTML(error: "Test error")

        XCTAssertTrue(html.contains("<style>"))
        XCTAssertTrue(html.contains("prefers-color-scheme: dark"))
    }
}
