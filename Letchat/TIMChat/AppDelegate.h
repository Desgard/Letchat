//
//  AppDelegate.h
//  TIMChat
//
//  Created by AlexiChen on 16/1/29.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : IMAAppDelegate

//次变量为了解决问题：从联系人列表进入聊天界面，即使不做任何操作，都会生成一个会话(现象是会话列表多出一个会话)
//@property (nonatomic, assign) BOOL isContactListEnterChatViewController;

- (void)pushToChatViewControllerWith:(IMAUser *)user;

@end

