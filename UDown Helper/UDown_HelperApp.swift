//
//  UDown_HelperApp.swift
//  UDown Helper
//
//  Created by Derek Jing on 2021/10/22.
//

import SwiftUI

@main
struct UDown_HelperApp: App {
    @AppStorage("runCount") var runCount:Int = 0
    @AppStorage("maxConnection") var maxConnection = "16"
    @AppStorage("split") var split = "16"
    @AppStorage("maxConcurrentDown") var maxConcurrentDown = "8"
    @AppStorage("minBlockSize") var minBlockSize = "1"
    @AppStorage("likeCount") var likeCount:Int = 0
    var version = "v1.0.0"
    var body: some Scene {
        WindowGroup {
            ContentView(maxConnection: $maxConnection, split: $split, maxConcurrentDown: $maxConcurrentDown, minBlockSize: $minBlockSize, runCount: $runCount, likeCount: $likeCount)
                .navigationTitle("典の视频下载小助手")
                .navigationSubtitle("\(version)")
        }.windowToolbarStyle(UnifiedWindowToolbarStyle())
        WindowGroup("谢谢老板~") {
            BuyCoffeeSubview(runCount: $runCount, likeCount: $likeCount)
        }.handlesExternalEvents(matching: Set(arrayLiteral: "like"))
        WindowGroup("Aria2下载器设置") {
            Aria2SettingView(maxConnection: $maxConnection, split: $split, maxConcurrentDown: $maxConcurrentDown, minBlockSize: $minBlockSize)
        }.handlesExternalEvents(matching: Set(arrayLiteral: "aria2"))
        WindowGroup("Aria2下载器设置") {
            HelpView()
        }.handlesExternalEvents(matching: Set(arrayLiteral: "help"))
    }
}
