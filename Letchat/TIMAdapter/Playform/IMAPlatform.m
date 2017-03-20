//
//  IMAPlatform.m
//  TIMAdapter
//
//  Created by AlexiChen on 16/2/17.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "IMAPlatform.h"

@interface IMAPlatform ()

@property (nonatomic, assign) TCQALNetwork networkType;

@end

@implementation IMAPlatform

#define kIMAPlatformConfig          @"IMAPlatformConfig"


static IMAPlatform *_sharedInstance = nil;

+ (instancetype)configWith:(IMAPlatformConfig *)cfg
{
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        _sharedInstance = [[IMAPlatform alloc] init];
        [_sharedInstance configIMSDK:cfg];
    });
    
    return _sharedInstance;
    
}
static Class kHostClass = Nil;
+ (void)configHostClass:(Class)hostcls
{
    if (![hostcls isSubclassOfClass:[IMAHost class]])
    {
        DebugLog(@"%@ 必须是IMAHost的子类型", hostcls);
    }
    else
    {
        kHostClass = hostcls;
    }
}
+ (instancetype)sharedInstance
{
    // TODO:
    return _sharedInstance;
}

#define kIMAPlatform_AutoLogin_Key @"kIMAPlatform_AutoLogin_Key"

+ (BOOL)isAutoLogin
{
    NSNumber *num = [[NSUserDefaults standardUserDefaults] objectForKey:@"kIMAPlatform_AutoLogin_Key"];
    return [num boolValue];
}
+ (void)setAutoLogin:(BOOL)autologin
{
    [[NSUserDefaults standardUserDefaults] setObject:@(autologin) forKey:kIMAPlatform_AutoLogin_Key];
}

//
//- (void)initialFriendProxy:(TIMSucc)succ fail:(TIMFail)fail
//{
//    // 说明登录成功
////    _friendShipMgr = [[TIMFriendshipManager sharedInstance] getFriendshipProxy];
////    [_friendShipMgr SetProxyListener:self];
////    [_friendShipMgr SyncWithFlags:0XFF custom:nil succ:succ fail:fail];
//    
//    
//}


- (IMAContactManager *)contactMgr
{
    if (!_contactMgr)
    {
        _contactMgr = [[IMAContactManager alloc] init];
    }
    return _contactMgr;
}

- (IMAConversationManager *)conversationMgr
{
    if (!_conversationMgr)
    {
        _conversationMgr = [[IMAConversationManager alloc] init];
    }
    return _conversationMgr;
}

- (IMAUser *)getReceiverOf:(IMAConversation *)conv
{
    NSString *receiver = [conv receiver];
    if (conv.type == TIM_C2C)
    {
        return [self.contactMgr getUserByUserId:receiver];
    }
    else if (conv.type == TIM_GROUP)
    {
        // 查询群列表
        return [self.contactMgr getUserByGroupId:receiver];
    }
    else
    {
        DebugLog(@"不支持的会话模式");
        return nil;
    }
}

- (void)configIMSDK:(IMAPlatformConfig *)cfg
{
    TIMManager *manager = [TIMManager sharedInstance];
    
    [manager setEnv:cfg.environment];
    [manager initLogSettings:cfg.enableConsoleLog logPath:[manager getLogPath]];
    [manager setLogLevel:cfg.logLevel];
    [manager disableAutoReport];
    
    [manager initSdk:[kSdkAppId intValue] accountType:kSdkAccountType];
    
    [manager setConnListener:self];
    
    [manager setRefreshListener:self];
    
    [manager setUserStatusListener:self];
    
    //初始化好友代理监听
    TIMFriendshipSetting *setting = [[TIMFriendshipSetting alloc] init];
    setting.friendFlags = TIM_PROFILE_FLAG_NICK | TIM_PROFILE_FLAG_ALLOW_TYPE | TIM_PROFILE_FLAG_FACE_URL | TIM_PROFILE_FLAG_REMARK | TIM_PROFILE_FLAG_GROUP | TIM_PROFILE_FLAG_SELFSIGNATURE;
    
    [manager initFriendshipSetting:setting];
    [manager enableFriendshipProxy];
    [manager setFriendshipProxyListener:self];
    
    //初始化群助手监听
    TIMGroupSetting *groupSetting = [[TIMGroupSetting alloc] init];
//    groupSetting.groupFlags = TIM_GET_GROUP_BASE_INFO_FLAG_NAME | TIM_GET_GROUP_BASE_INFO_FLAG_CREATE_TIME | TIM_GET_GROUP_BASE_INFO_FLAG_OWNER_UIN |TIM_GET_GROUP_BASE_INFO_FLAG_SEQ | TIM_GET_GROUP_BASE_INFO_FLAG_TIME | TIM_GET_GROUP_BASE_INFO_FLAG_NEXT_MSG_SEQ | TIM_GET_GROUP_BASE_INFO_FLAG_LAST_MSG_TIME | TIM_GET_GROUP_BASE_INFO_FLAG_APP_ID | TIM_GET_GROUP_BASE_INFO_FLAG_MEMBER_NUM | TIM_GET_GROUP_BASE_INFO_FLAG_MAX_MEMBER_NUM | TIM_GET_GROUP_BASE_INFO_FLAG_NOTIFICATION | TIM_GET_GROUP_BASE_INFO_FLAG_INTRODUCTION | TIM_GET_GROUP_BASE_INFO_FLAG_FACE_URL | TIM_GET_GROUP_BASE_INFO_FLAG_ADD_OPTION | TIM_GET_GROUP_BASE_INFO_FLAG_GROUP_TYPE | TIM_GET_GROUP_BASE_INFO_FLAG_LAST_MSG;
//    
//    groupSetting.memberFlags = TIM_GET_GROUP_MEM_INFO_FLAG_JOIN_TIME | TIM_GET_GROUP_MEM_INFO_FLAG_MSG_FLAG | TIM_GET_GROUP_MEM_INFO_FLAG_ROLE_INFO | TIM_GET_GROUP_MEM_INFO_FLAG_SHUTUP_TIME | TIM_GET_GROUP_MEM_INFO_FLAG_NAME_CARD;
    
    groupSetting.groupFlags = 0XFFFF;
    groupSetting.memberFlags = 0XFF;
    groupSetting.groupCustom = nil;
    groupSetting.memberCustom = nil;
    
    [manager initGroupSetting:groupSetting];
    [manager setGroupAssistantListener:self];
    [manager enableGroupAssistant];
}



- (void)saveToLocal
{
    // 保存上一次联系人列表状态
    [_contactMgr saveToLocal];
    
    // 保存Config状态
}

- (void)onLogoutCompletion
{
    [self offlineLogin];
    
    self.offlineExitLivingBlock = nil;
    
    [IMAPlatform setAutoLogin:NO];
    _host = nil;
    
#if kIsUseAVSDKAsLiveScene
    [TCAVSharedContext destroyContextCompletion:nil];
#endif
    
}

- (void)offlineLogin
{
    // 被踢下线，则清空单例中的数据，再登录后再重新创建
    [self saveToLocal];
    
    _contactMgr = nil;
    
    [[TIMManager sharedInstance] removeMessageListener:_conversationMgr];
    _conversationMgr = nil;
}

- (void)logout:(TIMLoginSucc)succ fail:(TIMFail)fail
{
    __weak IMAPlatform *ws = self;
    
    [[TIMManager sharedInstance] logout:^{
        [ws onLogoutCompletion];
        if (succ)
        {
            succ();
        }
    } fail:^(int code, NSString *err) {
        [ws onLogoutCompletion];
        if (fail)
        {
            fail(code, err);
        }
    }];
}

- (IMAPlatformConfig *)localConfig
{
    return _host.loginParm.config;
}

- (void)configHost:(TIMLoginParam *)param
{
    if (!_host)
    {
        if (kHostClass == Nil)
        {
            kHostClass = [IMAHost class];
        }
        _host = [[kHostClass alloc] init];
    }
    _host.loginParm = param;
    [_host asyncProfile];
    
#if kIsUseAVSDKAsLiveScene
    [TCAVSharedContext configWithStartedContext:_host completion:nil];
#endif
}


- (void)changeToNetwork:(TCQALNetwork)work
{
    if (work > EQALNetworkType_ReachableViaWWAN)
    {
        // 不处理这些
        work = EQALNetworkType_ReachableViaWWAN;
    }
    DebugLog(@"网络切换到(-1:未知 0:无网 1:wifi 2:移动网):%d", work);
    //    if (work != _networkType)
    //    {
    self.networkType = work;
    
    //    }
}


@end



