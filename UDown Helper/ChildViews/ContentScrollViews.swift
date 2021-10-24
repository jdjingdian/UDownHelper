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
    //                    .onChange(of: contentEntries.) { _ in
    //                        withAnimation {
    //                            proxy.scrollTo(self.contentEntries.last)
    //                        }
    //                    }
                }
                
                                ScrollViewReader{ proxy in
                                    ScrollView(.vertical){
                                        VStack(){
                                            ForEach(processManager.taskStack,id:\.self){ task in
                                                HStack(){
                                                
                                                    switch task.runningType {
                                                    case .running:Text("\(task.taskType.rawValue)正在运行").fontWeight(.bold)
                                                    case .acciStop:Text("\(task.taskType.rawValue)手动停止").fontWeight(.bold)
                                                    case .complete:Text("\(task.taskType.rawValue)运行结束").fontWeight(.bold)
                                                    }
//                                                    task.process.isRunning ? Text("正在运行").fontWeight(.bold):Text("运行结束").fontWeight(.bold)
                                                    if task.process.isRunning{
                                                        Image(systemName: "arrow.down.circle")
                                                            .foregroundColor(.blue)
                                                    }else if task.runningType == .acciStop {
                                                        Image(systemName: "exclamationmark.octagon.fill")
                                                        .foregroundColor(.red)
                                                    }
                                                    else{
                                                        Image(systemName: "checkmark.seal.fill")
                                                        .foregroundColor(.green)
                                                    }
                
                                                }.padding(.all,10)
                                                .background(Color("backColor"))
                                                .cornerRadius(10)
                
                
                
                                            }
                                        }
                
                                    }.clipped()
                //                        .frame(width: window!.width/4, height: window!.height/3)
                //                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray,lineWidth: 2))
                                        .padding()
                                    
                                }
                
            }
            .clipped()
            .frame(width: contentWeight, height: contentHeight)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray,lineWidth: 2))
            .padding()
            
            
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
