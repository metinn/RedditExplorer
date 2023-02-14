//
//  CommentView.swift
//  RedditExplorer
//
//  Created by Metin Güler on 19.07.22.
//

import SwiftUI

struct CommentView: View {
    let comment: Comment
    let postAuthor: String
    let depth: Int
    let isCollapsed: Bool
    
    @EnvironmentObject var homeVM: HomeViewModel
    
    var authorText: some View {
        if comment.author == postAuthor {
            return Text(comment.author).foregroundColor(.accentColor).bold()
        } else {
            return Text(comment.author)
        }
    }
    
    var attributedCommentText: AttributedString? {
        Markdown.getAttributedString(from: comment.body)
    }

    var body: some View {
        CommentFrame(depth: depth, isCollapsed: isCollapsed) {
            VStack(alignment: .leading, spacing: Space.mini) {
                // header
                HStack(spacing: Space.small) {
                    authorText
                    HStack(spacing: Space.mini) {
                        Image(systemName: "arrow.up")
                        Text("\(comment.score)")
                    }
                }
                .font(.footnote)
                .opacity(0.75)
                
                // comment text
                if isCollapsed {
                    Text("")
                } else if let attrStr = attributedCommentText {
                    Text(attrStr)
                        .environment(\.openURL, OpenURLAction { url in
                            homeVM.showWebView(url.absoluteString)
                            return .handled
                          })
                } else {
                    Text(comment.body)
                }
            }
            .padding(.vertical, Space.small)
        }
    }
}

struct CommentView_Previews: PreviewProvider {
    static var previews: some View {
        return Group {
            CommentView(comment: Comment(id: UUID().uuidString, author: "you", score: 122, body: "A Comment", replies: nil), postAuthor: "me", depth: 0, isCollapsed: false)
                .previewLayout(.sizeThatFits)
            
            CommentView(comment: Comment(id: UUID().uuidString, author: "you", score: 76, body: "A Comment", replies: nil), postAuthor: "me", depth: 2, isCollapsed: false)
                .previewLayout(.sizeThatFits)
        }
    }
}
