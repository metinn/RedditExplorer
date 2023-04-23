//
//  SubredditsPage.swift
//  RedditExplorer
//
//  Created by Metin Guler on 18.08.22.
//

import SwiftUI
import Combine

@MainActor
class SubredditsViewModel: ObservableObject {
    private var api: RedditAPIProtocol.Type = RedditAPI.self
    
    var topSubreddits = ["funny", "AskReddit", "worldnews", "todayilearned", "science", "DIY", "gifs", "videos", "pics", "memes"]
    
    @Published var subredditName: String = ""
    @Published var searchText: String = ""
    @Published var subreddits: [Subreddit] = []
    
    var cancelables: Set<AnyCancellable> = []
    
    init() {
        $searchText
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .sink { text in
                let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else {
                    withAnimation {
                        self.subreddits = []
                    }
                    return
                }
                
                print(text + " should be searched")
                Task { await self.searchSubreddits(text: trimmed) }
            }
            .store(in: &cancelables)
    }
    
    func searchSubreddits(text: String) async {
        do {
            let result = try await api.searchSubreddits(searchText: text, limit: 20)
            withAnimation {
                subreddits = result
            }
        } catch let err {
            print("Error: searchSubreddits \(err.localizedDescription)")
        }
    }
}

struct SubredditsPage: View {
    @StateObject var vm = SubredditsViewModel()
    
    var body: some View {
        ScrollView {
            LazyVStack {
                
                ForEach(vm.subreddits) { subreddit in
                    SubredditCellView(subreddit: subreddit)
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
        .searchable(text: $vm.searchText, prompt: "Search subreddits")
    }
    
    @ViewBuilder
    func listPage(_ subreddit: String) -> some View {
        PostListPage(vm: PostListViewModel(listing: .subreddit(subreddit)))
            .navigationTitle(subreddit)
    }
}

struct SubredditsPage_Previews: PreviewProvider {
    static var previews: some View {
        SubredditsPage()
    }
}
