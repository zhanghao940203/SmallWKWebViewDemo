//
//  messageModel.h
//  WebViewTest
//
//  Created by Mac on 2019/4/30.
//  Copyright © 2019 Hao Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JSONModel/JSONModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface messageModel : JSONModel

@property (nonatomic, strong) NSString *body;

@end

NS_ASSUME_NONNULL_END
