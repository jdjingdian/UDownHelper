//
//  FolderSelectorView.swift
//  UDown Helper
//
//  Created by Derek Jing on 2021/10/23.
//

import Foundation
import SwiftUI

struct FolderSelector:View {
    var fnName: String
    @Binding var filePath: String
    @Binding var fileExist:Bool
    var isDir:Bool
    let fileManager = FileManager.default
    
    var body: some View {
        HStack(){
            Button(fnName){
                let panel = NSOpenPanel()
                panel.allowsMultipleSelection = false
                panel.canChooseDirectories = isDir ? true:false
                panel.canChooseFiles = isDir ? false:true
                panel.directoryURL = URL(string: filePath) //设置默认打开文件路径为用户下载路径
                if panel.runModal() == .OK {
                    filePath = panel.url?.path ?? "~/Downloads"
                    if fileManager.fileExists(atPath: filePath){
                        if isDir{
                            if fileManager.isWritableFile(atPath: filePath){
                                fileExist = true
                                
                            }else{
                                fileExist = false
                            }
                        }else{
                            fileExist = true
                        }
                    }else{
                        fileExist = true
                    }
                    
                }
                
                print(filePath)
            }.foregroundColor(Color("textColor"))
            if fileExist{
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                
            }else{
                Image(systemName: "x.circle.fill")
                    .foregroundColor(.red)
            }
        }.onAppear {
            if fileManager.fileExists(atPath: filePath){
                if isDir{
                    if fileManager.isWritableFile(atPath: filePath){
                        fileExist = true
                    }else{
                        fileExist = false
                    }
                }else{
                    fileExist = true
                }
                
                
            }else{
                fileExist = false
            }
        }
        
    }
}

