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
    let globalQueue = DispatchQueue.global() //设置后台并行队列
    @Published var consoleOutput = ""
    @Published var taskStack:[taskTrack] = []
    
    func getSubstring(_ path: String) -> String {
        if let firstIndex = path.lastIndex(of: "/") {
            let index:Int = path.distance(from: path.startIndex, to: firstIndex)
            let strIndex = path.index(path.startIndex, offsetBy: index)
            print("index：\(index)")
            let outputPath = String(path[..<strIndex])
            print("convertedPath:\(outputPath)")
            return outputPath
        }else{
            print("not found")
            return path
        }
    }
    
    
    func runProcess(dlExcPath:String,dlPath:String,dlArgs:[String],opMode:TaskType,runMode:RunningType,ariaExcUrl:String?=nil){
        let index = self.taskStack.count
        
        self.taskStack.append(taskTrack.init(process: Process(), taskType: .inquire, runningType: .running, index: index))
        var environment =  ProcessInfo.processInfo.environment
        
        
        let dlEnvPath = getSubstring(dlExcPath)
        if ariaExcUrl == nil {
            environment["PATH"] = dlEnvPath
        }else{
            let ariaEnvPath = getSubstring(ariaExcUrl!)

            if dlEnvPath == ariaEnvPath {
                environment["PATH"] = dlEnvPath
            }else{
                environment["PATH"] = "\(dlEnvPath):\(ariaEnvPath)"
            }
        }
        
        print("PATH:\(environment["PATH"] ?? "")")
        self.taskStack[index].process.environment = environment
        
        //the path to the external program you want to run
        let executableURL = URL(fileURLWithPath: dlExcPath)
        self.taskStack[index].process.executableURL = executableURL
        
        //use pipe to get the execution program's output
        let pipe = Pipe()
        self.taskStack[index].process.standardOutput = pipe
        let outHandle = pipe.fileHandleForReading
        
        //this one helps set the directory the executable operates from
        self.taskStack[index].process.currentDirectoryURL = URL(fileURLWithPath: dlPath)
        
        //all the arguments to the executable
        self.taskStack[index].process.arguments = dlArgs
        print(dlArgs)
        
        //what to call once the process completes
        self.taskStack[index].process.terminationHandler = {
            _ in
            print("process run complete.")
            DispatchQueue.main.async {
                
                if self.taskStack[index].runningType == .acciStop{
                    print("手动停止")
                }else{
                    self.taskStack[index].runningType = .complete
                }
            }
        }
        
        
        
        //all this code helps you capture the output so you can, for e.g., show the user
        
        DispatchQueue.main.async {
            self.taskStack[index].runningType = runMode
            self.taskStack[index].taskType = opMode
            outHandle.readabilityHandler = { pipe in
                let line = String(data: pipe.availableData,encoding: .utf8)
                if self.taskStack[index].process.isRunning {
                    DispatchQueue.main.async {
                        self.consoleOutput = line ?? "nil output"
                    }
                }else{
                    outHandle.readabilityHandler = nil
                }
                
                
            }
        }
        globalQueue.async {
            do{
                try self.taskStack[index].process.run()
            }catch{
                print("运行错误")
            }
        }
        
        self.taskStack[index].process.waitUntilExit()//关闭这个之后无法接受到实时信息
        
    }
}
