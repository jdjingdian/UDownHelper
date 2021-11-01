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
    @AppStorage("useAria") var useAria = false
    @Binding var maxConnection:String
    @Binding var split:String
    @Binding var maxConcurrentDown:String
    @Binding var minBlockSize:String
    @Binding var runCount:Int
    @Binding var likeCount:Int
    @State var viewVars = contentVars()
    var window = NSScreen.main?.visibleFrame
    var body: some View {
        VStack(alignment: .center   , spacing: 5){
            Text("Current Directory: \(dirUrl)")
                .fontWeight(.light)
                .foregroundColor(Color("textColor").opacity(0.5))
                .frame(minWidth:0,maxWidth: .infinity,alignment:.center)
                .padding([.top, .leading], 20.0)
            URLInquiryView(minWidth: window!.width/3, sourceLogo: $viewVars.sourceLogo, videoUrl: $viewVars.videoUrl, runCount: $runCount, dlExcPath: $ydlExcUrl, dirUrl: $dirUrl, processManager: processManager)
            ContentScrollView(minHeight: window!.height/4, minWidth: window!.width/3, contentEntries: $viewVars.consoleOutMsg, processManager: processManager)
            HStack(){
                TextField("Leave blank to use the default format",text: $viewVars.videoFormat)
                    .onReceive(Just(viewVars.videoFormat)) { newValue in //只允许输入数字
                        let filtered = newValue.filter { "0123456789.".contains($0) }
                        if filtered != newValue {
                            self.viewVars.videoFormat = filtered
                        }
                    }
                    .frame(minWidth: 120,maxWidth:250,alignment: .trailing)
                    .cornerRadius(40)
                
                Button {
                    
                    if useAria{
                        if viewVars.videoFormat == ""{
                            let arg = ["--external-downloader",ariaExcUrl,"--external-downloader-args","-x \(maxConnection) -s \(split) -j \(maxConcurrentDown) -k \(minBlockSize)M",viewVars.videoUrl]
                            processManager.runProcess(dlExcPath: "/usr/local/bin/youtube-dl", dlPath: dirUrl, dlArgs: arg,opMode: .download,runMode: .running, ariaExcUrl: ariaExcUrl)
                        }else{
                            let arg = ["--external-downloader",ariaExcUrl,"--external-downloader-args","-x \(maxConnection) -s \(split) -j \(maxConcurrentDown) -k \(minBlockSize)M","-f",viewVars.videoFormat,viewVars.videoUrl]
                            processManager.runProcess(dlExcPath: "/usr/local/bin/youtube-dl", dlPath: dirUrl, dlArgs: arg,opMode: .download,runMode: .running, ariaExcUrl: ariaExcUrl)
                        }
                    }else{
                        if viewVars.videoFormat == ""{
                            let arg = [viewVars.videoUrl]
                            processManager.runProcess(dlExcPath: "/usr/local/bin/youtube-dl", dlPath: dirUrl, dlArgs: arg,opMode: .download,runMode: .running, ariaExcUrl: ariaExcUrl)
                        }else{
                            let arg = ["-f",viewVars.videoFormat,viewVars.videoUrl]
                            processManager.runProcess(dlExcPath: "/usr/local/bin/youtube-dl", dlPath: dirUrl, dlArgs: arg,opMode: .download,runMode: .running, ariaExcUrl: ariaExcUrl)
                        }
                    }
                    runCount += 1
                    
                } label: {
                    Image(systemName: "icloud.and.arrow.down")
                }.foregroundColor(viewVars.videoUrl == "" || !viewVars.dirExist ? Color(.gray):Color("textColor"))
                    .padding([.leading,.trailing],5)
                    .disabled(viewVars.videoUrl == "" || !viewVars.dirExist)
                Toggle("Use Aria2",isOn:$useAria)

                Button {
                    if let url = URL(string: "uhelper://aria2") { //replace myapp with your app's name
                        NSWorkspace.shared.open(url)
                    }
                } label: {
                    HStack(){
                        Image(systemName: "gear")
                        Text("Aria2 Preferences")
                    }
                }
                Button {
                    NSApp.terminate(self)
                } label: {
                    Text("Exit")
                }
            }
            .frame(minWidth:0,maxWidth: .infinity)
                .padding(.all,5)
            HStack(){
                Image(systemName: "externaldrive.badge.icloud")
                Link("Github Page", destination: URL(string: "https://github.com/jdjingdian/UDownHelper")!)
                Image(systemName: "externaldrive.badge.plus")
                Link("Youtube-dl Page",destination: URL(string: "https://github.com/ytdl-org/youtube-dl")!)
                Image(systemName: "externaldrive.badge.plus")
                Link("Aria2 Page",destination: URL(string: "https://github.com/aria2/aria2")!)
            }
        }.padding(.all,15)
        .onChange(of: processManager.consoleOutput){ _ in
            viewVars.consoleOutMsg.append(contentData(output: processManager.consoleOutput, id: viewVars.consoleOutMsg.count))
        }
        .toolbar{
            FolderSelector(fnName: "Download location", filePath: $dirUrl, fileExist: $viewVars.dirExist, isDir: true)
            FolderSelector(fnName: "Youtube-dl Path", filePath: $ydlExcUrl,fileExist: $viewVars.dlExist,isDir: false)
            FolderSelector(fnName: "Aria2 Path", filePath: $ariaExcUrl, fileExist: $viewVars.ariaExist, isDir: false)
            BuyCoffeeView(likeCount: $likeCount)
                .padding(.leading,20)
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
            .environment(\.locale, .init(identifier: "en"))
    }
}






extension LocalizedStringKey {
    var stringKey: String {
        let description = "\(self)"

        let components = description.components(separatedBy: "key: \"")
            .map { $0.components(separatedBy: "\",") }

        return components[1][0]
    }
}

extension String {
    static func localizedString(for key: String,
                                locale: Locale = .current) -> String {
        
        let language = Bundle.main.preferredLocalizations[0] //注意这个地方对比locale.languageCode
        let path = Bundle.main.path(forResource: language, ofType: "lproj")!
        let bundle = Bundle(path: path)!
        let localizedString = NSLocalizedString(key, bundle: bundle, comment: "")
        
        return localizedString
    }
}

extension LocalizedStringKey {
    func stringValue(locale: Locale = .current) -> String {
        return .localizedString(for: self.stringKey, locale: locale)
    }
}
