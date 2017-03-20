//
//  AppDelegate.m
//  TIMChat
//
//  Created by AlexiChen on 16/1/29.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "AppDelegate.h"

#import <TencentOpenAPI/TencentOAuth.h>

#import "WXApi.h"



@interface AppDelegate ()

@end

@implementation AppDelegate


- (void)configAppLaunch
{
    // 作App配置
    [[NSClassFromString(@"UICalloutBarButton") appearance] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
 
}


- (void)enterMainUI
{
    self.window.rootViewController = [[TIMTabBarController alloc] init];
}

+ (instancetype)sharedAppDelegate
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}


- (void)pushToChatViewControllerWith:(IMAUser *)user
{
    
    TIMTabBarController *tab = (TIMTabBarController *)self.window.rootViewController;
    [tab pushToChatViewControllerWith:user];
}


@end
