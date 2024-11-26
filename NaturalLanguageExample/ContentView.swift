//
//  Created by Artem Novichkov on 25.11.2024.
//

import SwiftUI
import NaturalLanguage

struct ContentView: View {

    @State private var notes: [String] = ["My day was good",
                                          "My day is not so good"]
    @State private var searchText: String = ""
    @State private var selectedNote: String?

    var body: some View {
        NavigationView {
            List {
                ForEach(searchNotes, id: \.self) { note in
                    Text(note)
                        .onTapGesture {
                            selectedNote = note
                        }
                }
            }
        }
        .searchable(text: $searchText)
        .navigationTitle("Notes")
        .sheet(item: $selectedNote) { selectedNote in
            NoteView(note: selectedNote)
        }
    }

    private var searchNotes: [String] {
        if searchText.isEmpty {
            return notes
        }
        let sentenceEmbedding = NLEmbedding.sentenceEmbedding(for: .english)!
        return notes.filter { note in
            let distance = sentenceEmbedding.distance(between: searchText, and: note)
            return distance < 1
        }
    }
}

extension String: @retroactive Identifiable {

    public var id: String { self }
}

#Preview {
    ContentView()
}
