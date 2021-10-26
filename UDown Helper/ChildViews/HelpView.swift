//
//  HelpView.swift
//  UDown Helper
//
//  Created by Derek Jing on 2021/10/25.
//

import Foundation
import SwiftUI

struct HelpView: View{
    var body:some View {
        NavigationView(){
            
            List{
                NavigationLink(destination: InstallHelpView()) {
                    HStack(){
                        Image(systemName: "tray.and.arrow.down.fill")
                            .resizable()
                            .foregroundColor(.black)
                            .frame(width: 15, height: 15, alignment: .center)
                            .scaledToFit()
                        Text("How To Install dependency")
                            .fontWeight(.bold)
                    }
                }
                NavigationLink(destination: TutorialView()) {
                    HStack(){
                        Image(systemName: "person.fill.questionmark")
                            .resizable()
                            .foregroundColor(.black)
                            .frame(width: 15, height: 15, alignment: .center)
                            .scaledToFit()
                        Text("Tutorial")
                            .fontWeight(.bold)
                    }
                }
                NavigationLink(destination: ResetView()){
                    HStack(){
                        Image(systemName: "gobackward")
                            .resizable()
                            .foregroundColor(.black)
                            .frame(width: 15, height: 15, alignment: .center)
                            .scaledToFit()
                        Text("Reset")
                            .fontWeight(.bold)
                    }
                    
                }
            }
            
        }

    }
}



struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}

struct ResetView: View{
    var body: some View {
        VStack{
            Text("⚠️Tap the button to reset the app.⚠️")
                .fontWeight(.bold)
            Button {
                let domain = Bundle.main.bundleIdentifier!
                UserDefaults.standard.removePersistentDomain(forName: domain)
                UserDefaults.standard.synchronize()
                NSApp.terminate(self)
                
            } label: {
                
                HStack(){
                    Image(systemName: "gobackward")
                        .resizable()
                        .foregroundColor(.black)
                        .frame(width: 15, height: 15, alignment: .center)
                        .scaledToFit()
                    Text("Reset")
                        .fontWeight(.bold)
                }
            }
        }
    }
}

struct InstallHelpView: View {
    var body: some View{
        VStack{
            InstallHelpSubview(title: "1. Install Homebrew:", text: "/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"")
            InstallHelpSubview(title: "2. Install Youtube-dl:", text: "brew install youtube-dl")
            InstallHelpSubview(title: "3. Install aria2:", text: "brew install aria2")
            Spacer()
            Text("确保youtube-dl和aria2是安装在`/usr/local/bin`目录下，目前是写死的")
                .foregroundColor(.gray)
                .fontWeight(.bold)
        }.padding(.all,20)
    }
}


struct InstallHelpSubview: View {
    let title:String
    let text:String
    var body: some View {
        HStack(){
            Text(LocalizedStringKey(title).stringValue())
                .fontWeight(.bold)
            Text(text).lineLimit(1)
            Button {
                let pasteboard = NSPasteboard.general
                pasteboard.declareTypes([.string], owner: nil)
                pasteboard.setString(text, forType: .string)
            } label: {
                Image(systemName: "doc.on.clipboard")
            }
            
        }
    }
}

struct TutorialView:View{
    var body: some View{
        Text("匆忙施工中，请先看Github，以及自己摸索")
        
    }
}
