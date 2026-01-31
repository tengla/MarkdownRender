import Foundation

struct HTMLGenerator {
    static func generateHTML(body: String, theme: String) -> String {
        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>MarkdownRender</title>
            <style>
        \(generateCSS())
            </style>
        </head>
        <body>
            <article class="markdown-body">
        \(body)
            </article>

            <!-- Mermaid.js for diagram rendering -->
            <script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>

            <!-- Viz.js for Graphviz rendering -->
            <script src="https://cdn.jsdelivr.net/npm/@viz-js/viz@3/lib/viz-standalone.min.js"></script>

            <!-- Highlight.js for code syntax highlighting -->
            <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/highlight.js@11/styles/github.min.css" media="(prefers-color-scheme: light)">
            <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/highlight.js@11/styles/github-dark.min.css" media="(prefers-color-scheme: dark)">
            <script src="https://cdn.jsdelivr.net/npm/highlight.js@11/lib/common.min.js"></script>

            <script>
                // Initialize Mermaid
                mermaid.initialize({
                    startOnLoad: true,
                    theme: window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'default',
                    securityLevel: 'loose',
                    fontFamily: '-apple-system, BlinkMacSystemFont, "SF Pro Text", "Helvetica Neue", sans-serif'
                });

                // Initialize Graphviz diagrams
                document.addEventListener('DOMContentLoaded', async function() {
                    const graphvizDivs = document.querySelectorAll('.graphviz');

                    if (graphvizDivs.length > 0 && typeof Viz !== 'undefined') {
                        const viz = await Viz.instance();

                        graphvizDivs.forEach(div => {
                            const dotCode = div.getAttribute('data-graph');
                            if (dotCode) {
                                try {
                                    const svg = viz.renderSVGElement(dotCode);
                                    svg.style.maxWidth = '100%';
                                    svg.style.height = 'auto';
                                    div.appendChild(svg);
                                } catch (error) {
                                    div.innerHTML = '<pre class="error">Graphviz Error: ' + error.message + '</pre>';
                                }
                            }
                        });
                    }

                    // Initialize syntax highlighting
                    if (typeof hljs !== 'undefined') {
                        document.querySelectorAll('pre code').forEach((block) => {
                            hljs.highlightElement(block);
                        });
                    }
                });
            </script>
        </body>
        </html>
        """
    }

    static func generateCSS() -> String {
        return """
        :root {
            --bg-color: #ffffff;
            --text-color: #24292f;
            --text-secondary: #57606a;
            --border-color: #d0d7de;
            --code-bg: #f6f8fa;
            --link-color: #0969da;
            --blockquote-border: #d0d7de;
            --blockquote-text: #57606a;
            --table-border: #d0d7de;
            --table-row-alt: #f6f8fa;
            --hr-color: #d8dee4;
        }

        @media (prefers-color-scheme: dark) {
            :root {
                --bg-color: #0d1117;
                --text-color: #c9d1d9;
                --text-secondary: #8b949e;
                --border-color: #30363d;
                --code-bg: #161b22;
                --link-color: #58a6ff;
                --blockquote-border: #3b434b;
                --blockquote-text: #8b949e;
                --table-border: #30363d;
                --table-row-alt: #161b22;
                --hr-color: #21262d;
            }
        }

        * {
            box-sizing: border-box;
        }

        html {
            font-size: 16px;
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", "Helvetica Neue", Helvetica, Arial, sans-serif;
            font-size: 1rem;
            line-height: 1.6;
            color: var(--text-color);
            background-color: var(--bg-color);
            margin: 0;
            padding: 0;
        }

        .markdown-body {
            max-width: 780px;
            margin: 0 auto;
            padding: 32px 24px 64px;
        }

        /* Headings */
        h1, h2, h3, h4, h5, h6 {
            font-family: -apple-system, BlinkMacSystemFont, "SF Pro Display", "Helvetica Neue", Helvetica, Arial, sans-serif;
            font-weight: 600;
            line-height: 1.25;
            margin-top: 1.5em;
            margin-bottom: 0.5em;
        }

        h1 {
            font-size: 2em;
            font-weight: 700;
            padding-bottom: 0.3em;
            border-bottom: 1px solid var(--border-color);
        }

        h2 {
            font-size: 1.5em;
            padding-bottom: 0.3em;
            border-bottom: 1px solid var(--border-color);
        }

        h3 { font-size: 1.25em; }
        h4 { font-size: 1em; }
        h5 { font-size: 0.875em; }
        h6 { font-size: 0.85em; color: var(--text-secondary); }

        h1:first-child, h2:first-child, h3:first-child {
            margin-top: 0;
        }

        /* Paragraphs and text */
        p {
            margin-top: 0;
            margin-bottom: 1em;
        }

        a {
            color: var(--link-color);
            text-decoration: none;
        }

        a:hover {
            text-decoration: underline;
        }

        strong {
            font-weight: 600;
        }

        /* Code */
        code {
            font-family: "SF Mono", SFMono-Regular, ui-monospace, Menlo, Monaco, "Cascadia Code", "Consolas", monospace;
            font-size: 0.875em;
            background-color: var(--code-bg);
            padding: 0.2em 0.4em;
            border-radius: 6px;
        }

        pre {
            background-color: var(--code-bg);
            border-radius: 6px;
            padding: 16px;
            overflow-x: auto;
            margin: 1em 0;
        }

        pre code {
            background-color: transparent;
            padding: 0;
            font-size: 0.875rem;
            line-height: 1.45;
        }

        /* Blockquotes */
        blockquote {
            margin: 1em 0;
            padding: 0 1em;
            color: var(--blockquote-text);
            border-left: 4px solid var(--blockquote-border);
        }

        blockquote > :first-child {
            margin-top: 0;
        }

        blockquote > :last-child {
            margin-bottom: 0;
        }

        /* Lists */
        ul, ol {
            padding-left: 2em;
            margin-top: 0;
            margin-bottom: 1em;
        }

        ul ul, ul ol, ol ul, ol ol {
            margin-bottom: 0;
        }

        li {
            margin-top: 0.25em;
        }

        li + li {
            margin-top: 0.25em;
        }

        /* Task lists */
        .task-list-item {
            list-style-type: none;
            margin-left: -1.5em;
        }

        .task-list-item input[type="checkbox"] {
            margin-right: 0.5em;
            vertical-align: middle;
        }

        /* Tables */
        table {
            border-collapse: collapse;
            width: 100%;
            margin: 1em 0;
            overflow: auto;
        }

        th, td {
            border: 1px solid var(--table-border);
            padding: 8px 13px;
            text-align: left;
        }

        th {
            font-weight: 600;
            background-color: var(--code-bg);
        }

        tr:nth-child(even) {
            background-color: var(--table-row-alt);
        }

        /* Horizontal rules */
        hr {
            height: 0.25em;
            padding: 0;
            margin: 24px 0;
            background-color: var(--hr-color);
            border: 0;
            border-radius: 2px;
        }

        /* Images */
        img {
            max-width: 100%;
            height: auto;
            border-radius: 6px;
        }

        /* Mermaid and Graphviz diagrams */
        .mermaid, .graphviz {
            background-color: var(--code-bg);
            border-radius: 6px;
            padding: 16px;
            margin: 1em 0;
            text-align: center;
            overflow-x: auto;
        }

        .mermaid svg, .graphviz svg {
            max-width: 100%;
            height: auto;
        }

        /* Error display */
        .error {
            color: #cf222e;
            background-color: #ffebe9;
            border: 1px solid #ff8182;
            border-radius: 6px;
            padding: 16px;
            margin: 1em 0;
        }

        @media (prefers-color-scheme: dark) {
            .error {
                color: #ff7b72;
                background-color: rgba(248, 81, 73, 0.1);
                border-color: rgba(248, 81, 73, 0.4);
            }
        }

        /* Print styles */
        @media print {
            body {
                background-color: white;
                color: black;
            }

            .markdown-body {
                max-width: none;
                padding: 0;
            }

            pre, code {
                background-color: #f6f8fa !important;
            }

            a {
                color: black;
                text-decoration: underline;
            }
        }
        """
    }

    static func generateErrorHTML(error: String) -> String {
        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <title>Error</title>
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, sans-serif;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    height: 100vh;
                    margin: 0;
                    background-color: #f6f8fa;
                }
                @media (prefers-color-scheme: dark) {
                    body { background-color: #0d1117; color: #c9d1d9; }
                }
                .error-box {
                    text-align: center;
                    padding: 40px;
                }
                .error-icon {
                    font-size: 48px;
                    margin-bottom: 16px;
                }
                .error-message {
                    color: #cf222e;
                    font-size: 14px;
                    font-family: monospace;
                    background: rgba(248,81,73,0.1);
                    padding: 12px 16px;
                    border-radius: 6px;
                    margin-top: 16px;
                }
                @media (prefers-color-scheme: dark) {
                    .error-message { color: #ff7b72; }
                }
            </style>
        </head>
        <body>
            <div class="error-box">
                <div class="error-icon">⚠️</div>
                <h2>Unable to render markdown</h2>
                <div class="error-message">\(error)</div>
            </div>
        </body>
        </html>
        """
    }
}
