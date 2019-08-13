# SmallWKWebViewDemo
A simple demo of using WKWebView which is wrote for practice some basic functions while I learn WKWebView. 
WKWebView有两个delegate,WKUIDelegate和WKNavigationDelegate。WKNavigationDelegate主要处理一些跳转、加载处理操作，WKUIDelegate主要处理JS脚本，确认框，警告框等。

声明一个WKWebView并设置其代理到父级控制器：


    _webView =[[WKWebView alloc]initWithFrame:CGRectMake(0,100,  self.view.bounds.size.width,self.view.bounds.size.height)];

    [self.view addSubview:_webView];

    _webView.UIDelegate =self;

    _webView.navigationDelegate =self;

设置网页路径，如果是一个本地html页面，首先将html和配套js、css文件引入iOS工程，然后创建路径变量为此工程包：


    NSString *path =[[[NSBundle mainBundle]bundlePath]  stringByAppendingPathComponent:@"webViewTest.html"];

创建一个NSURLRequest，设置其请求URL为一个路径为所需路径的NSURL，然后webView去读取该路径：

    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]];

    [_webView loadRequest: request];

直接使用网页URL调用远程路径：


[_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.jianshu.com/p/4fa8c4eb1316"]]];

JS调用OC方法：

首先需要配置WKWebView的WKWebViewConfiguration

的WKUserContentController：


    WKWebViewConfiguration * configuration =[[WKWebViewConfiguration alloc]init];

    userContentController =[[WKUserContentController alloc]init];

    configuration.userContentController = userContentController;

    _webView =[[WKWebView alloc]initWithFrame:CGRectMake(0,100,self.view.bounds.size.width,self.view.bounds.size.height)configuration:configuration];

然后通过调用addScriptMessageHandler方法注册要调用OC方法的JS方法：


[userContentController addScriptMessageHandler:selfname:@"callOC”];//callOC为js方法的标签

然后通过实现WKScriptMessageHandler中的代理方法didReceiveScriptMessage来处理从JS接收到的消息：


-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{

    if([message.name isEqualToString:@"callOC"]){

//message.name即位js方法的标签，通过比对标签的值来确认处理哪个js函数

        NSDictionary *msg = message.body;

//message.body为js传递过来的参数，是一个字典型数据结构

        NSString *msgBody =[msg objectForKey:@"body"];

        UIAlertController *alert =[UIAlertController alertControllerWithTitle:@"提示" message:msgBody preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *action =[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:nil];

        [alert addAction:action];

        [selfpresentViewController:alert animated:YEScompletion:nil];

    }

}

HTML代码和JS代码：

html：


<html>

<head>

</head>

hello world
        say hello

</html>

javaScript：


    function say()

    {

        window.webkit.messageHandlers.callOC.postMessage({body: 'hello world!'});

    }//此处的window.webkit.messageHandlers.sayhello.postMessage方法中sayhello为这个需要调用OC方法的js方法的标签，注意一定要和OC的addScriptMessageHandler方法中注册的一致

OC调用JS方法：

调用evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void(^_Nullable)(_Nullableid,NSError *_Nullableerror))completionHandler方法，其中javaScriptString为需要调用的js方法名称，参数可以直接用括号拼接进去，completionHandler为完成后的回调：


    [_webView evaluateJavaScript:@"alertAction('OC调用JS警告窗方法')" completionHandler:^(id_Nullableitem,NSError *_Nullableerror){

        NSLog(@"alert");

    }];

这里要显示一个JS的Alert，则需要实现WKUIDelegate代理中的webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void(^)(void))completionHandler方法在OC中替JS创建alert：


-(void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void(^)(void))completionHandler{

    UIAlertController *alert =[UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *action =[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnullaction){

        completionHandler();//此处的completionHandler()就是调用JS方法时，`evaluateJavaScript`方法中的completionHandler

    }];

    [alert addAction:action];

    [selfpresentViewController:alert animated:YEScompletion:nil];

}

关于h5页面的进度条：

创建一个UIProgressView类型的对象：


        _progressView =[[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar];

        _progressView.frame = CGRectMake(0,50,self.view.bounds.size.width,2.5);

        _progressView.tintColor =[UIColor greenColor];

        _progressView.trackTintColor =[UIColor lightGrayColor];

对WKWebView添加监听：


[_webView addObserver:selfforKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];

注意这里使用了NSKeyValueObservingOptionNew，这个选项可以使观察者获取被监听对象的被监听属性的变化以及变化后的新值

然后添加观察者方法：


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void*)context {

    if(object ==self.webView &&[keyPath isEqualToString:@"estimatedProgress"]){

    //添加进度条动画效果

    }

}

参考：
https://www.jianshu.com/p/35be2053111c
https://www.jianshu.com/p/4fa8c4eb1316
https://www.jianshu.com/p/5cf0d241ae12

