### 使用第三方框架：youtube-dl, aria2

---

#### 使用教程（现在太累了，之后补充详细

1. 安装homebrew：`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
2. 安装youtube-dl：`brew install youtube-dl`
3. 安装aria2：`brew install aria2`
4. 确保youtube-dl和aria2是安装在`/usr/local/bin`目录下，目前是写死的
5. 快乐下载

---

#### 已知问题

- ~~成下载后CPU占用会飙升，正在排查~~ [**解决方法**](# 进程结束task的输出没有停止导致CPU占用过高)

---

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

5. ##### 文件路径使用相对路径

   起初我的文件URL写成`URL(fileURLWithPath:~/Downloads)`时，程序会崩溃，但如果我指定绝对路径的话，就不方便程序的传播，经过修改，可以使用相对路径，如下

   ``` swift
   URL(fileURLWithPath: (NSString(string:"~/Downloads").expandingTildeInPath))
   ```

6. ##### 适配深色模式

   最初我习惯用`.preferredColorScheme(.light)`来强制应用使用浅色模式，这种方式在iOS上蛮好用的，因为iOS应用都是全屏运行的，并不会有什么违和感，但是在mac上运行时，系统切换到了深色模式，应用还保留在浅色模式，会非常突兀，解决的方法也很简单，在Assets里添加ColorSet即可，可以为深色模式手动设定颜色，使用的时候使用以下样例即可

   ``` swift
   .foregroundColor(Color("textColor"))//textColor是我给ColorSet起得名字
   ```

   ![WX20211022-224119@2x.png](https://i.loli.net/2021/10/22/hD2YtcAXaRP9J4f.png)

7. ##### 莫名其妙的环境变量引起的问题

   这个应用的基础功能是调用`youtube-dl`来下载视频，但关键核心其实是`aria2`外挂下载器来加速，但起初按照正确的命令配置后，下载的时候始终无法调用到aria2下载器加速，仍然是使用youtube-dl本身的下载功能，在琢磨了一整天仍然不知道为什么后，我尝试在代码中加入环境变量，没想到意外地解决了这个问题

   ``` swift
   var environment =  ProcessInfo.processInfo.environment
   environment["PATH"] = "/usr/local/bin" //← youtube-dl和aria2c可执行程序所在的目录
   task.environment = environment
   ```

   ![561a803262669f1069cce8cf76766b49.jpg](https://i.loli.net/2021/10/23/ljT5zNK6bHpiu3G.jpg)

8. ##### 简单的用户配置存储

   我在程序里设置了默认下载目录为`~/Downloads`，但也许有用户会希望能更改默认存储位置，并希望下次程序启动的时候能记住此前的选择，这样就不用每次都选择目录了。这里选择了一个非常简单的方法，在SwiftUI2.0中提出了三种新的用于数据持久性的新属性包装器

   ``` swift
   @AppStorage
   @StateObject
   @SceneStorage
   ```

   在本项目里使用的是`@AppStorage`,实现了能够保存用户下载目录和可执行文件路径的功能，在Stack Overflow上有一段解释，个人觉得讲的蛮清楚的[SwiftUI: What is @AppStorage property wrapper](https://stackoverflow.com/questions/62562534/swiftui-what-is-appstorage-property-wrapper)

   简单来说，`@AppStorage`是一种很方便的方法用于从`UserDefaults`里读写数据，并且使用起来跟`@State`修饰符一样，当数据发生变化的时候它会自动将数据保存到UserDefaults中。代码举例来说：

   ``` swift
   @State var dirUrl = NSString(string:"~/Downloads").expandingTildeInPath
   ```

   改成以下即可：

   ``` swift
   @AppStorage("dirUrl") var dirUrl:String = NSString(string:"~/Downloads").expandingTildeInPath
   ```

   它的功能与以下代码等价：

   ``` swift
   @State var dirUrl: String = NSString(string:"~/Downloads").expandingTildeInPath {
       get {
           UserDefaults.standard.string(forKey: "dirUrl")
       }
       set {
           UserDefaults.standard.set(newValue, forKey: "dirUrl")
       }
   }
   ```

   `@AppStorage`的行为与`@State`相似，当数据发生变化的时候，也会驱动UI界面重新绘制。默认情况下，`@AppStorage`会使用`UserDefaults.standard`来存储数据，但是你也可以自定义使用你自己的`UserDefault`存储。

9. ##### 进程结束task的输出没有停止导致CPU占用过高

经过很多次测试，最终猜测占用过高的原因可能跟控制台输出有关，注释掉输出部分的代码后，程序运行后不会再出现CPU占用过高的情况。控制台输出原本的代码如下：

``` swift
task.standardOutput = pipe
let outHandle = pipe.fileHandleForReading
DispatchQueue.main.async {
    outHandle.readabilityHandler = { pipe in
        let line = String(data: pipe.availableData,encoding: .utf8)
            DispatchQueue.main.async {
                self.consoleOutput = line ?? "nil output"
            }
    }
    self.taskStack.append(taskTrack(process: task, taskType: opMode, runningType: runMode))
}
```

再次测试，发现当程序结束之后，管道的`readabilityHandler`仍然在不断地读取内容，导致CPU占用过高，所以应该要在程序停止后释放。

最终改成如下：

``` swift
DispatchQueue.main.async {
    outHandle.readabilityHandler = { pipe in
        let line = String(data: pipe.availableData,encoding: .utf8)
        if task.isRunning {
            DispatchQueue.main.async {
                self.consoleOutput = line ?? "nil output"
            }
        }else{
            outHandle.readabilityHandler = nil //释放
        }
    }
    self.taskStack.append(taskTrack(process: task, taskType: opMode, runningType: runMode))
}
```

10. ##### 设置窗口标题和副标题

    比较简单，直接上代码

    ``` swift
    WindowGroup {
                ContentView()
                    .navigationTitle("典の视频下载小助手")
                    .navigationSubtitle("\(version)")
    }
    ```

    Github上有一个仓库介绍了相关的Style，可以前往查看学习[SwiftUIWindowStyles](https://github.com/martinlexow/SwiftUIWindowStyles)

11. ##### 本地化

    在本地化的过程中，如果是单纯的String，比如Text("Hello")里的"Hello"，可以很轻松通过Localizable.string实现本地化，但是对于一些变量来说，就会不生效，参照网上写了个扩展但是初次运行发现不成功，调查后发现是因为通过`locale.languageCode`,原始代码中使用的是这个，但是这个代码返回的东西实际上只是区域信息，就比如中文，有简体，有繁体，有zh-Hans、zh-hk、zh-tw等，这种时候使用`locale.languageCode`就没有办法很好的实现本地化，所以最终我改成了`Bundle.main.preferredLocalizations[0]`来获取当前的语言信息。

    ``` swift
    extension LocalizedStringKey {
        var stringKey: String {
            let description = "\(self)"
    
            let components = description.components(separatedBy: "key: \"")
                .map { $0.components(separatedBy: "\",") }
    
            return components[1][0]
        }
    }
    
    extension String {
        static func localizedString(for key: String,
                                    locale: Locale = .current) -> String {
            
            let language = Bundle.main.preferredLocalizations[0] //注意这个地方对比locale.languageCode
            let path = Bundle.main.path(forResource: language, ofType: "lproj")!
            let bundle = Bundle(path: path)!
            let localizedString = NSLocalizedString(key, bundle: bundle, comment: "")
            
            return localizedString
        }
    }
    
    extension LocalizedStringKey {
        func stringValue(locale: Locale = .current) -> String {
            return .localizedString(for: self.stringKey, locale: locale)
        }
    }
    ```

    在使用的时候，使用这个代替string即可

    ``` swift
    LocalizedStringKey("变量用的，需要本地化的文字").stringValue()
    ```

    

----

## 免责声明

- 本软件只是个UI，请合法使用，仅供个人学习与交流使用，严禁用于商业以及不良用途。
- 如有发现任何商业行为以及不良用途，软件作者有权撤销使用权。
- 使用本软件所存在的风险将完全由其本人承担，软件作者不承担任何责任。
- 因不当使用本软件而导致的任何意外、疏忽、合约毁坏、诽谤、版权或其他知识产权侵犯及其所造成的任何损失，本软件作者概不负责，亦不承担任何法律责任。
- 本声明未涉及的问题请参见国家有关法律法规，当本声明与国家有关法律法规冲突时，以国家法律法规为准。 
- 本软件相关声明版权及其修改权、更新权和最终解释权均属软件作者所有。
