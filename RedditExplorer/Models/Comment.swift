//
//  Comment.swift
//  Reddit
//
//  Created by Carson Katri on 7/27/19.
//  Copyright © 2019 Carson Katri. All rights reserved.
//

import Foundation

struct Comment: RedditObject {
    let id: String
    let author: String
    let score: Int
    let body: String
    let replies: RedditObjectWrapper?

    init(id: String, author: String, score: Int, body: String, replies: RedditObjectWrapper?) {
        self.id = id
        self.author = author
        self.score = score
        self.body = body
        self.replies = replies
    }
    
    enum CommentKeys: String, CodingKey {
        case id
        case author
        case score
        case body
        case replies
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CommentKeys.self)
        id = try values.decode(String.self, forKey: .id)
        author = try values.decode(String.self, forKey: .author)
        score = try values.decode(Int.self, forKey: .score)
        body = try values.decode(String.self, forKey: .body)
        
        if let replies = try? values.decode(RedditObjectWrapper.self, forKey: .replies) {
            self.replies = replies
        } else {
            replies = nil
        }
    }
}
