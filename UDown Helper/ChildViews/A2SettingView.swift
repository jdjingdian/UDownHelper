//
//  A2SettingView.swift
//  UDown Helper
//
//  Created by Derek Jing on 2021/10/23.
//

import Foundation
import SwiftUI

struct Aria2SettingView: View {
    @Binding var maxConnection: String
    @Binding var split: String
    @Binding var maxConcurrentDown: String
    @Binding var minBlockSize: String
    var body: some View{
        VStack(alignment: .leading, spacing: 10){
            Aria2DetailSettingView(title: "Max Connection", parameter: $maxConnection)
            Aria2DetailSettingView(title: "Split",parameter: $split)
            Aria2DetailSettingView(title: "Max Concurrent",parameter: $maxConcurrentDown)
            Aria2DetailSettingView(title: "Min Blocksize(MB)",parameter: $minBlockSize)
        }.padding(.all,10)
        
    }
}

struct Aria2SettingView_Previews:PreviewProvider{
    
    static var previews:some View{
        Aria2SettingView(maxConnection: .constant("16"), split: .constant("16"), maxConcurrentDown: .constant("8"), minBlockSize: .constant("1"))
    }
}

struct Aria2DetailSettingView:View {
    let title: String
    @Binding var parameter: String
    var body: some View{
        HStack(){
            Text(title)
            TextField("",text:$parameter)
                .frame(width: 50)
                .cornerRadius(25)
        }
    }
}
