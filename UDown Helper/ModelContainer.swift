//
//  ModelContainer.swift
//  UDown Helper
//
//  Created by Derek Jing on 2021/10/22.
//

import Foundation
import SwiftUI
import Cocoa

struct contentData:Hashable{
    var output: String
    var id: Int
}

class DetailWC<RootView : View>: NSWindowController {
    convenience init(rootView: RootView) {
        let hostingController = NSHostingController(rootView: rootView.frame(width: 250, height: 200))
        let window = NSWindow(contentViewController: hostingController)
        window.setContentSize(NSSize(width: 250, height: 200))
        self.init(window: window)
    }
}
