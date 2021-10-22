//
//  ContentView.swift
//  UDown Helper
//
//  Created by Derek Jing on 2021/10/22.
//

import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject var processManager = ProcessHelper()
    @State var dirUrl = "~/Downloads"
    @State var videoUrl = ""
    @State var videoFormat = ""
    @State var combineUrl = ""
    @State var cOut = ""
    @State var consoleOutMsg = [contentData]()
    var window = NSScreen.main?.visibleFrame
    var body: some View {
        VStack(alignment: .leading, spacing: 5){
            FolderSelector(folderUrl: $dirUrl, isDir: true)
                .padding([.top, .leading], 10.0)
            HStack(){
                TextField("请输入视频链接",text: $videoUrl)
                    .cornerRadius(40)
                Button("查询视频信息"){
                    let arg = ["-F",videoUrl]
                    processManager.runProcess(dlExcPath: "/usr/local/bin/youtube-dl", dlPath: dirUrl, dlArgs: arg)
                }.foregroundColor(Color("textColor"))
                    .padding([.leading,.trailing],5)
            }.frame(width: window!.width/2)
                .padding(.all,10)
            
            ContentScrollView(contentHeight: window!.height/3, contentWeight: window!.width/2, contentEntries: $consoleOutMsg)
            
            HStack(){
                TextField("视频格式",text: $videoFormat)
                    .onReceive(Just(videoFormat)) { newValue in //只允许输入数字
                        let filtered = newValue.filter { "0123456789.".contains($0) }
                        if filtered != newValue {
                            self.videoFormat = filtered
                        }
                    }
                    .frame(width: 100,alignment: .trailing)
                    .cornerRadius(40)
                Button("开始下载"){
                    let arg = ["-f",videoFormat,videoUrl]
                    processManager.runProcess(dlExcPath: "/usr/local/bin/youtube-dl", dlPath: dirUrl, dlArgs: arg)
                }.foregroundColor(Color("textColor"))
                    .padding([.leading,.trailing],5)
            }.frame(width: window!.width/2)
                .padding(.all,20)
            //        }.preferredColorScheme(.light)
        }.onChange(of: processManager.consoleOutput){ _ in
            consoleOutMsg.append(contentData(output: processManager.consoleOutput, id: consoleOutMsg.count))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct FolderSelector:View {
    @Binding var folderUrl: String
    var isDir:Bool
    var body: some View {
        Button("选择输出文件夹"){
            let panel = NSOpenPanel()
            panel.allowsMultipleSelection = false
            panel.canChooseDirectories = isDir ? true:false
            panel.canChooseFiles = isDir ? false:true
            panel.directoryURL = URL(string: "~/Downloads") //设置默认打开文件路径为用户下载路径
            if panel.runModal() == .OK {
                folderUrl = panel.url?.path ?? "~/Downloads"
            }
            //            print(folderUrl)
        }.foregroundColor(Color("textColor"))
    }
}
