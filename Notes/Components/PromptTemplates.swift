import SwiftUI

struct PromptTemplate: Identifiable {
    let id = UUID()
    let title: String
    let prompt: String
    let icon: String
}

struct PromptTemplates: View {
    let templates: [PromptTemplate] = [
        PromptTemplate(
            title: "Meeting Notes",
            prompt: "Transform these meeting minutes into well-structured notes with key points, action items, and decisions made.",
            icon: "person.2.fill"
        ),
        PromptTemplate(
            title: "Study Notes",
            prompt: "Convert this study material into concise notes with main concepts, definitions, and examples.",
            icon: "book.fill"
        ),
        PromptTemplate(
            title: "Research Notes",
            prompt: "Organize this research information into structured notes with methodology, findings, and conclusions.",
            icon: "magnifyingglass"
        ),
        PromptTemplate(
            title: "Project Notes",
            prompt: "Structure these project details into clear notes with objectives, timeline, and deliverables.",
            icon: "list.clipboard.fill"
        ),
    ]

    var onTemplateSelected: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(templates) { template in
                    TemplateCard(template: template) {
                        onTemplateSelected(template.prompt)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct TemplateCard: View {
    let template: PromptTemplate
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: template.icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.purple)
                    Text(template.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                }
                Text(template.prompt)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .frame(width: 200)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.purple.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

#Preview {
    PromptTemplates { prompt in
        print(prompt)
    }
    .padding(.vertical)
    .background(Color(.systemGray6))
}
