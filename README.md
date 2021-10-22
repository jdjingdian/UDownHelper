### 使用第三方框架：nil



#### 学到的一些知识点：

1. ##### 打开文件选择框

   在本项目中，需要打开文件框来选择下载目录，这里使用的方法是`NSOpenPanel`

   关键代码如下

   ``` swift
    panel.allowsMultipleSelection = false //不允许选择多项
    panel.canChooseDirectories = true //可以选择目录
    panel.canChooseFiles = false //不可以选择文件
    panel.directoryURL = URL(string: "~/Downloads") //设置默认打开文件路径为用户下载路径
    if panel.runModal() == .OK {
    	folderUrl = panel.url?.path ?? "~/Downloads" //返回文件夹path
    }
   ```

2. ##### 主线程与子线程の一些问题

   在之前制作SocketCS的时候，第一次接触到了DispatchQueue这个东西，当时没研究明白以为无脑`DispatchQueue.main.async`就完事了，但是制作这次项目的时候，因为需要联网下载视频，运行时间会比较长，我发现如果使用`DispatchQueue.main.async`的话，程序就会卡主不动。

   经过面向谷歌编程，我发现，问题的出现是因为我对这玩意的理解不透彻，总结来说，DispatchQueue里面有三种队列，分别是Main Queue、Global Queue、Custom Queue，main是主队列，串行运行的，与UI相关的所有操作都必须在main中完成。global是全局队列，并行运行的，运行在后台线程，是系统内共享的全局队列，custom是自定义队列，默认是串行的。

   在后台运行的子任务，如果想将数据推向UI，应使用DispatchQueue.main.async将数据传回主线程，样例如下

   ``` swift 
   DispatchQueue.global().async{
     //后台代码
     DispatchQueue.main.async{
       //后台运行代码结束后传回数据的代码放这里
     }
   }
   ```

   具体的介绍可以看这个链接：[一天精通iOS Swift多线程（GCD）

3. ##### 后台运行的脚本如何将控制台输出传回UI（⭐️有大坑）

   因为这个项目本质上只是给youtube-dl包装了一个外壳，youtube-dl又是一个命令行程序，所以我想将youtube-dl运行时的控制台信息在SwiftUI中显示出来，程序运行的时候，我将控制台输出输出到`pipe`管道中，面向谷歌编程后，大概明白需要使用一段简单的代码

   ``` swift
   DispatchQueue.main.async {
     ...
   	let pipe = Pipe()
   	task.standardOutput = pipe
   	let outHandle = pipe.fileHandleForReading
   	outHandle.readabilityHandler = { pipe in
         var line = String(data: pipe.availableData,encoding: .utf8)
         print(line)
     }
     do{
       try task.run()
     }catch{
       print("运行错误")
     }
   }
   
   ```

   `readabilityHandler`是OS X 10.7后开始提供的功能，可以读取管道中的实时内容。但是我在使用了这个代码之后，仍然没法Swift控制台中看到实时的信息，只有当整个下载流程结束之后，才会一次性将所有的信息打印出来，在折腾了一个多小时之后，我发现少写了一行代码……

   ``` swift
      DispatchQueue.main.async {
        ...
      	let pipe = Pipe()
      	task.standardOutput = pipe
      	let outHandle = pipe.fileHandleForReading
      	outHandle.readabilityHandler = { pipe in
            var line = String(data: pipe.availableData,encoding: .utf8)
            print(line)
        }
        do{
          try task.run()
        }catch{
          print("运行错误")
        }
      }
      task.waitUntilExit()//←没有写这个就不会实时显示
   ```
   个人理解，如果没有使用`waitUntilExit()`,运行的脚本就会直接进入后台，从而`readabilityHandler`无法读取到脚本的控制台输出。
4. ##### 关闭App Sandbox

   关闭App Sandbox后的应用无法提交到App Store，但这问题不大，本身就只是小工具，如果不关闭沙盒的话，我的程序就没办法直接读取电脑中的内容，也就没办法控制youtube-dl程序进行下载了，所以，要在Entitlement文件中将该选项设置为关。

   ![WX20211022-195522@2x.png](https://i.loli.net/2021/10/22/movBkhwQNiSjb8O.png)
