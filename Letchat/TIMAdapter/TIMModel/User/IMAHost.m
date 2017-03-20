//
//  IMAHost.m
//  TIMAdapter
//
//  Created by AlexiChen on 16/1/29.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "IMAHost.h"

@implementation IMAHost

- (void)asyncProfile
{
    __weak IMAHost *ws = self;
    [[TIMFriendshipManager sharedInstance] GetSelfProfile:^(TIMUserProfile *selfProfile) {
        DebugLog(@"Get Self Profile Succ");
        ws.profile = selfProfile;
    } fail:^(int code, NSString *err) {
        DebugLog(@"Get Self Profile Failed: code=%d err=%@", code, err);
        [[HUDHelper sharedInstance] tipMessage:IMALocalizedError(code, err)];
    }];
}

- (BOOL)isMe:(IMAUser *)user
{
    return [self.userId isEqualToString:user.userId];
}


- (void)setLoginParm:(TIMLoginParam *)loginParm
{
    _loginParm = loginParm;
    [_loginParm saveToLocal];
}

- (NSString *)userId
{
    return _profile ? _profile.identifier : _loginParm.identifier;
}
- (NSString *)icon
{
    return nil;
}
- (NSString *)remark
{
    return ![NSString isEmpty:_profile.nickname] ? _profile.nickname : _profile.identifier;
}
- (NSString *)name
{
    return ![NSString isEmpty:_profile.nickname] ? _profile.nickname : _profile.identifier;
}
- (NSString *)nickName
{
    return ![NSString isEmpty:_profile.nickname] ? _profile.nickname : _profile.identifier;
}



@end
