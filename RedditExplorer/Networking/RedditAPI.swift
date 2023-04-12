//
//  RedditAPI.swift
//  RedditExplorer
//
//  Created by Metin Güler on 20.03.22.
//

import Foundation

protocol RedditAPIProtocol {
    static func getPosts(_ sortBy: SortBy, listing: ListingType, after: String?, limit: Int?) async throws -> [Post]
    static func getComments(subreddit: String, id: String, commentId: String?) async throws -> [Comment]
}

enum ListingType {
    case subreddit(String?)
    case user(String)
}

class RedditAPI: RedditAPIProtocol {
    static let baseUrl = "https://www.reddit.com"
    
    static func getPosts(_ sortBy: SortBy, listing: ListingType, after: String?, limit: Int?) async throws -> [Post] {
        // Url creation
        let params = ["raw_json": "1",
                      "after": after,
                      "limit": limit == nil ? nil : String(limit!)]
        var path = ""
        
        switch listing {
        case .subreddit(let subreddit):
            if let subreddit = subreddit {
                path += "/r/" + subreddit
            }
        case .user(let user):
            path += "/u/" + user
        }
        
        path += "/\(sortBy.rawValue).json"
        
        let url = buildUrl(path: path, params: params)

        // making call
        let (data, response) = try await URLSession.shared.data(from: url)
        
        let statusCode = (response as! HTTPURLResponse).statusCode
        guard statusCode == 200 else {
            throw NSError(domain: "Bad Status code: \(statusCode)", code: -1, userInfo: nil)
        }
        
        let wrapper = try JSONDecoder().decode(RedditObjectWrapper.self, from: data)
        guard let listing = wrapper.data as? RedditListing else {
            throw NSError(domain: "Parsing Error: data is not Listing", code: -1, userInfo: nil)
        }
        return listing.children.compactMap { $0.data as? Post }
    }
    
    static func getComments(subreddit: String, id: String, commentId: String?) async throws -> [Comment] {
        let url = buildUrl(path: "/r/\(subreddit)/comments/\(id).json", params: ["comment": commentId])
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        let statusCode = (response as! HTTPURLResponse).statusCode
        guard statusCode == 200 else {
            throw NSError(domain: "Bad Status code: \(statusCode)", code: -1, userInfo: nil)
        }
        
        let wrappers = try JSONDecoder().decode([RedditObjectWrapper].self, from: data)
        guard let commentListing = wrappers[1].data as? RedditListing else {
            throw NSError(domain: "Received object is not listing", code: -1, userInfo: nil)
        }
        return commentListing.children.compactMap { $0.data as? Comment }
    }
}

extension RedditAPI {
    private static func buildUrl(path: String, params: [String: String?]? = nil) -> URL {
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
