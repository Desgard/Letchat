//
//  IMAPlatform+AppConfig.m
//  TIMChat
//
//  Created by AlexiChen on 16/2/26.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "IMAPlatform+AppConfig.h"

@implementation IMAPlatform (AppConfig)


// app 启动时配置
- (void)configOnAppLaunch
{
    // TODO:大部份在IMAPlatform创建的时候处理了，此处添加额外处理，用户自行添加
    
}

// app 进入后台时配置
- (void)configOnAppEnterBackground
{
    
    // 将相关的配置缓存至本地
    [[IMAPlatform sharedInstance] saveToLocal];
    
    
    NSUInteger unReadCount = [[IMAPlatform sharedInstance].conversationMgr unReadMessageCount];
    [UIApplication sharedApplication].applicationIconBadgeNumber = unReadCount;
    
    TIMBackgroundParam  *param = [[TIMBackgroundParam alloc] init];
    [param setC2cUnread:(int)unReadCount];
    
    
    [[TIMManager sharedInstance] doBackground:param succ:^() {
        DebugLog(@"doBackgroud Succ");
    } fail:^(int code, NSString * err) {
        DebugLog(@"Fail: %d->%@", code, err);
    }];
}

// app 进前台时配置
- (void)configOnAppEnterForeground
{
    [UIApplication.sharedApplication.windows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIWindow *w, NSUInteger idx, BOOL *stop) {
        if (!w.opaque && [NSStringFromClass(w.class) hasPrefix:@"UIText"]) {
            // The keyboard sometimes disables interaction. This brings it back to normal.
            BOOL wasHidden = w.hidden;
            w.hidden = YES;
            w.hidden = wasHidden;
            *stop = YES;
        }
    }];
    
    //清空通知栏消息
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

// app become active
- (void)configOnAppDidBecomeActive
{
    [[TIMManager sharedInstance] doForeground];
}

// app 注册APNS成功后
- (void)configOnAppRegistAPNSWithDeviceToken:(NSData *)deviceToken
{
    DebugLog(@"didRegisterForRemoteNotificationsWithDeviceToken:%ld", (unsigned long)deviceToken.length);
    NSString *token = [NSString stringWithFormat:@"%@", deviceToken];
    [[TIMManager sharedInstance] log:TIM_LOG_INFO tag:@"SetToken" msg:[NSString stringWithFormat:@"My Token is :%@", token]];
    TIMTokenParam *param = [[TIMTokenParam alloc] init];

#if kAppStoreVersion

// AppStore版本
#if DEBUG
    param.busiId = 2383;
#else
    param.busiId = 2382;
#endif
    
#else
    //企业证书id
    param.busiId = 2516;
#endif
    
    [param setToken:deviceToken];
    
//    [[TIMManager sharedInstance] setToken:param];
    [[TIMManager sharedInstance] setToken:param succ:^{
       
        NSLog(@"-----> 上传token成功 ");
    } fail:^(int code, NSString *msg) {
        NSLog(@"-----> 上传token失败 ");
    }];
}




@end
