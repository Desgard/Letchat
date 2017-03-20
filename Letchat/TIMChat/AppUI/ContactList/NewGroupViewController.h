//
//  NewGroupViewController.h
//  TIMChat
//
//  Created by AlexiChen on 16/3/1.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "BaseViewController.h"

@interface NewChatGroupViewController : BaseViewController
{
@protected
    UILabel         *_nameTip;
    
    UIView          *_nameBack;
    UITextField     *_textField;
    
    UIButton        *_createButton;
}
- (void)onCreateGroupSucc:(IMAGroup *)group;
@end

@interface NewPublicGroupViewController : NewChatGroupViewController

@end

@interface NewChatRoomViewController : NewChatGroupViewController

@end
