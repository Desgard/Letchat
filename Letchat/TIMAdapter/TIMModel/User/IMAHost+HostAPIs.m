//
//  IMAHost+HostAPIs.m
//  TIMChat
//
//  Created by AlexiChen on 16/3/22.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "IMAHost+HostAPIs.h"

@implementation IMAHost (HostAPIs)

- (void)asyncSetAllowType:(TIMFriendAllowType)type succ:(TIMSucc)succ fail:(TIMFail)fail
{
    __weak IMAHost *ws = self;
    [[TIMFriendshipManager sharedInstance] SetAllowType:type succ:^{
            ws.profile.allowType = type;
            if (succ)
            {
                succ();
            }
    } fail:^(int code, NSString *msg) {
            DebugLog(@"code = %d, err = %@", code, msg);
            [[HUDHelper sharedInstance] tipMessage:IMALocalizedError(code, msg)];
            if (fail)
            {
                fail(code, msg);
            }
    }];
}

- (void)asyncSetNickname:(NSString *)nick  succ:(TIMSucc)succ fail:(TIMFail)fail
{
    if ([NSString isEmpty:nick])
    {
        [[HUDHelper sharedInstance] tipMessage:@"昵称不能为空"];
        return;
    }
    if ([nick utf8Length] > kNicknameMaxLength)
    {
        [[HUDHelper sharedInstance] tipMessage:@"昵称超过长度限制"];
        return;
    }
    
    __weak IMAHost *ws = self;
    [[TIMFriendshipManager sharedInstance] SetNickname:nick succ:^{
        ws.nickName = nick;
        ws.profile.nickname = nick;
        if (succ)
        {
            succ();
        }
    } fail:^(int code, NSString *msg) {
        //        dispatch_async(dispatch_get_main_queue(), ^{
        DebugLog(@"code = %d, err = %@", code, msg);
        [[HUDHelper sharedInstance] tipMessage:IMALocalizedError(code, msg)];
        if (fail)
        {
            fail(code, msg);
        }
    }];

}

@end
