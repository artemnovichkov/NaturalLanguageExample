//
//  Created by Artem Novichkov on 25.11.2024.
//

import SwiftUI
import NaturalLanguage

struct NoteView: View {

    enum Sentiment {
        case negative
        case neutral
        case positive
    }

    @State var note: String
    @FocusState private var isFocused: Bool
    @State private var sentiment: Sentiment = .neutral

    var body: some View {
        TextEditor(text: $note)
            .multilineTextAlignment(.center)
            .scrollContentBackground(.hidden)
            .foregroundStyle(.white)
            .tint(.white)
            .font(.system(size: 40, weight: .thin, design: .serif))
            .focused($isFocused)
            .background {
                MeshGradient(width: 4, height: 4, points: [
                    [0, 0],    [0.25, 0],    [0.5, 0],    [1, 0],
                    [0, 0.25], [0.25, 0.25], [0.5, 0.25], [1, 0.25],
                    [0, 0.75], [0.25, 0.75], [0.5, 0.75], [1, 0.75],
                    [0, 1],    [0.25, 1],    [0.5, 1],    [1, 1]
                ], colors: sentimentColors)
                .animation(.smooth(duration: 1), value: sentiment)
            }
            .ignoresSafeArea()
            .onAppear {
                isFocused = true
                sentiment = sentiment(for: note)
            }
            .onChange(of: note) {
                sentiment = sentiment(for: note)
            }
    }

    private var sentimentColors: [Color] {
        switch sentiment {
        case .negative:
            negativeColors
        case .neutral:
            neutralColors
        case .positive:
            positiveColors
        }
    }

    private var negativeColors: [Color] {
        [Color(r: 255, g: 110, b: 10),
         Color(r: 250, g: 140, b: 64),
         Color(r: 255, g: 163, b: 102),
         Color(r: 249, g: 186, b: 144),

         Color(r: 249, g: 171, b: 176),
         Color(r: 255, g: 158, b: 171),
         Color(r: 255, g: 131, b: 150),
         Color(r: 255, g: 112, b: 134),

         Color(r: 255, g: 84, b: 113),
         Color(r: 255, g: 57, b: 93),
         Color(r: 255, g: 39, b: 80),
         Color(r: 255, g: 10, b: 58),

         Color(r: 208, g: 5, b: 42),
         Color(r: 159, g: 8, b: 48),
         Color(r: 107, g: 5, b: 43),
         Color(r: 56, g: 5, b: 43)]
    }

    private var neutralColors: [Color] {
        [Color(r: 244, g: 244, b: 244),
         Color(r: 231, g: 238, b: 248),
         Color(r: 223, g: 235, b: 248),
         Color(r: 196, g: 227, b: 248),

         Color(r: 170, g: 216, b: 248),
         Color(r: 148, g: 208, b: 250),
         Color(r: 117, g: 196, b: 253),
         Color(r: 116, g: 202, b: 255),

         Color(r: 85, g: 189, b: 255),
         Color(r: 62, g: 180, b: 255),
         Color(r: 43, g: 173, b: 255),
         Color(r: 21, g: 165, b: 255),

         Color(r: 6, g: 132, b: 221),
         Color(r: 12, g: 111, b: 211),
         Color(r: 11, g: 85, b: 186),
         Color(r: 11, g: 61, b: 162)]
    }

    private var positiveColors: [Color] {
        [Color(r: 12, g: 87, b: 12),
         Color(r: 10, g: 109, b: 9),
         Color(r: 14, g: 138, b: 14),
         Color(r: 21, g: 166, b: 21),

         Color(r: 14, g: 186, b: 14),
         Color(r: 7, g: 207, b: 7),
         Color(r: 17, g: 235, b: 17),
         Color(r: 11, g: 255, b: 11),

         Color(r: 44, g: 251, b: 44),
         Color(r: 93, g: 249, b: 93),
         Color(r: 148, g: 251, b: 148),
         Color(r: 195, g: 248, b: 195),

         Color(r: 9, g: 71, b: 9),
         Color(r: 16, g: 103, b: 16),
         Color(r: 13, g: 125, b: 13),
         Color(r: 6, g: 144, b: 6)]
    }

    private func sentiment(for text: String) -> Sentiment {
        let availableTagSchemes = NLTagger.availableTagSchemes(for: .paragraph, language: .english)
        guard availableTagSchemes.contains(.sentimentScore) else {
            return .neutral
        }
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text
        let (sentimentTag, _) = tagger.tag(at: note.startIndex,
                                           unit: .paragraph,
                                           scheme: .sentimentScore)
        guard let sentimentTag else {
            return .neutral
        }

        let score = Double(sentimentTag.rawValue) ?? 0
        if score < -0.6 {
            return .negative
        } else if score >= 0.2 {
            return  .positive
        } else {
            return .neutral
        }
    }
}

extension Color {

    init(r: Int, g: Int, b: Int) {
        self.init(red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255)
    }
}

#Preview {
    NoteView(note: "Day was good")
}
