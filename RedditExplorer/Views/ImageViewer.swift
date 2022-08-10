//
//  ImageViewer.swift
//  RedditExplorer
//
//  Created by Metin Guler on 10.08.22.
//

import SwiftUI

struct ImageViewer: View {
    var imageUrl: String
    @Binding var showImageViewer: Bool
    @State var imageOffset: CGSize = .zero
    @GestureState var magnifyBy = 1.0
    @State var bgOpacity: Double = 1
    
    let minDragYForClose: CGFloat = 250
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(bgOpacity)
                .ignoresSafeArea()
            
            AsyncImage(url: URL(string: imageUrl)) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .offset(imageOffset)
                    .opacity(bgOpacity)
                    .scaleEffect(magnifyBy)
            } placeholder: {
                ProgressView()
            }
        }
        .overlay(closeButton, alignment: .bottom)
        .gesture(dragging)
        .gesture(magnification)
    }
    
    var closeButton: some View {
        Button {
            withAnimation {
                showImageViewer.toggle()
            }
        } label: {
            Image(systemName: "xmark")
                .foregroundColor(.white)
                .padding()
                .background(.white.opacity(0.4))
                .clipShape(Circle())
        }
        .padding()
    }
    
    var dragging: some Gesture {
        DragGesture().onChanged({ update in
            imageOffset = update.translation
            print("DragGesture", "translating")
            
            withAnimation {
                let maxTranslation = UIScreen.main.bounds.height / 2
                let translationY = min(maxTranslation, abs(update.predictedEndTranslation.height))
                bgOpacity = (maxTranslation - translationY) / maxTranslation
            }
        }).onEnded({ end in
            withAnimation {
                if abs(end.predictedEndTranslation.height) > minDragYForClose {
                    imageOffset = end.predictedEndTranslation
                    showImageViewer = false
                    bgOpacity = 0
                } else {
                    imageOffset = .zero
                    bgOpacity = 1
                }
            }
        })
    }
    
    var magnification: some Gesture {
        MagnificationGesture()
            .updating($magnifyBy) { currentState, gestureState, transaction in
                gestureState = currentState
                print("MagnificationGesture", "updating")
            }
    }
}

struct ImageViewer_Previews: PreviewProvider {
    static var previews: some View {
        ImageViewer(imageUrl: "https://img.favpng.com/2/12/4/bird-scalable-vector-graphics-icon-png-favpng-WbMkbz0Edv7jXtG67SpdVAdkC.jpg",
                    showImageViewer: Binding<Bool>.init(get: { true }, set: { _ in }))
    }
}
