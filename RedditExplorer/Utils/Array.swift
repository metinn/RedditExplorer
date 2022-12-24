//
//  Array.swift
//  RedditExplorer
//
//  Created by Metin Güler on 21.12.22.
//

import Foundation

extension Array {
    var middle: Element? {
        guard count != 0 else { return nil }
        return self[count / 2]
    }
}
