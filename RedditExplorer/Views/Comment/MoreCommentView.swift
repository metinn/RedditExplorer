//
//  MoreCommentView.swift
//  RedditExplorer
//
//  Created by Metin Guler on 31.07.22.
//

import SwiftUI

struct MoreCommentView: View {
    let moreComment: MoreComment
    let depth: Int
    
    var body: some View {
        CommentCell(depth: depth, isCollapsed: false) {
            Text("\(moreComment.count) more comment")
                .foregroundColor(.blue)
        }
    }
}
