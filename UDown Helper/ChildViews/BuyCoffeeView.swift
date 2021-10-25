//
//  BuyCoffeeView.swift
//  UDown Helper
//
//  Created by Derek Jing on 2021/10/25.
//

import Foundation
import SwiftUI

struct BuyCoffeeView: View {
    @Binding var likeCount:Int
    var body: some View {
        if likeCount < 10{
            Button {
          
                    if let url = URL(string: "uhelper://like") { //replace myapp with your app's name
                        NSWorkspace.shared.open(url)

                }
                
            } label: {
                Image(systemName: "hand.thumbsup.fill")
                    .resizable()
                    .foregroundColor(.orange)
                    .frame(width: 15, height: 15, alignment: .center)
                    .scaledToFit()
                    
            }
        }
        }
        
}


struct BuyCoffeeView_Previews:PreviewProvider {
    static var previews: some View{
        BuyCoffeeView(likeCount: .constant(10))
    }
}

struct BuyCoffeeSubview: View {
    @Binding var runCount: Int
    @Binding var likeCount:Int
    var body: some View {
        VStack(){
            Text("小助手已帮你查询/下载\(runCount)次")
                .fontWeight(.bold)
                .foregroundColor(Color("textColor"))
            Image("like")
                .onTapGesture {
                    likeCount += 1
                }
            Text("如果觉得好用的话，可以微信扫码请我喝咖啡~")
                .fontWeight(.bold)
                .foregroundColor(Color("textColor"))
            
            Text("再点击\(10 - likeCount)次可以永久关闭改选项")
                .foregroundColor(Color("textColor").opacity(0.5))
                .fontWeight(.light)
                .padding(.all,20)
        }.padding(.all,20)
    }
}
