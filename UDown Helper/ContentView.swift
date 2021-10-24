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
    @AppStorage("dirUrl") var dirUrl:String = NSString(string:"~/Downloads").expandingTildeInPath
    @AppStorage("ydlExcUrl") var ydlExcUrl:String = "/usr/local/bin/youtube-dl"
    @AppStorage("ariaExcUrl") var ariaExcUrl:String = "/usr/local/bin/aria2c"
    @State var videoUrl = ""
    @State var videoFormat = ""
    @State var combineUrl = ""
    @State var cOut = ""
    @State var consoleOutMsg = [contentData]()
    @State var sourceLogo = Image(systemName: "play.tv.fill")
    @State var dirExist = false
    @State var dlExist = false
    @State var ariaExist = false
    @AppStorage("useAria") var useAria = false
    @AppStorage("maxConnection") var maxConnection = "16"
    @AppStorage("split") var split = "16"
    @AppStorage("maxConnection") var maxConcurrentDown = "8"
    @AppStorage("minBlockSize") var minBlockSize = "1"
    var window = NSScreen.main?.visibleFrame
    var body: some View {
        VStack(alignment: .leading, spacing: 5){
            HStack(){
                FolderSelector(fnName: "选择输出文件夹", filePath: $dirUrl, fileExist: $dirExist, isDir: true)
                FolderSelector(fnName: "选择youtube-dl路径", filePath: $ydlExcUrl,fileExist: $dlExist,isDir: false)
                FolderSelector(fnName: "选择aria2路径", filePath: $ariaExcUrl, fileExist: $ariaExist, isDir: false)
                Text("当前下载目录：\(dirUrl)")
                    .fontWeight(.bold)
                
            }
            .padding([.top, .leading], 10.0)
            HStack(){
                sourceLogo
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25, alignment: .center)
                TextField("请输入视频链接",text: $videoUrl)
                    .cornerRadius(40)
                    .onChange(of: videoUrl) { _ in
                        if videoUrl.contains("bilibili") {
                            sourceLogo = Image("bilibili")
                        }else if videoUrl.contains("youtube"){
                            sourceLogo = Image("youtube")
                            
                        }else if videoUrl.contains("porn"){
                            sourceLogo = Image("porn")
                        }else if videoUrl.contains("iqiyi"){
                            sourceLogo = Image("iqiyi")
                        }else if videoUrl.contains("youku"){
                            sourceLogo = Image("youku")
                        }
                        else{
                            sourceLogo = Image(systemName: "play.tv.fill")
                        }
                    }
                Button {
                    let arg = ["-F",videoUrl]
                    processManager.runProcess(dlExcPath: "/usr/local/bin/youtube-dl", dlPath: dirUrl, dlArgs: arg)
                } label: {
                    Image(systemName: "magnifyingglass.circle")
                }.foregroundColor(videoUrl == "" ? Color(.gray):Color("textColor"))
                    .padding([.leading,.trailing],5)
                    .disabled(videoUrl == "")

            }.frame(width: window!.width/2)
                .padding(.all,10)
            
            ContentScrollView(contentHeight: window!.height/3, contentWeight: window!.width/2, contentEntries: $consoleOutMsg)
            
            HStack(){
                TextField("留空使用默认格式",text: $videoFormat)
                    .onReceive(Just(videoFormat)) { newValue in //只允许输入数字
                        let filtered = newValue.filter { "0123456789.".contains($0) }
                        if filtered != newValue {
                            self.videoFormat = filtered
                        }
                    }
                    .frame(width: 120,alignment: .trailing)
                    .cornerRadius(40)
                
                Button {
                    
                    if useAria{
                        if videoFormat == ""{
                            let arg = ["--external-downloader",ariaExcUrl,"--external-downloader-args","-x \(maxConnection) -s \(split) -j \(maxConcurrentDown) -k \(minBlockSize)M",videoUrl]
                            processManager.runProcess(dlExcPath: "/usr/local/bin/youtube-dl", dlPath: dirUrl, dlArgs: arg)
                        }else{
                            let arg = ["--external-downloader",ariaExcUrl,"--external-downloader-args","-x \(maxConnection) -s \(split) -j \(maxConcurrentDown) -k \(minBlockSize)M","-f",videoFormat,videoUrl]
                            processManager.runProcess(dlExcPath: "/usr/local/bin/youtube-dl", dlPath: dirUrl, dlArgs: arg)
                        }
                    }else{
                        if videoFormat == ""{
                            let arg = [videoUrl]
                            processManager.runProcess(dlExcPath: "/usr/local/bin/youtube-dl", dlPath: dirUrl, dlArgs: arg)
                        }else{
                            let arg = ["-f",videoFormat,videoUrl]
                            processManager.runProcess(dlExcPath: "/usr/local/bin/youtube-dl", dlPath: dirUrl, dlArgs: arg)
                        }
                    }
                    
                } label: {
                    Image(systemName: "icloud.and.arrow.down")
                }.foregroundColor(videoUrl == "" || !dirExist ? Color(.gray):Color("textColor"))
                    .padding([.leading,.trailing],5)
                    .disabled(videoUrl == "" || !dirExist)
                Toggle("使用Aria2下载加速",isOn:$useAria)

                Button {
                    let aSetView = Aria2SettingView(maxConnection: $maxConnection, split: $split, maxConcurrentDown: $maxConcurrentDown, minBlockSize: $minBlockSize)
                    let controller = DetailWC(rootView: aSetView)
                    controller.window?.title = "Aria2设置"
                    controller.showWindow(nil)
                } label: {
                    HStack(){
                        Image(systemName: "gear")
                        Text("Aria2下载器设置")
                    }
                }


                
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

