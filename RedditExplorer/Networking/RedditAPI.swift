//
//  RedditAPI.swift
//  RedditExplorer
//
//  Created by Metin Güler on 20.03.22.
//

import Foundation

protocol RedditAPIProtocol {
    func getSubReddit(subReddit: String, sortBy: SortBy) async throws -> Listing
    func getHotPosts() async throws -> Listing
    func getPost(subreddit: String, id: String) async throws -> [CommentListing]
}

class RedditAPI: RedditAPIProtocol {
    static let shared = RedditAPI()
    
    let baseUrl = "https://www.reddit.com"
    
    func getSubReddit(subReddit: String, sortBy: SortBy) async throws -> Listing {
        let url = URL(string: "\(baseUrl)/r/\(subReddit)/\(sortBy.rawValue).json?raw_json=1")!
        let (data, response) = try await URLSession.shared.data(from: url)
        
        let statusCode = (response as! HTTPURLResponse).statusCode
        if statusCode != 200 {
            throw NSError(domain: "Bad Status code: \(statusCode)", code: -1, userInfo: nil)
        }
        
        return try JSONDecoder().decode(Listing.self, from: data)
    }
    
    func getHotPosts() async throws -> Listing {
        let url = URL(string: "\(baseUrl)/hot.json?raw_json=1")!
        let (data, response) = try await URLSession.shared.data(from: url)
        
        let statusCode = (response as! HTTPURLResponse).statusCode
        if statusCode != 200 {
            throw NSError(domain: "Bad Status code: \(statusCode)", code: -1, userInfo: nil)
        }
        
        return try JSONDecoder().decode(Listing.self, from: data)
    }
    
    func getPost(subreddit: String, id: String) async throws -> [CommentListing] {
        let url = URL(string: "\(baseUrl)/r/\(subreddit)/\(id).json")!
        let (data, response) = try await URLSession.shared.data(from: url)
        
        let statusCode = (response as! HTTPURLResponse).statusCode
        if statusCode != 200 {
            throw NSError(domain: "Bad Status code: \(statusCode)", code: -1, userInfo: nil)
        }
        
        return try JSONDecoder().decode([CommentListing].self, from: data)
    }
}
