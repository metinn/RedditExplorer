//
//  SubredditsPage.swift
//  RedditExplorer
//
//  Created by Metin Guler on 18.08.22.
//

import SwiftUI

class SubredditsViewModel: ObservableObject {
    @Published var subredditName: String = ""
    var topSubreddits = ["funny", "AskReddit", "worldnews", "todayilearned", "science", "DIY", "gifs", "videos", "pics", "memes"]
}

struct SubredditsPage: View {
    @StateObject var vm = SubredditsViewModel()
    
    var body: some View {
        ScrollView {
            LazyVStack {
                TextField("Enter subreddit...", text: $vm.subredditName)
                    .textFieldStyle(.roundedBorder)
                    .disableAutocorrection(true)
                
                NavigationLink(destination: PostListPage(vm: PostListViewModel(sortBy: .hot, subReddit: vm.subredditName))) {
                    Text("GO")
                        .padding()
                        .background(Color.teal.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .clipped()
                }
                
                ForEach(vm.topSubreddits, id: \.self) { subreddit in
                    NavigationLink(destination: listPage(subreddit))
                    {
                        HStack {
                            Text(subreddit)
                                .padding(6)
                        }
                        Spacer()
                    }
                    .background(Color.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .clipped()
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder
    func listPage(_ subreddit: String) -> some View {
        PostListPage(vm: PostListViewModel(sortBy: .hot, subReddit: subreddit))
            .navigationTitle(subreddit)
    }
}

struct SubredditsPage_Previews: PreviewProvider {
    static var previews: some View {
        SubredditsPage()
    }
}
