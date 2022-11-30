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
    let parent_id: String
    let children: [String]
}
