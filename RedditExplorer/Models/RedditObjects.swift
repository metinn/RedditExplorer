//
//  RedditObjects.swift
//  RedditExplorer
//
//  Created by Metin Guler on 31.07.22.
//

import Foundation

enum RedditObjectType: String, Decodable {
    case listing = "Listing"
    case comment = "t1"
    case link = "t3"
    case moreComment = "more"
}

protocol RedditObject: Decodable {
    var id: String { get }
}

struct RedditListing: RedditObject {
    var id: String { UUID().uuidString }
    let children: [RedditObjectWrapper]
}

struct RedditObjectWrapper: Decodable {
    var kind: RedditObjectType
    var data: RedditObject
    
    enum CommentKeys: String, CodingKey {
        case kind
        case data
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CommentKeys.self)
        kind = try values.decode(RedditObjectType.self, forKey: .kind)
        
        switch kind {
        case .comment:
            data = try values.decode(Comment.self, forKey: .data)
        case .moreComment:
            data = try values.decode(MoreComment.self, forKey: .data)
        case .listing:
            data = try values.decode(RedditListing.self, forKey: .data)
        case .link:
            // TODO: implement
            data = RedditListing(children: [])
        }
    }
}
