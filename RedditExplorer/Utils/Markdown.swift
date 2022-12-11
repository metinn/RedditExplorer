//
//  Markdown.swift
//  RedditExplorer
//
//  Created by Metin Guler on 11.12.22.
//

import Foundation

class Markdown {
    static func getAttributedString(from: String) -> AttributedString? {
        return try? AttributedString(markdown: from,
                                     options: .init(interpretedSyntax:
                                            .inlineOnlyPreservingWhitespace))
    }
}
