//
//  ImageViewer.swift
//  RedditExplorer
//
//  Created by Metin Guler on 10.08.22.
//

import SwiftUI
import PDFKit

extension CGSize {
    func divide(_ scale: CGFloat) -> CGSize {
        CGSize(width: width / scale, height: height / scale)
    }
    func add(_ toAdd: CGSize) -> CGSize {
        CGSize(width: width + toAdd.width, height: height + toAdd.height)
    }
}

struct ImageViewer: View {
    var imageUrl: String
    @Binding var showImageViewer: Bool
    
    // drag gesture
    @State var lastOffset: CGSize = .zero
    @State var currentOffset: CGSize = .zero
    var offset: CGSize {
        currentOffset.add(lastOffset)
            .divide(scale)
    }
    
    // magnify gesture
    @State var lastScale: CGFloat = 1
    @GestureState var currentScale: CGFloat = 1
    var scale: CGFloat {
        currentScale * lastScale
    }
    
    // dismiss animation
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
                    .opacity(bgOpacity)
                    .offset(offset)
                    .scaleEffect(scale)
            } placeholder: {
                ProgressView()
            }
        }
        .overlay(closeButton, alignment: .bottom)
        .gesture(dragging)
        .gesture(magnification)
        .onTapGesture(count: 2) {
            withAnimation(.spring()) {
                if scale == 1 {
                    lastScale = 3
                } else {
                    lastScale = 1
                    lastOffset = .zero
                    currentOffset = .zero
                }
            }
        }
    }
    
    var closeButton: some View {
        Button {
            withAnimation {
                showImageViewer.toggle()
                bgOpacity = 0
            }
        } label: {
            Image(systemName: "xmark")
                .foregroundColor(.white)
                .padding()
                .background(.gray.opacity(0.5))
                .clipShape(Circle())
        }
        .padding()
    }
    
    var dragging: some Gesture {
        DragGesture().onChanged({ update in
            currentOffset = update.translation
            
            // do dismiss animation only when not zoomed
            guard scale <= 1 else { return }
            withAnimation {
                let maxTranslation = UIScreen.main.bounds.height / 2
                let translationY = min(maxTranslation, abs(update.predictedEndTranslation.height))
                bgOpacity = (maxTranslation - translationY) / maxTranslation
            }
        }).onEnded({ end in
            lastOffset = lastOffset.add(end.translation)
            currentOffset = .zero
            
            // do dismiss animation only when not zoomed
            guard scale <= 1 else { return }
            withAnimation {
                if abs(end.predictedEndTranslation.height) > minDragYForClose {
                    currentOffset = end.predictedEndTranslation
                    showImageViewer = false
                    bgOpacity = 0
                } else {
                    bgOpacity = 1
                }
            }
        })
    }
    
    var magnification: some Gesture {
        MagnificationGesture()
            .updating($currentScale) { currentState, gestureState, _ in
                gestureState = currentState
            }
            .onEnded { scale in
                lastScale = max(lastScale * scale, 1)
            }
    }
}

struct ImageViewer_Previews: PreviewProvider {
    static var previews: some View {
        ImageViewer(imageUrl: "https://img.favpng.com/2/12/4/bird-scalable-vector-graphics-icon-png-favpng-WbMkbz0Edv7jXtG67SpdVAdkC.jpg",
                    showImageViewer: Binding<Bool>.init(get: { true }, set: { _ in }))
    }
}
