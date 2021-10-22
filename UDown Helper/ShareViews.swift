//
//  ShareViews.swift
//  UDown Helper
//
//  Created by Derek Jing on 2021/10/22.
//
import SwiftUI
import Foundation

struct ContentScrollView: View {
    let contentHeight:CGFloat
    let contentWeight:CGFloat
    @Binding var contentEntries:[contentData]
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical){
                VStack(alignment:.leading,spacing:0){
                    ForEach(self.contentEntries,id:\.self){ line in
                        ContentSubview(scrollView: proxy, entry: line, dataCount: contentEntries.count)
                            .onAppear {
                                proxy.scrollTo(line.id)
                            }
                            
                    }
                    
                }.animation(.easeIn(duration: 0.5))
                    .offset(y:5)
                    .frame(maxWidth:.infinity,alignment: .leading)
//                    .onChange(of: contentEntries.) { _ in
//                        withAnimation {
//                            proxy.scrollTo(self.contentEntries.last)
//                        }
//                    }
            }
        }
        .clipped()
        .frame(width: contentWeight, height: contentHeight)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray,lineWidth: 2))
        .padding()
    }
}


struct ContentSubview: View {
    let scrollView:ScrollViewProxy
    let entry:contentData
    let dataCount:Int
    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            Text(entry.output)
                .font(.system(size: 14))
                .fontWeight(.light)
                .foregroundColor(Color("textColor"))
        }.frame(alignment:.leading)
            .offset(x:10)
            .id(entry.id)
//            .onAppear(){
//                scrollView.scrollTo(entry)
//            }
    }
}
