//
//  WebView.swift
//  RedditExplorer
//
//  Created by Metin Güler on 09.08.22.
//

import SwiftUI
import WebKit
import SafariServices
 
struct WebView: UIViewControllerRepresentable {
    typealias UIViewControllerType = SFSafariViewController

    var url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<WebView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ safariViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<WebView>) {
    }
}

#if DEBUG
struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        WebView(url: URL(string: "https://reddit.com")!)
    }
}
#endif
