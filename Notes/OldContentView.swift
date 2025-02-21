//
//  OldContentView.swift
//  Notes
//
//  Created by Maxime Tanter on 17/02/2025.
//

import SwiftUI

struct Note: Identifiable, Codable {
    let id: UUID
    var title: String
    var content: String
    var date: Date
    var location: String
    var color: Color
    
    init(id: UUID = UUID(), title: String = "", content: String = "",
         date: Date = Date(), location: String = "", color: Color = .gray) {
        self.id = id
        self.title = title
        self.content = content
        self.date = date
        self.location = location
        self.color = color
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, title, content, date, location, color
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        try container.encode(date, forKey: .date)
        try container.encode(location, forKey: .location)
        try container.encode(UIColor(color).hexString, forKey: .color)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        date = try container.decode(Date.self, forKey: .date)
        location = try container.decode(String.self, forKey: .location)
        let hexString = try container.decode(String.self, forKey: .color)
        color = Color(UIColor(hex: hexString) ?? .gray)
    }
}

extension UIColor {
    var hexString: String {
        let components = cgColor.components
        let r = components?[0] ?? 0
        let g = components?[1] ?? 0
        let b = components?[2] ?? 0
        return String(format: "#%02lX%02lX%02lX",
            lround(r * 255),
            lround(g * 255),
            lround(b * 255))
    }
    
    convenience init?(hex: String) {
        let r, g, b: CGFloat
        
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            
            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: 1.0)
                    return
                }
            }
        }
        return nil
    }
}

class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var isShowingNewNote = false
    
    func addNote(_ note: Note) {
        notes.insert(note, at: 0)
        saveNotes()
    }
    
    func deleteNote(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes.remove(at: index)
            saveNotes()
        }
    }
    
    private func saveNotes() {
        if let encoded = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encoded, forKey: "notes")
        }
    }
    
    func loadNotes() {
        if let data = UserDefaults.standard.data(forKey: "notes"),
           let decoded = try? JSONDecoder().decode([Note].self, from: data) {
            notes = decoded
        }
    }
}

struct OldContentView: View {
    @StateObject private var viewModel = NotesViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.notes.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "note.text")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No Notes Yet")
                            .font(.title2)
                            .fontWeight(.medium)
                        Text("Tap the button above to create your first note")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(viewModel.notes) { note in
                            NavigationLink(destination: NoteDetailView(note: note, viewModel: viewModel)) {
                                NoteRowView(note: note)
                            }
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { index in
                                viewModel.deleteNote(viewModel.notes[index])
                            }
                        }
                    }
                }
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.isShowingNewNote = true }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $viewModel.isShowingNewNote) {
                NewNoteView(viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.loadNotes()
        }
    }
}

struct NoteRowView: View {
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Circle()
                    .fill(note.color)
                    .frame(width: 12, height: 12)
                Text(note.title)
                    .font(.headline)
            }
            Text(note.content)
                .font(.subheadline)
                .lineLimit(2)
                .foregroundColor(.gray)
            HStack {
                if !note.location.isEmpty {
                    Image(systemName: "location.fill")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    Text(note.location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(note.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct NoteDetailView: View {
    let note: Note
    @ObservedObject var viewModel: NotesViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Circle()
                        .fill(note.color)
                        .frame(width: 16, height: 16)
                    Text(note.title)
                        .font(.title)
                }
                
                HStack {
                    if !note.location.isEmpty {
                        Image(systemName: "location.fill")
                        Text(note.location)
                    }
                    Spacer()
                    Text(note.date, style: .date)
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                
                Text(note.content)
                    .font(.body)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.deleteNote(note)
                }) {
                    Image(systemName: "trash")
                }
            }
        }
    }
}

struct NewNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: NotesViewModel
    @State private var title = ""
    @State private var content = ""
    @State private var location = ""
    @State private var selectedDate = Date()
    @State private var selectedColor = Color.gray
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Title", text: $title)
                    TextEditor(text: $content)
                        .frame(height: 200)
                }
                
                Section("Details") {
                    TextField("Location", text: $location)
                    DatePicker("Date", selection: $selectedDate, displayedComponents: [.date])
                    ColorPicker("Color", selection: $selectedColor)
                }
            }
            .navigationTitle("New Note")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let note = Note(
                            title: title,
                            content: content,
                            date: selectedDate,
                            location: location,
                            color: selectedColor
                        )
                        viewModel.addNote(note)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

#Preview {
    OldContentView()
}
