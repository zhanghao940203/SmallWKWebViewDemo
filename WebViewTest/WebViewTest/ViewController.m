//
//  ViewController.m
//  WebViewTest
//
//  Created by Mac on 2019/4/29.
//  Copyright © 2019 Hao Zhang. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "messageModel.h"

@interface ViewController ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>{
    WKUserContentController* userContentController;
    UIButton *_alertButton;
}
@property(nonatomic,strong)UIProgressView * progressView;
@property(nonatomic, strong)WKWebView *webView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    WKWebViewConfiguration * configuration = [[WKWebViewConfiguration alloc]init];
    userContentController =[[WKUserContentController alloc]init];
    configuration.userContentController = userContentController;
    _webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, self.view.bounds.size.height) configuration:configuration];
    
    [userContentController addScriptMessageHandler:self name:@"sayhello"];
    
//    _webView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_webView];
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;
    NSString *path = [[[NSBundle mainBundle] bundlePath]  stringByAppendingPathComponent:@"webViewTest.html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]];
    [_webView loadRequest: request];
//    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.jianshu.com/p/4fa8c4eb1316"]]];
    // Do any additional setup after loading the view, typically from a nib.
    
    _alertButton = [[UIButton alloc] initWithFrame:CGRectMake(150, 150, 100, 40)];
    _alertButton.backgroundColor = [UIColor colorWithRed:250/255.0 green:204/255.0 blue:96/255.0 alpha:1.0];
    _alertButton.layer.cornerRadius = 6.0f;
    _alertButton.layer.masksToBounds = YES;
    _alertButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_alertButton setTitle:@"弹出弹窗" forState:UIControlStateNormal];
    [_alertButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_alertButton addTarget:self action:@selector(alertButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_alertButton];
    
    [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc{
    //这里需要注意，前面增加过的方法一定要remove掉。
    [userContentController removeScriptMessageHandlerForName:@"sayhello"];
}

- (UIProgressView *)progressView {
    
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        _progressView.frame = CGRectMake(0, 50, self.view.bounds.size.width, 2.5);
        _progressView.tintColor = [UIColor greenColor];
        _progressView.trackTintColor = [UIColor lightGrayColor];
    }
    [self.view addSubview:_progressView];
    return _progressView;
}

#pragma mark - KVO
//计算WKWebView进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.webView && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        if (newprogress == 1) {
            [self.progressView setProgress:1.0 animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressView.hidden = YES;
                [self.progressView setProgress:0 animated:NO];
            });
        }else {
            self.progressView.hidden = NO;
            [self.progressView setProgress:newprogress animated:YES];
        }
    }
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    if ([message.name isEqualToString:@"sayhello"]) {
        NSDictionary *msg = message.body;
        NSString *msgBody = [msg objectForKey:@"body"];
        NSLog(@"name:%@\\\\n body:%@\\\\n frameInfo:%@\\\\n",message.name,message.body,message.frameInfo);
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:msgBody preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

//接收到警告面板
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();//此处的completionHandler()就是调用JS方法时，`evaluateJavaScript`方法中的completionHandler
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)alertButtonAction{
    [_webView evaluateJavaScript:@"alertAction('OC调用JS警告窗方法')" completionHandler:^(id _Nullable item, NSError * _Nullable error) {
        NSLog(@"alert");
    }];
}


@end
