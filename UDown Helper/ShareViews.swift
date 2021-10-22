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
    @Binding var contentEntries:[String]
    var body: some View {
        ScrollView(){
            ScrollViewReader { scrollView in
                VStack(alignment:.leading,spacing:0){
                    ForEach(self.contentEntries,id:\.self){ line in
                        ContentSubview(scrollView: scrollView, entry: line)
                    }
                        
                }.animation(.easeIn(duration: 0.5))
                .offset(y:5)
                .frame(maxWidth:.infinity,alignment: .leading)
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
    let entry:String
    var body: some View {
        VStack(alignment: .leading, spacing: 0){
//            Text("Output:")
//                .font(.system(size: 10))
//                .foregroundColor(.gray)
//                .fontWeight(.ultraLight)
            
            Text(entry)
                .font(.system(size: 14))
                .fontWeight(.light)
                .foregroundColor(Color("textColor"))
                
            
            
        }.frame(alignment:.leading)
            .offset(x:10)
            .onAppear(){
                scrollView.scrollTo(entry)
            }
    }
}
