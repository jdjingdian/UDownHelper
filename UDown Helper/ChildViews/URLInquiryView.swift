//
//  URLInquiryView.swift
//  UDown Helper
//
//  Created by Derek Jing on 2021/10/25.
//

import Foundation
import SwiftUI
struct URLInquiryView: View {
    var minWidth:CGFloat
    @Binding var sourceLogo:Image
    @Binding var videoUrl:String
    @Binding var runCount: Int
    @Binding var dlExcPath:String
    @Binding var dirUrl:String
    
    @ObservedObject var processManager:ProcessHelper
    var body: some View {
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
                processManager.runProcess(dlExcPath: "/usr/local/bin/youtube-dl", dlPath: dirUrl, dlArgs: arg,opMode: .inquire,runMode: .running)
                runCount += 1
            } label: {
                Image(systemName: "magnifyingglass.circle")
            }.foregroundColor(videoUrl == "" ? Color(.gray):Color("textColor"))
                .padding([.leading,.trailing],5)
                .disabled(videoUrl == "")
            
        }.frame(minWidth:minWidth,maxWidth: .infinity)
            .padding(.all,10)
    }
}
