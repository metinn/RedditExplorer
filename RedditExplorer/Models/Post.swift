//
//  Post.swift
//  Reddit
//
//  Created by Carson Katri on 7/21/19.
//  Copyright © 2019 Carson Katri. All rights reserved.
//

import Foundation

struct Post: RedditObject {
    let id: String
    var title: String
    let name: String
    let selftext: String
    let selftext_html: String?
    let thumbnail: String
    let url: String
    let author: String
    let subreddit: String
    let subreddit_name_prefixed: String
    let ups: Int
    let upvote_ratio: Float
    let num_comments: Int
    let stickied: Bool
    let created_utc: Double
    let preview: Preview?
    
    let link_flair_text: String?
    let is_original_content: Bool
    let spoiler: Bool
    
    var flairs: [String] {
        var res: [String] = []
        if link_flair_text != nil {
            res.append(link_flair_text!)
        }
        if is_original_content {
            res.append("OC")
        }
        if spoiler {
            res.append("Spoiler")
        }
        return res
    }
    
    let replies: [Self]?
    
    struct Preview: Decodable {
        let images: [PreviewImage]
        let enabled: Bool
        
        struct PreviewImage: Decodable {
            let source: ImageSource
            let resolutions: [ImageSource]
            let id: String
            
            struct ImageSource: Decodable {
                let url: String
                let width: Int
                let height: Int
            }
        }
    }
}

#if DEBUG

func samplePost() -> Post {
    return Post(id: "1", title: "Post Title", name: "Author 1", selftext: "", selftext_html: nil, thumbnail: "", url: "", author: "", subreddit: "", subreddit_name_prefixed: "r/tifu", ups: 132, upvote_ratio: 0.87, num_comments: 0, stickied: false, created_utc: 0, preview: nil, link_flair_text: nil, is_original_content: false, spoiler: false, replies: nil)
}

#endif
