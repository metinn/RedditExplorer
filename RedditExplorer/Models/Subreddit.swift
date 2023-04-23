//
//  Subreddit.swift
//  RedditExplorer
//
//  Created by Metin Güler on 16.04.23.
//

import Foundation

struct Subreddit: RedditObject, Identifiable {
    var id: String
    var display_name: String
    var title: String
    var public_description: String
    var community_icon: String
    
    var iconUrl: URL? {
        var url = URLComponents(string: community_icon)
        url?.query = nil
        return url?.url
    }
}
