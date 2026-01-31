import XCTest
@testable import MarkdownRender

final class MarkdownParserTests: XCTestCase {
    var parser: MarkdownParser!

    override func setUp() {
        super.setUp()
        parser = MarkdownParser()
    }

    // MARK: - Headings

    func testHeading1() {
        let markdown = "# Hello World"
        let html = parser.parse(markdown)
        XCTAssertTrue(html.contains("<h1"))
        XCTAssertTrue(html.contains("Hello World"))
        XCTAssertTrue(html.contains("</h1>"))
    }

    func testHeading2() {
        let markdown = "## Section Title"
        let html = parser.parse(markdown)
        XCTAssertTrue(html.contains("<h2"))
        XCTAssertTrue(html.contains("Section Title"))
    }

    func testHeadingWithId() {
        let markdown = "# My Heading"
        let html = parser.parse(markdown)
        XCTAssertTrue(html.contains("id=\"my-heading\""))
    }

    // MARK: - Paragraphs and Text

    func testParagraph() {
        let markdown = "This is a paragraph."
        let html = parser.parse(markdown)
        XCTAssertTrue(html.contains("<p>This is a paragraph.</p>"))
    }

    func testBoldText() {
        let markdown = "This is **bold** text."
        let html = parser.parse(markdown)
        XCTAssertTrue(html.contains("<strong>bold</strong>"))
    }

    func testItalicText() {
        let markdown = "This is *italic* text."
        let html = parser.parse(markdown)
        XCTAssertTrue(html.contains("<em>italic</em>"))
    }

    func testStrikethrough() {
        let markdown = "This is ~~deleted~~ text."
        let html = parser.parse(markdown)
        XCTAssertTrue(html.contains("<del>deleted</del>"))
    }

    func testInlineCode() {
        let markdown = "Use the `print()` function."
        let html = parser.parse(markdown)
        XCTAssertTrue(html.contains("<code>print()</code>"))
    }

    // MARK: - Links and Images

    func testLink() {
        let markdown = "Visit [Google](https://google.com)."
        let html = parser.parse(markdown)
        XCTAssertTrue(html.contains("<a href=\"https://google.com\">Google</a>"))
    }

    func testLinkWithTitle() {
        let markdown = "[Example](https://example.com \"Example Site\")"
        let html = parser.parse(markdown)
        XCTAssertTrue(html.contains("title=\"Example Site\""))
    }

    func testImage() {
        let markdown = "![Alt text](image.png)"
        let html = parser.parse(markdown)
        XCTAssertTrue(html.contains("<img"))
        XCTAssertTrue(html.contains("src=\"image.png\""))
        XCTAssertTrue(html.contains("alt=\"Alt text\""))
    }

    // MARK: - Lists

    func testUnorderedList() {
        let markdown = """
        - Item 1
        - Item 2
        - Item 3
        """
        let html = parser.parse(markdown)
        XCTAssertTrue(html.contains("<ul>"))
        XCTAssertTrue(html.contains("<li>"))
        XCTAssertTrue(html.contains("Item 1"))
        XCTAssertTrue(html.contains("</ul>"))
    }

    func testOrderedList() {
        let markdown = """
        1. First
        2. Second
        3. Third
        """
        let html = parser.parse(markdown)
        XCTAssertTrue(html.contains("<ol>"))
        XCTAssertTrue(html.contains("<li>"))
        XCTAssertTrue(html.contains("First"))
    }

    func testTaskList() {
        let markdown = """
        - [x] Done
        - [ ] Not done
        """
        let html = parser.parse(markdown)
        XCTAssertTrue(html.contains("class=\"task-list-item\""))
        XCTAssertTrue(html.contains("type=\"checkbox\""))
        XCTAssertTrue(html.contains("checked"))
    }

    // MARK: - Code Blocks

    func testCodeBlock() {
        let markdown = """
        ```swift
        let x = 42
        ```
        """
        let html = parser.parse(markdown)
        XCTAssertTrue(html.contains("<pre>"))
        XCTAssertTrue(html.contains("<code"))
        XCTAssertTrue(html.contains("language-swift"))
        XCTAssertTrue(html.contains("let x = 42"))
    }

    func testCodeBlockWithoutLanguage() {
        let markdown = """
        ```
        plain code
        ```
        """
        let html = parser.parse(markdown)
        XCTAssertTrue(html.contains("<pre><code>"))
        XCTAssertFalse(html.contains("language-"))
    }

    // MARK: - Mermaid Diagrams

    func testMermaidBlock() {
        let markdown = """
        ```mermaid
        flowchart TD
            A --> B
        ```
        """
        let html = parser.parse(markdown)
        XCTAssertTrue(html.contains("<div class=\"mermaid\">"))
        XCTAssertTrue(html.contains("flowchart TD"))
        XCTAssertFalse(html.contains("<pre>"))
    }

    // MARK: - Graphviz Diagrams

    func testGraphvizDotBlock() {
        let markdown = """
        ```dot
        digraph G { A -> B; }
        ```
        """
        let html = parser.parse(markdown)
        XCTAssertTrue(html.contains("<div class=\"graphviz\""))
        XCTAssertTrue(html.contains("data-graph="))
        XCTAssertFalse(html.contains("<pre>"))
    }

    func testGraphvizBlock() {
        let markdown = """
        ```graphviz
        digraph G { A -> B; }
        ```
        """
        let html = parser.parse(markdown)
        XCTAssertTrue(html.contains("<div class=\"graphviz\""))
    }

    // MARK: - Blockquotes

    func testBlockquote() {
        let markdown = "> This is a quote."
        let html = parser.parse(markdown)
        XCTAssertTrue(html.contains("<blockquote>"))
        XCTAssertTrue(html.contains("This is a quote."))
        XCTAssertTrue(html.contains("</blockquote>"))
    }

    // MARK: - Horizontal Rules

    func testHorizontalRule() {
        let markdown = "---"
        let html = parser.parse(markdown)
        XCTAssertTrue(html.contains("<hr>"))
    }

    // MARK: - Tables

    func testTable() {
        let markdown = """
        | Header 1 | Header 2 |
        |----------|----------|
        | Cell 1   | Cell 2   |
        """
        let html = parser.parse(markdown)
        XCTAssertTrue(html.contains("<table>"))
        XCTAssertTrue(html.contains("<thead>"))
        XCTAssertTrue(html.contains("<tbody>"))
        XCTAssertTrue(html.contains("<th>"))
        XCTAssertTrue(html.contains("<td>"))
    }

    // MARK: - HTML Escaping

    func testHtmlEscaping() {
        let markdown = "Use `<div>` tags."
        let html = parser.parse(markdown)
        XCTAssertTrue(html.contains("&lt;div&gt;"))
        XCTAssertFalse(html.contains("<div>"))
    }

    func testAmpersandEscaping() {
        let markdown = "Tom & Jerry"
        let html = parser.parse(markdown)
        XCTAssertTrue(html.contains("Tom &amp; Jerry"))
    }

    // MARK: - Complex Documents

    func testComplexDocument() {
        let markdown = """
        # Title

        This is a **paragraph** with *formatting*.

        ## Code Example

        ```swift
        func hello() {
            print("Hello!")
        }
        ```

        ## Diagram

        ```mermaid
        flowchart LR
            A --> B
        ```

        - Item 1
        - Item 2

        > A quote

        ---

        The end.
        """
        let html = parser.parse(markdown)

        // Check all major elements are present
        XCTAssertTrue(html.contains("<h1"))
        XCTAssertTrue(html.contains("<h2"))
        XCTAssertTrue(html.contains("<strong>"))
        XCTAssertTrue(html.contains("<em>"))
        XCTAssertTrue(html.contains("<pre>"))
        XCTAssertTrue(html.contains("class=\"mermaid\""))
        XCTAssertTrue(html.contains("<ul>"))
        XCTAssertTrue(html.contains("<blockquote>"))
        XCTAssertTrue(html.contains("<hr>"))
    }
}
