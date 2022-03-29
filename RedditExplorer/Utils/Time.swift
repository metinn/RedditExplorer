//
//  Time.swift
//  RedditExplorer
//
//  Created by Metin Güler on 25.04.22.
//

import Foundation

func timeSince(_ interval: TimeInterval) -> String {
    let formatter = RelativeDateTimeFormatter()
    return formatter.localizedString(for: Date(timeIntervalSince1970: interval), relativeTo: Date())
}
