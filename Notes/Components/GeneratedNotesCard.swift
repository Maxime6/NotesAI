import MarkdownUI
import SwiftUI

private extension Theme {
    static let custom = Theme()
        .text {
            FontSize(.em(0.8))
            ForegroundColor(.primary.opacity(0.7))
        }
        .code {
            FontFamilyVariant(.monospaced)
            FontSize(.em(0.8))
            ForegroundColor(.purple)
            BackgroundColor(.purple.opacity(0.15))
            FontWeight(.medium)
        }
        .codeBlock { configuration in
            ScrollView(.horizontal) {
                configuration.label
                    .relativeLineSpacing(.em(0.25))
                    .markdownTextStyle {
                        FontFamilyVariant(.monospaced)
                        FontSize(.em(0.85))
                    }
                    .padding()
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .markdownMargin(top: .zero, bottom: .em(0.8))
        }
        .link {
            ForegroundColor(.purple)
        }
        .heading1 { configuration in
            configuration.label
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .markdownMargin(top: 16, bottom: 8)
        }
        .heading2 { configuration in
            configuration.label
                .font(.body)
                .fontWeight(.semibold)
                .foregroundStyle(.primary.opacity(0.5))
                .markdownMargin(top: 16, bottom: 8)
        }
        .heading3 { configuration in
            configuration.label
                .foregroundStyle(.primary.opacity(0.7))
                .markdownMargin(top: 16, bottom: 8)
        }
        .paragraph { configuration in
            configuration.label
                .relativeLineSpacing(.em(0.25))
                .markdownMargin(top: 0, bottom: 16)
        }
        .listItem { configuration in
            configuration.label
                .markdownMargin(top: .em(0.25))
        }
}

struct GeneratedNotesCard: View {
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Generated Notes")
                .font(.headline)
                .padding(.top)

            Markdown(content)
                .markdownTheme(.custom)
                .textSelection(.enabled)
                .markdownBlockStyle(\.table) { configuration in
                    ScrollView(.horizontal, showsIndicators: false) {
                        configuration.label
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(32)
        .background(Color(.systemBackground))
        .cornerRadius(44)
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
}

#Preview {
    GeneratedNotesCard(content: """
    # Sample Note
    This is a sample note with some **bold** and *italic* text.

    ```swift
    let code = "Some code"
    ```
    """)
    .padding()
}
