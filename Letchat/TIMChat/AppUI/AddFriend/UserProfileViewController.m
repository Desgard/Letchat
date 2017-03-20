//
//  AddUserProfileViewController.m
//  TIMChat
//
//  Created by AlexiChen on 16/2/23.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "AddUserProfileViewController.h"

#import "SubGroupPickerViewController.h"

@interface AddUserProfileViewController ()

@end



typedef NS_ENUM(NSInteger, UserProfileSection) {
    EUserProfileSection_BaseInfo,
    EUserProfileSection_Remark,
    EUserProfileSectionCount,
};


typedef NS_ENUM(NSInteger, UserProfileBaseInfo) {
    EUserProfileBaseInfo_UserId,
    EUserProfileBaseInfo_NickName,
    EUserProfileBaseInfo_SubGroup,
    EUserProfileBaseInfo_Count
};


@implementation AddUserProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _selectedSubGroup = [[IMAPlatform sharedInstance].contactMgr defaultAddToSubGroup];
}
- (void)addHeaderView
{
    
}

- (void)addFooterView
{
    
}

- (void)addRefreshScrollView
{
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.frame = self.view.bounds;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = RGB(240, 240, 240);
    _tableView.scrollsToTop = YES;
    [self.view addSubview:_tableView];
    
    _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.refreshScrollView = _tableView;
}

- (void)addOwnViews
{
    [super addOwnViews];
    
    ImageTitleButton *userIcon = [[ImageTitleButton alloc] initWithStyle:EImageTopTitleBottom];
    userIcon.imageSize = CGSizeMake(80, 80);
    userIcon.frame = CGRectMake(0, 0, self.view.bounds.size.width, 160);
    userIcon.margin = UIEdgeInsetsMake(20, 0, 20, 0);
    userIcon.imageView.layer.cornerRadius = 40;
    userIcon.imageView.layer.masksToBounds = YES;
    userIcon.titleLabel.textAlignment = NSTextAlignmentCenter;
    [userIcon sd_setImageWithURL:[_userProfile showIconUrl] forState:UIControlStateNormal placeholderImage:kDefaultUserIcon];
    [userIcon setTitle:[_userProfile showTitle] forState:UIControlStateNormal];
    _tableView.tableHeaderView = userIcon;
    
    [self addTableFooter];
}


- (void)addTableFooter
{
    
}

- (BOOL)hasData
{
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return EUserProfileSectionCount;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == EUserProfileSection_Remark)
    {
        return @"附加信息";
    }
    else
    {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case EUserProfileSection_BaseInfo:
            return EUserProfileBaseInfo_Count;
            break;
        case EUserProfileSection_Remark:
            return 1;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case EUserProfileSection_BaseInfo:
        {
            switch (indexPath.row)
            {
                case EUserProfileBaseInfo_UserId:
                {
                    TipTextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserID"];
                    if (!cell)
                    {
                        cell = [[TipTextFieldTableViewCell alloc] initWith:@"帐号ID" placeHolder:nil editAction:nil reuseIdentifier:@"UserID"];
                        cell.editable = NO;
                        cell.tipWidth = 80;
                    }
                    
                    cell.edit.text = [_userProfile showTitle];
                    return cell;
                }
                    
                    break;
                case EUserProfileBaseInfo_NickName:
                {
                    TipTextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NickName"];
                    if (!cell)
                    {
                        cell = [[TipTextFieldTableViewCell alloc] initWith:@"备注名" placeHolder:nil editAction:nil reuseIdentifier:@"NickName"];
                        cell.tipWidth = 80;
                        cell.editable = YES;
                    }
                    
                    cell.edit.text = [_userProfile showTitle];
                    return cell;
                }
                    
                    break;
                case EUserProfileBaseInfo_SubGroup:
                {
                    
                    TipTextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SubGroup"];
                    if (!cell)
                    {
                        __weak AddUserProfileViewController *ws = self;
                        cell = [[TipTextFieldTableViewCell alloc] initWith:@"分组" placeHolder:nil editAction:^BOOL(TextFieldTableViewCell *cell) {
                            SubGroupPickerViewController *vc = [[SubGroupPickerViewController alloc] initWithCompletion:^(SubGroupPickerViewController *selfPtr, BOOL isFinished) {
                                ws.selectedSubGroup = selfPtr.selectedSubGroup;
                                TipTextFieldTableViewCell *subGroupCell = [ws.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:EUserProfileBaseInfo_SubGroup inSection:EUserProfileSection_BaseInfo]];
                                subGroupCell.edit.text = [ws.selectedSubGroup showTitle];
                            }];
                            vc.selectedSubGroup = ws.selectedSubGroup;
                            [ws.navigationController pushViewController:vc animated:YES];
                            
                            
                            return NO;
                        } reuseIdentifier:@"SubGroup"];
                        cell.tipWidth = 80;
                    }
                    
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    
                    cell.edit.text = [self.selectedSubGroup showTitle];
                    return cell;
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case EUserProfileSection_Remark:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Remark"];
            if (!cell)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Remark"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            //            cell.textLabel.text = @"分组";
            //            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
            break;
        default:
            return 0;
            break;
    }
    return nil;
}

@end
