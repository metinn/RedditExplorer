//
//  IfCondition.swift
//  RedditExplorer
//
//  Created by Metin Guler on 13.08.22.
//

import SwiftUI

extension View {
    @ViewBuilder
    func ifCondition<TrueContent: View>(_ condition: Bool, then trueContent: (Self) -> TrueContent) -> some View {
        if condition {
            trueContent(self)
        } else {
            self
        }
    }
}
