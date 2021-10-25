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
    @Binding var maxConnection:String
    @Binding var split:String
    @Binding var maxConcurrentDown:String
    @Binding var minBlockSize:String
    @Binding var runCount:Int
    @Binding var likeCount:Int
    var window = NSScreen.main?.visibleFrame
    var body: some View {
        VStack(alignment: .center   , spacing: 5){
            Text("当前下载目录：\(dirUrl)")
                .fontWeight(.light)
                .foregroundColor(Color("textColor").opacity(0.5))
                .frame(minWidth:0,maxWidth: .infinity,alignment:.center)
                .padding([.top, .leading], 20.0)
            URLInquiryView(minWidth: window!.width/3, sourceLogo: $sourceLogo, videoUrl: $videoUrl, runCount: $runCount, dlExcPath: $ydlExcUrl, dirUrl: $dirUrl, processManager: processManager)
            ContentScrollView(minHeight: window!.height/4, minWidth: window!.width/3, contentEntries: $consoleOutMsg, processManager: processManager)
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
                            processManager.runProcess(dlExcPath: "/usr/local/bin/youtube-dl", dlPath: dirUrl, dlArgs: arg,opMode: .download,runMode: .running)
                        }else{
                            let arg = ["--external-downloader",ariaExcUrl,"--external-downloader-args","-x \(maxConnection) -s \(split) -j \(maxConcurrentDown) -k \(minBlockSize)M","-f",videoFormat,videoUrl]
                            processManager.runProcess(dlExcPath: "/usr/local/bin/youtube-dl", dlPath: dirUrl, dlArgs: arg,opMode: .download,runMode: .running)
                        }
                    }else{
                        if videoFormat == ""{
                            let arg = [videoUrl]
                            processManager.runProcess(dlExcPath: "/usr/local/bin/youtube-dl", dlPath: dirUrl, dlArgs: arg,opMode: .download,runMode: .running)
                        }else{
                            let arg = ["-f",videoFormat,videoUrl]
                            processManager.runProcess(dlExcPath: "/usr/local/bin/youtube-dl", dlPath: dirUrl, dlArgs: arg,opMode: .download,runMode: .running)
                        }
                    }
                    runCount += 1
                    
                } label: {
                    Image(systemName: "icloud.and.arrow.down")
                }.foregroundColor(videoUrl == "" || !dirExist ? Color(.gray):Color("textColor"))
                    .padding([.leading,.trailing],5)
                    .disabled(videoUrl == "" || !dirExist)
                Toggle("使用Aria2下载加速",isOn:$useAria)

                Button {
                    if let url = URL(string: "uhelper://aria2") { //replace myapp with your app's name
                        NSWorkspace.shared.open(url)
                    }
                } label: {
                    HStack(){
                        Image(systemName: "gear")
                        Text("Aria2下载器设置")
                    }
                }
                Button {
                    NSApp.terminate(self)
                } label: {
                    Text("退出程序")
                }
            }
            .frame(minWidth:0,maxWidth: .infinity)
                .padding(.all,5)
            HStack(){
                Image(systemName: "externaldrive.badge.icloud")
                Link("项目Github仓库", destination: URL(string: "https://github.com/jdjingdian/UDownHelper")!)
                Image(systemName: "externaldrive.badge.plus")
                Link("youtube-dl仓库",destination: URL(string: "https://github.com/ytdl-org/youtube-dl")!)
                Image(systemName: "externaldrive.badge.plus")
                Link("aria2仓库",destination: URL(string: "https://github.com/aria2/aria2")!)
            }
        }.padding(.all,15)
        .onChange(of: processManager.consoleOutput){ _ in
            consoleOutMsg.append(contentData(output: processManager.consoleOutput, id: consoleOutMsg.count))
        }
        .toolbar{
            FolderSelector(fnName: "选择下载文件夹", filePath: $dirUrl, fileExist: $dirExist, isDir: true)
            FolderSelector(fnName: "选择youtube-dl路径", filePath: $ydlExcUrl,fileExist: $dlExist,isDir: false)
            FolderSelector(fnName: "选择aria2路径", filePath: $ariaExcUrl, fileExist: $ariaExist, isDir: false)
            BuyCoffeeView(likeCount: $likeCount)
                .padding(.leading,20)
//            HelpView()
            Button {
                if let url = URL(string: "uhelper://help") { //replace myapp with your app's name
                    NSWorkspace.shared.open(url)
                }
                
            } label: {
                Image(systemName: "questionmark.circle.fill")
                    .resizable()
                    .foregroundColor(.yellow)
                    .frame(width: 15, height: 15, alignment: .center)
                    .scaledToFit()
                    
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(maxConnection: .constant("1"), split: .constant("1"), maxConcurrentDown: .constant("1"), minBlockSize: .constant("1"), runCount: .constant(1), likeCount: .constant(10))
    }
}






