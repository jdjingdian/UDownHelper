//
//  ProcessHelper.swift
//  UDown Helper
//
//  Created by Derek Jing on 2021/10/22.
//

import Foundation
import Cocoa
import Combine

class ProcessHelper: ObservableObject{
    let globalQueue = DispatchQueue.global()
    @Published var consoleOutput:[String] = [""]
    func runProcess(dlExcPath:String,dlPath:String,dlArgs:[String]){
        globalQueue.async {
            let task = Process()
            
            //the path to the external program you want to run
            let executableURL = URL(fileURLWithPath: "/usr/local/bin/youtube-dl")
            task.executableURL = executableURL
            
            //use pipe to get the execution program's output
            let pipe = Pipe()
            task.standardOutput = pipe
            let outHandle = pipe.fileHandleForReading
            
            //this one helps set the directory the executable operates from
            task.currentDirectoryURL = URL(fileURLWithPath: (NSString(string:"~/Downloads").expandingTildeInPath))
            
            //all the arguments to the executable
            task.arguments = dlArgs
            print(dlArgs)
            
            //what to call once the process completes
            task.terminationHandler = {
                _ in
                print("process run complete.")
            }
            
            
            
            //all this code helps you capture the output so you can, for e.g., show the user
            
            DispatchQueue.main.async {
                outHandle.readabilityHandler = { pipe in
                    print("pipe:\(pipe)")
                    let line = String(data: pipe.availableData,encoding: .utf8)
                    DispatchQueue.main.async {
                        self.consoleOutput.append(line ?? "nil output")
                    }
                    
                }
            }
            
            do{
                try task.run()
            }catch{
                print("运行错误")
            }
            task.waitUntilExit()//关闭这个之后无法接受到实时信息
        }
    }
}
