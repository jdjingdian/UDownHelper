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
    @Binding var contentEntries:String
    var body: some View {
        ScrollView(){
            ScrollViewReader { scrollView in
                VStack(alignment:.leading,spacing:5){
                        ContentSubview(scrollView: scrollView, entry: contentEntries)
                }.animation(.linear(duration: 0.7))
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
        VStack(alignment: .leading, spacing: 1){
            
            Text("Output:")
                .font(.system(size: 15))
            Text(entry)
                .font(.system(size: 14))
                .fontWeight(.light)
                .foregroundColor(.black)
            
            
        }.frame(alignment:.leading)
            .offset(x:5)
            .onAppear(){
                scrollView.scrollTo(entry)
            }
    }
}
