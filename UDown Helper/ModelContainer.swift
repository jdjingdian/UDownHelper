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

enum TaskType:String {
    case inquire = "inquiry"
    case download = "download"
}

enum RunningType {
    case running
    case complete
    case acciStop
}

struct taskTrack:Hashable{
    var process:Process
    var taskType:TaskType
    var runningType:RunningType
    var index:Int
    var isHide:Bool = false
    var highlight:Bool = false
}

struct contentVars {
    var videoUrl:String = ""
    var videoFormat:String = ""
    var combineUrl:String = ""
    var cOut:String = ""
    var consoleOutMsg = [contentData]()
    var sourceLogo:Image = Image(systemName: "play.tv.fill")
    var dirExist:Bool = false
    var dlExist:Bool = false
    var ariaExist:Bool = false
}

