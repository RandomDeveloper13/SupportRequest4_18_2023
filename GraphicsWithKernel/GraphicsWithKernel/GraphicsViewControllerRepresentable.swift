//
//  GraphicsViewControllerRepresentable.swift
//  Graphics
//
//  Created by Landon Teeter on 3/21/23.
//

import SwiftUI

struct GraphicsView : UIViewControllerRepresentable{
    func makeUIViewController(context: Context) -> GraphicsViewController {
        return GraphicsViewController()
    }

    func updateUIViewController(_ uiViewController: GraphicsViewController, context: Context) {
        //code
    }
}
