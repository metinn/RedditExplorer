//
//  RedditAPI.swift
//  RedditExplorer
//
//  Created by Metin Güler on 20.03.22.
//

import Foundation

protocol RedditAPIProtocol {
    func getHotPosts(after: String?, limit: Int?) async throws -> Listing
    func getSubReddit(subReddit: String, sortBy: SortBy) async throws -> Listing
    func getPost(subreddit: String, id: String) async throws -> [CommentListing]
}

class RedditAPI: RedditAPIProtocol {
    static let shared = RedditAPI()
    
    let baseUrl = "https://www.reddit.com"
    let components = URLComponents(string: "https://www.reddit.com")!
    
    func getHotPosts(after: String?, limit: Int?) async throws -> Listing {
        // Url creation
        let params = ["raw_json": "1",
                      "after": after,
                      "limit": limit == nil ? nil : String(limit!)]
        
        let url = buildUrl(path: "/hot.json", params: params)

        // making call
        let (data, response) = try await URLSession.shared.data(from: url)
        
        let statusCode = (response as! HTTPURLResponse).statusCode
        if statusCode != 200 {
            throw NSError(domain: "Bad Status code: \(statusCode)", code: -1, userInfo: nil)
        }
        
        return try JSONDecoder().decode(Listing.self, from: data)
    }
    
    func getSubReddit(subReddit: String, sortBy: SortBy) async throws -> Listing {
        let url = buildUrl(path: "/r/\(subReddit)/\(sortBy.rawValue).json", params: ["raw_json": "1"])
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        let statusCode = (response as! HTTPURLResponse).statusCode
        if statusCode != 200 {
            throw NSError(domain: "Bad Status code: \(statusCode)", code: -1, userInfo: nil)
        }
        
        return try JSONDecoder().decode(Listing.self, from: data)
    }
    
    func getPost(subreddit: String, id: String) async throws -> [CommentListing] {
        let url = buildUrl(path: "/r/\(subreddit)/\(id).json")
        let (data, response) = try await URLSession.shared.data(from: url)
        
        let statusCode = (response as! HTTPURLResponse).statusCode
        if statusCode != 200 {
            throw NSError(domain: "Bad Status code: \(statusCode)", code: -1, userInfo: nil)
        }
        
        return try JSONDecoder().decode([CommentListing].self, from: data)
    }
}

extension RedditAPI {
    private func buildUrl(path: String, params: [String: String?]? = nil) -> URL {
        var urlComp = URLComponents(string: baseUrl + path)!
        
        if let params = params {
            var queryItems = [URLQueryItem]()
            for (k, v) in params {
                if v != nil {
                    queryItems.append(URLQueryItem(name: k, value: v))
                }
            }
            urlComp.queryItems = queryItems
        }
        
        return urlComp.url!
    }
}
