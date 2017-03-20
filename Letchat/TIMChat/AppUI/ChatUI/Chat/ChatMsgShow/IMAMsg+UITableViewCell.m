//
//  IMAMsg+UITableViewCell.m
//  TIMChat
//
//  Created by AlexiChen on 16/3/8.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "IMAMsg+UITableViewCell.h"

@implementation IMAMsg (UITableViewCell)


static NSString *const kIMAMsgShowHeightInChat = @"kIMAMsgShowHeightInChat";
static NSString *const kIMAMsgShowContentSizeInChat = @"kIMAMsgShowContentSizeInChat";
static NSString *const kIMAMsgShowChatAttributedText = @"kIMAMsgShowChatAttributedText";
//static NSString *const kIMAMsgShowLastMsgAttributedText = @"kIMAMsgShowLastMsgAttributedText";

- (CGFloat)showHeightInChat
{
    NSNumber *num = objc_getAssociatedObject(self, (__bridge const void *)kIMAMsgShowHeightInChat);
    return [num floatValue];
}

- (void)setShowHeightInChat:(CGFloat)showHeightInChat
{
    objc_setAssociatedObject(self, (__bridge const void *)kIMAMsgShowHeightInChat, @(showHeightInChat), OBJC_ASSOCIATION_RETAIN);
}

- (CGSize)showContentSizeInChat
{
    NSValue *num = objc_getAssociatedObject(self, (__bridge const void *)kIMAMsgShowContentSizeInChat);
    return [num CGSizeValue];
}

- (void)setShowContentSizeInChat:(CGSize)showContentSizeInChat
{
    objc_setAssociatedObject(self, (__bridge const void *)kIMAMsgShowContentSizeInChat, [NSValue valueWithCGSize:showContentSizeInChat], OBJC_ASSOCIATION_RETAIN);
}

- (NSAttributedString *)showChatAttributedText
{
    NSAttributedString *string = objc_getAssociatedObject(self, (__bridge const void *)kIMAMsgShowChatAttributedText);
    if (!string)
    {
        NSAttributedString *ats = [self loadShowChatAttributedText];
        self.showChatAttributedText = ats;
        return ats;
        
    }
    return string;
}

- (NSAttributedString *)loadShowChatAttributedText
{
    NSMutableAttributedString *ats = [[NSMutableAttributedString alloc] init];
    NSInteger loc = 0;
    for (int i = 0; i < self.msg.elemCount; i++)
    {
        TIMElem *e = [self.msg getElem:i];
        NSArray *array = [e chatAttachmentOf:self];
        for (NSAttributedString *ca in array)
        {
            [ats appendAttributedString:ca];
            // 移动光标
            loc += ca.length;
        }
    }
    return ats;
}

- (void)setShowChatAttributedText:(NSAttributedString *)showChatAttributedText
{
    objc_setAssociatedObject(self, (__bridge const void *)kIMAMsgShowChatAttributedText, showChatAttributedText, OBJC_ASSOCIATION_RETAIN);
}


- (NSAttributedString *)showDraftMsgAttributedText
{
    NSMutableAttributedString *ats = [[NSMutableAttributedString alloc] init];
    NSInteger loc = 0;
    for (int i = 0; i < self.msgDraft.elemCount; i++)
    {
        TIMElem *e = [self.msgDraft getElem:i];
        NSArray *array = [e singleAttachmentOf:self];
        for (NSAttributedString *ca in array)
        {
            [ats appendAttributedString:ca];
            // 移动光标
            loc += ca.length;
        }
    }
    return ats;
}

- (NSAttributedString *)showLastMsgAttributedText
{
//    NSAttributedString *string = objc_getAssociatedObject(self, (__bridge const void *)kIMAMsgShowLastMsgAttributedText);
//    if (!string)
//    {
        NSAttributedString *ats = [self loadShowLastMsgAttributedText];
//        self.showLastMsgAttributedText = ats;
        return ats;
        
//    }
//    return string;
}

- (NSAttributedString *)loadShowLastMsgAttributedText
{
    NSMutableAttributedString *ats = [[NSMutableAttributedString alloc] init];
    NSInteger loc = 0;
    for (int i = 0; i < self.msg.elemCount; i++)
    {
        TIMElem *e = [self.msg getElem:i];
        NSArray *array = [e singleAttachmentOf:self];
        for (NSAttributedString *ca in array)
        {
            [ats appendAttributedString:ca];
            // 移动光标
            loc += ca.length;
        }
    }
    return ats;
}

- (void)setShowLastMsgAttributedText:(NSAttributedString *)showLastMsgAttributedText
{
//    objc_setAssociatedObject(self, (__bridge const void *)kIMAMsgShowLastMsgAttributedText, showLastMsgAttributedText, OBJC_ASSOCIATION_RETAIN);
}


- (NSString *)msgCellReuseIndentifier
{
    return [NSString stringWithFormat:@"IMAMsgCell_%d", (int)_type];
}

- (Class)showCellClass
{
#if kTestChatAttachment
    
    if ([self isMultiMsg])
    {
        switch (self.type)
        {
            case EIMAMSG_GroupTips:
                return [ChatGroupTipTableViewCell class];
                break;
            case EIMAMSG_TimeTip:
                return [ChatTimeTipTableViewCell class];
                break;
            case EIMAMSG_SaftyTip:
                return [ChatSaftyTipTableViewCell class];
                break;
            default:
                return [RichChatTableViewCell class];
                break;
        }
    }
    else
#endif
    {
        // 目前TIMMessage里面只有一个element，可以这样写
        TIMElem *elem = [_msg getElem:0];
        return [elem showCellClassOf:self];
    }
}

- (UITableViewCell<TIMElemAbleCell> *)tableView:(UITableView *)tableView style:(TIMElemCellStype)style
{
    NSString *reuseid = [self msgCellReuseIndentifier];
    TIMElemBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseid];
    if (!cell)
    {
        if (style == TIMElemCell_C2C)
        {
            cell = [[[self showCellClass] alloc] initWithC2CReuseIdentifier:reuseid];
        }
        else if (style == TIMElemCell_Group)
        {
            cell = [[[self showCellClass] alloc] initWithGroupReuseIdentifier:reuseid];
        }
        else
        {
            DebugLog(@"不支持该类型的Cell，请检查代码逻辑");
            NSException *e = [NSException exceptionWithName:@"不支持该类型的Cell" reason:@"不支持该类型的Cell" userInfo:nil];
            @throw e;
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    if (cell == nil)
    {
        DebugLog(@"不支持该类型的Cell，请检查代码逻辑");
        NSException *e = [NSException exceptionWithName:@"不支持该类型的Cell" reason:@"不支持该类型的Cell" userInfo:nil];
        @throw e;
    }
    return cell;
}

- (UIFont *)inputTextFont
{
    return kIMAMiddleTextFont;
}

- (UIColor *)inputTextColor
{
    return kBlackColor;
}

- (UIFont *)textFont
{
    return kIMAMiddleTextFont;
}
- (UIColor *)textColor
{
    if ([self isMineMsg])
    {
        return kWhiteColor;
    }
    else
    {
        return kBlackColor;
    }
}

- (UIFont *)tipFont
{
    return kIMASmallTextFont;
}
- (UIColor *)tipTextColor
{
    if ([self isMsgDraft])
    {
        return kLightGrayColor;
    }
    return [self isMineMsg] ? self.status == EIMAMsg_SendSucc ? kLightGrayColor : kRedColor : kLightGrayColor;
}

- (NSInteger)contentMaxWidth;
{
    return (NSInteger)(kMainScreenWidth * 0.6);
}

- (NSInteger)heightInWidth:(CGFloat)width inStyle:(BOOL)isGroup
{
    if (self.showHeightInChat != 0)
    {
        return self.showHeightInChat;
    }
    
    if (self.type == EIMAMSG_TimeTip || self.type == EIMAMSG_SaftyTip)
    {
        // 时间标签显示20
        self.showHeightInChat = 20;
        return self.showHeightInChat;
    }
    
    CGSize size = [self contentBackSizeInWidth:width];
    
    if (self.type == EIMAMSG_GroupTips)
    {
        self.showHeightInChat = size.height;
        return size.height;
    }
    
    
    if (isGroup && ![self isMineMsg])
    {
        size.height += [self groupMsgTipHeight];
    }
    size.height += kDefaultMargin;
    
    CGSize iconSize = [self userIconSize];
    if (size.height < iconSize.height + kDefaultMargin)
    {
        size.height = iconSize.height + kDefaultMargin;
    }
    self.showHeightInChat = size.height;
    return size.height;
    
}

- (UIEdgeInsets)contentBackInset
{
    
    if (self.isMineMsg)
    {
        return UIEdgeInsetsMake(kDefaultMargin/2 + 1, kDefaultMargin/2, kDefaultMargin/2 + 1, kDefaultMargin + 1);
    }
    else
    {
        return UIEdgeInsetsMake(kDefaultMargin/2 + 1, kDefaultMargin + 2, kDefaultMargin/2 + 1, kDefaultMargin/2 + 1);
    }
}

- (NSInteger)pickedViewWidth
{
    return 32;
}
- (CGSize)userIconSize
{
    return CGSizeMake(32, 32);
}
- (NSInteger)sendingTipWidth
{
    return 24;
}

- (NSInteger)groupMsgTipHeight
{
    return 20;
}

- (NSInteger)horMargin
{
    return kDefaultMargin;
}

// 当正在Picked的时候
- (CGSize)contentBackSizeInWidth:(CGFloat)width
{
    NSInteger horMargin = [self horMargin];
    CGSize size = CGSizeMake(width, HUGE_VALF);
    if (self.isPicked)
    {
        // 在勾选状态
        size.width -= horMargin + [self pickedViewWidth] + horMargin + [self sendingTipWidth] + horMargin + horMargin + [self userIconSize].width + horMargin;
        size = [self contentSizeInWidth:size.width];
    }
    else
    {
        // 在非勾选状态下
        size.width -= horMargin + [self sendingTipWidth] + horMargin + horMargin + [self userIconSize].width + horMargin;
        size = [self contentSizeInWidth:size.width];
    }
    
    if (self.type == EIMAMSG_GroupTips)
    {
        return size;
    }
    
    
    UIEdgeInsets inset = [self contentBackInset];
    size.width += inset.left + inset.right;
    size.height += inset.top + inset.bottom;
    
    return size;
}

// 只算内容的size
- (CGSize)contentSizeInWidth:(CGFloat)width
{
    if (self.showContentSizeInChat.width != 0)
    {
        return self.showContentSizeInChat;
    }
    
    NSInteger max = [self contentMaxWidth];
    if (width > max)
    {
        width = max;
    }
    CGFloat h = 0;
    CGFloat w = 0;
    
    if ([self isMultiMsg])
    {
        self.showContentSizeInChat = [self multiContentSizeInWidth:width];
        return self.showContentSizeInChat;
    }
    else
    {
        // 本质上只有一个element
        // 目前大部份都是只有一个elemment，后面有多个element的时候再作处理
        for (int i = 0; i < [_msg elemCount]; i++)
        {
            TIMElem *elem = [_msg getElem:i];
            CGSize size = [elem sizeInWidth:width atMsg:self];
            h += size.height;
            if (w < size.width)
            {
                w = size.width;
            }
        }
    }
    
    self.showContentSizeInChat = CGSizeMake(w, h);
    return self.showContentSizeInChat;
}


// 用于计算显示的文本高度
static ChatTextView *kSharedTextView = nil;

- (CGSize)multiContentSizeInWidth:(CGFloat)width
{
    if (!kSharedTextView)
    {
        kSharedTextView = [[ChatTextView alloc] init];
    }
    
    // 设置一个最大值
    kSharedTextView.frame = CGRectMake(0, 0, width, 1024 * 100);
    
    [kSharedTextView showMessage:self];
    
    CGRect rect = [kSharedTextView.layoutManager usedRectForTextContainer:kSharedTextView.textContainer];
    
    return rect.size;
}

- (void)updateElem:(TIMElem *)elem attachmentChanged:(NSTextAttachment *)att
{
    // 更新产变更的att
    self.showChatAttributedText = [self loadShowChatAttributedText];
    [[NSNotificationCenter defaultCenter] postNotificationName:kIMAMSG_ChangedNotification object:self];
}

- (void)prepareChatForReuse
{
    self.showChatAttributedText = nil;
}


@end
