//
//  MoreComment.swift
//  RedditExplorer
//
//  Created by Metin Guler on 31.07.22.
//

import Foundation

struct MoreComment: RedditObject {
    let id: String
    let count: Int
    let children: [String]
    
    func nextId(_ comments: [Comment]) -> String? {
        return children.first { cid in
            !comments.contains(where: { cid == $0.id })
        }
    }
}
