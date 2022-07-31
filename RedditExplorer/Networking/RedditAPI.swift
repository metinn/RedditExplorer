//
//  RedditAPI.swift
//  RedditExplorer
//
//  Created by Metin Güler on 20.03.22.
//

import Foundation
import SwiftyJSON

protocol RedditAPIProtocol {
    func getHotPosts(after: String?, limit: Int?) async throws -> Listing
    func getComments(subreddit: String, id: String, commentId: String?) async throws -> [Comment]
}

class RedditAPI: RedditAPIProtocol {
    static let shared = RedditAPI()
    
    let baseUrl = "https://www.reddit.com"
    
    func getHotPosts(after: String?, limit: Int?) async throws -> Listing {
        // Url creation
        let params = ["raw_json": "1",
                      "after": after,
                      "limit": limit == nil ? nil : String(limit!)]
        
        let url = buildUrl(path: "/hot.json", params: params)

        // making call
        let (data, response) = try await URLSession.shared.data(from: url)
        
        let statusCode = (response as! HTTPURLResponse).statusCode
        guard statusCode == 200 else {
            throw NSError(domain: "Bad Status code: \(statusCode)", code: -1, userInfo: nil)
        }
        
        return try JSONDecoder().decode(Listing.self, from: data)
    }
    
    func getComments(subreddit: String, id: String, commentId: String?) async throws -> [Comment] {
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
