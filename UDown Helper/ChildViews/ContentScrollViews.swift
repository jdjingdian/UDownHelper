//
//  ShareViews.swift
//  UDown Helper
//
//  Created by Derek Jing on 2021/10/22.
//
import SwiftUI
import Foundation

struct ContentScrollView: View {
    let minHeight:CGFloat
    let minWidth:CGFloat
    
    @Binding var contentEntries:[contentData]
    @ObservedObject var processManager:ProcessHelper
    var body: some View {
        ScrollViewReader { proxy in
            HStack(){
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
                }
                
                RunningState(processManager: processManager)
                
            }        }
        .clipped()
        .frame(minWidth: minWidth, minHeight: minHeight,alignment: .center)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray,lineWidth: 1))
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
    }
}

struct RunningState: View {
    @ObservedObject var processManager:ProcessHelper
    var body: some View {
        ScrollViewReader{ proxy in
            ScrollView(.vertical){
                VStack(){
                    ForEach(processManager.taskStack,id:\.self){ task in
                        
                        if task.isHide == false{
                            HStack(){
                                
                                switch task.runningType {
                                case .running:Text("\(task.taskType.rawValue)正在运行").fontWeight(.bold)
                                case .acciStop:Text("\(task.taskType.rawValue)手动停止").fontWeight(.bold)
                                case .complete:Text("\(task.taskType.rawValue)运行结束").fontWeight(.bold)
                                }
                                if task.runningType == .complete{
                                    Image(systemName: "checkmark.seal.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 15, height: 15)
                                        .foregroundColor(.green)
                                        .onTapGesture {
                                            processManager.taskStack[task.index].isHide = true
                                        }
                                    
                                    //
                                }else if task.runningType == .acciStop{
                                    Image(systemName: "exclamationmark.octagon.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 15, height: 15)
                                        .foregroundColor(.orange)
                                        .onTapGesture {
                                            processManager.taskStack[task.index].isHide = true
                                        }
                                }
                                else{
                                    Image(systemName: "arrow.down.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 15, height: 15)
                                        .foregroundColor(.blue)
                                }
                                
                            }.padding(.all,10)
                        
                                .background(task.highlight ? Color("backHighlight"):Color("backColor"))
                                .cornerRadius(10)
                                .onTapGesture {
                                    processManager.taskStack[task.index].highlight = true
                                    DispatchQueue.main.asyncAfter(deadline: .now()+0.15) {
                                        processManager.taskStack[task.index].highlight = false
                                        if task.runningType == .running{
                                            processManager.taskStack[task.index].runningType = .acciStop
                                            task.process.terminate()
                                        }
                                    }
                                }
                        }
                        
                        
                        
                        
                        
                    }
                }
                
            }.clipped()
            //                        .frame(width: window!.width/4, height: window!.height/3)
            //                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray,lineWidth: 2))
                .padding()
            
        }
    }
}
