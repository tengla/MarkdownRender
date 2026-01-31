import Foundation
import Markdown

class MarkdownParser {
    func parse(_ markdown: String) -> String {
        let document = Document(parsing: markdown)
        var htmlVisitor = HTMLConvertingVisitor()
        return htmlVisitor.visitDocument(document)
    }
}

struct HTMLConvertingVisitor: MarkupVisitor {
    typealias Result = String

    mutating func defaultVisit(_ markup: Markup) -> String {
        return markup.children.map { visit($0) }.joined()
    }

    mutating func visitDocument(_ document: Document) -> String {
        return document.children.map { visit($0) }.joined()
    }

    mutating func visitHeading(_ heading: Heading) -> String {
        let content = heading.children.map { visit($0) }.joined()
        let id = content.lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "[^a-z0-9-]", with: "", options: .regularExpression)
        return "<h\(heading.level) id=\"\(id)\">\(content)</h\(heading.level)>\n"
    }

    mutating func visitParagraph(_ paragraph: Paragraph) -> String {
        let content = paragraph.children.map { visit($0) }.joined()
        return "<p>\(content)</p>\n"
    }

    mutating func visitText(_ text: Text) -> String {
        return escapeHTML(text.string)
    }

    mutating func visitEmphasis(_ emphasis: Emphasis) -> String {
        let content = emphasis.children.map { visit($0) }.joined()
        return "<em>\(content)</em>"
    }

    mutating func visitStrong(_ strong: Strong) -> String {
        let content = strong.children.map { visit($0) }.joined()
        return "<strong>\(content)</strong>"
    }

    mutating func visitStrikethrough(_ strikethrough: Strikethrough) -> String {
        let content = strikethrough.children.map { visit($0) }.joined()
        return "<del>\(content)</del>"
    }

    mutating func visitInlineCode(_ inlineCode: InlineCode) -> String {
        return "<code>\(escapeHTML(inlineCode.code))</code>"
    }

    mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> String {
        let code = codeBlock.code
        let language = codeBlock.language ?? ""

        // Handle Mermaid diagrams
        if language.lowercased() == "mermaid" {
            return "<div class=\"mermaid\">\(escapeHTML(code))</div>\n"
        }

        // Handle Graphviz/DOT diagrams
        if ["dot", "graphviz"].contains(language.lowercased()) {
            return "<div class=\"graphviz\" data-graph=\"\(escapeHTMLAttribute(code))\"></div>\n"
        }

        // Regular code block with syntax highlighting
        let langClass = language.isEmpty ? "" : " class=\"language-\(language)\""
        return "<pre><code\(langClass)>\(escapeHTML(code))</code></pre>\n"
    }

    mutating func visitBlockQuote(_ blockQuote: BlockQuote) -> String {
        let content = blockQuote.children.map { visit($0) }.joined()
        return "<blockquote>\(content)</blockquote>\n"
    }

    mutating func visitUnorderedList(_ unorderedList: UnorderedList) -> String {
        let items = unorderedList.children.map { visit($0) }.joined()
        return "<ul>\n\(items)</ul>\n"
    }

    mutating func visitOrderedList(_ orderedList: OrderedList) -> String {
        let items = orderedList.children.map { visit($0) }.joined()
        let start = orderedList.startIndex
        let startAttr = start == 1 ? "" : " start=\"\(start)\""
        return "<ol\(startAttr)>\n\(items)</ol>\n"
    }

    mutating func visitListItem(_ listItem: ListItem) -> String {
        let content = listItem.children.map { visit($0) }.joined()
        // Check for task list items
        if let checkbox = listItem.checkbox {
            let checked = checkbox == .checked ? " checked disabled" : " disabled"
            return "<li class=\"task-list-item\"><input type=\"checkbox\"\(checked)>\(content)</li>\n"
        }
        return "<li>\(content)</li>\n"
    }

    mutating func visitLink(_ link: Link) -> String {
        let content = link.children.map { visit($0) }.joined()
        let href = escapeHTMLAttribute(link.destination ?? "")
        let title = link.title.map { " title=\"\(escapeHTMLAttribute($0))\"" } ?? ""
        return "<a href=\"\(href)\"\(title)>\(content)</a>"
    }

    mutating func visitImage(_ image: Image) -> String {
        let alt = escapeHTMLAttribute(image.plainText)
        let src = escapeHTMLAttribute(image.source ?? "")
        let title = image.title.map { " title=\"\(escapeHTMLAttribute($0))\"" } ?? ""
        return "<img src=\"\(src)\" alt=\"\(alt)\"\(title)>"
    }

    mutating func visitThematicBreak(_ thematicBreak: ThematicBreak) -> String {
        return "<hr>\n"
    }

    mutating func visitLineBreak(_ lineBreak: LineBreak) -> String {
        return "<br>\n"
    }

    mutating func visitSoftBreak(_ softBreak: SoftBreak) -> String {
        return "\n"
    }

    mutating func visitHTMLBlock(_ html: HTMLBlock) -> String {
        return html.rawHTML
    }

    mutating func visitInlineHTML(_ html: InlineHTML) -> String {
        return html.rawHTML
    }

    mutating func visitTable(_ table: Table) -> String {
        let content = table.children.map { visit($0) }.joined()
        return "<table>\n\(content)</table>\n"
    }

    mutating func visitTableHead(_ tableHead: Table.Head) -> String {
        let cells = tableHead.children.map { visit($0) }.joined()
        return "<thead>\n<tr>\(cells)</tr>\n</thead>\n"
    }

    mutating func visitTableBody(_ tableBody: Table.Body) -> String {
        let rows = tableBody.children.map { visit($0) }.joined()
        return "<tbody>\n\(rows)</tbody>\n"
    }

    mutating func visitTableRow(_ tableRow: Table.Row) -> String {
        let cells = tableRow.children.map { visit($0) }.joined()
        return "<tr>\(cells)</tr>\n"
    }

    mutating func visitTableCell(_ tableCell: Table.Cell) -> String {
        let content = tableCell.children.map { visit($0) }.joined()
        let tag = tableCell.parent is Table.Head ? "th" : "td"
        return "<\(tag)>\(content)</\(tag)>"
    }

    // MARK: - Helper Methods

    private func escapeHTML(_ string: String) -> String {
        return string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }

    private func escapeHTMLAttribute(_ string: String) -> String {
        return escapeHTML(string)
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }
}
