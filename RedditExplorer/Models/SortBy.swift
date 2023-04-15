import Foundation

enum SortBy: String, CaseIterable {
    case hot
    case new
    case controversial
    case top
    case rising
    
    // user
    case overview
    case submitted
    case comments
    case upvoted
    case downvoted
    case hidden
}
