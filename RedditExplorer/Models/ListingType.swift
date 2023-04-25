import Foundation

enum ListingType {
    case subreddit(String?)
    case user(String)
    
    var sortingOptions: [SortBy] {
        switch self {
        case .subreddit(_):
            return [.top, .hot, .rising, .controversial, .new]
        case .user(_):
            return [.submitted]
            // TODO: .comments, .upvoted, .downvoted not working
        }
    }
}
