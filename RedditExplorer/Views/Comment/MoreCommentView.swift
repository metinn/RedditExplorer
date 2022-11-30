//
//  MoreCommentView.swift
//  RedditExplorer
//
//  Created by Metin Guler on 31.07.22.
//

import SwiftUI

struct MoreCommentView: View {
    let count: Int
    let depth: Int
    let isLoading: Bool
    
    var body: some View {
        CommentCell(depth: depth, isCollapsed: false) {
            if isLoading {
                ProgressView()
            } else {
                Text("\(count) more comment")
                    .foregroundColor(.blue)
                    .padding(.vertical, 6)                
            }
        }
    }
}
