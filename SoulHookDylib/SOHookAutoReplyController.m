//
//  SOHookAutoReplyController.m
//  SoulHookDylib
//
//  Created by 月成 on 2019/7/17.
//  Copyright © 2019 fancy. All rights reserved.
//

#import "SOHookAutoReplyController.h"
#import "SOHookSettingController.h"

@interface SOHookAutoReplyController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray <NSArray *> *dataSource;
@property (nonatomic, strong) UIBarButtonItem *rightBarButtonItem;

@end

@implementation SOHookAutoReplyController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = @"自动回复设置";
    self.navigationItem.rightBarButtonItem = self.rightBarButtonItem;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat top = 44 + [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat bottom = 0;
    if (@available(iOS 11.0, *)) {
        bottom = self.view.safeAreaInsets.bottom;
    }
    
    self.tableView.frame = CGRectMake(0, top, self.view.bounds.size.width,  self.view.bounds.size.height - top - bottom);
}

#pragma mark - Tablke
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UISwitch *view = [cell.contentView viewWithTag:1000];
    if (!view) {
        view = [[UISwitch alloc] init];
        view.tag = 1000;
        view.frame = CGRectMake(self.view.bounds.size.width - 15 - 51, (50 - 31) / 2, 51, 31);
        [view addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:view];
    }
    
    NSDictionary *dic = self.dataSource[indexPath.section][indexPath.row];
    
    cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    cell.textLabel.text = [dic valueForKey:@"title"];
    view.on = [[dic valueForKey:@"enable"] boolValue];
    view.hidden = !(indexPath.section == 0 || indexPath.section == 1);
    
    if (indexPath.section == 3) {
        cell.accessoryType = [[dic valueForKey:@"enable"] boolValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 1:
        case 2:
            return 15;
            break;
        default:
            return 30;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 2:
            return @"关键词";
            break;
        case 3:
            return @"自动回复文本";
            break;
        default:
            return nil;
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 88)];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 3) {
        [self.dataSource[indexPath.section] enumerateObjectsUsingBlock:^(NSMutableDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj[@"enable"] = @(0);
        }];
        
        NSMutableDictionary *dic = self.dataSource[indexPath.section][indexPath.row];
        dic[@"enable"] = @(1);
        
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationNone];
        
        [[NSUserDefaults standardUserDefaults] setObject:self.dataSource[3] forKey:SOUL_HOOK_AUTO_REPLY_TEXTS];
    }
}

#pragma mark - Action
- (void)switchAction:(UISwitch *)sender {
    NSIndexPath *indexPath = [self indexPathForRowAtView:sender];
    
    NSDictionary *dic1 = self.dataSource[indexPath.section][indexPath.row];
    [dic1 setValue:[NSNumber numberWithBool:sender.on] forKey:@"enable"];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:sender.on forKey:[dic1 valueForKey:@"type"]];
    
    NSDictionary *dic2 = (indexPath.section == 0) ? self.dataSource[1][0] : self.dataSource[0][0];
    
    UISwitch *aSwitch = [[self.tableView cellForRowAtIndexPath:(indexPath.section == 0) ? [NSIndexPath indexPathForRow:0 inSection:1] : [NSIndexPath indexPathForRow:0 inSection:0]] viewWithTag:1000];
    if (sender.on) {
        [userDefaults setBool:NO forKey:[dic2 valueForKey:@"type"]];
        aSwitch.on = NO;
    }
    
    [userDefaults synchronize];
    
}

- (NSIndexPath *)indexPathForRowAtView:(UIView *)view {
    if (!view || !view.superview) {
        return nil;
    }
    
    if ([view isKindOfClass:[UITableViewCell class]] && ([NSStringFromClass(view.superview.class) isEqualToString:@"UITableViewWrapperView"] ? view.superview.superview : view.superview) == self.tableView) {
        // iOS 11 下，cell.superview 是 UITableView，iOS 11 以前，cell.superview 是 UITableViewWrapperView
        return [self.tableView indexPathForCell:(UITableViewCell *)view];
    }
    
    return [self indexPathForRowAtView:view.superview];
}

#pragma mark - Get
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 50;
        _tableView.tableFooterView = [UIView new];
        
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
        if (@available(iOS 11, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
    }
    return _tableView;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        NSMutableDictionary *item0 = @{@"title" : @"自动回复所有消息",
                                       @"enable" : [NSNumber numberWithBool:[userDefaults boolForKey:SOUL_HOOK_AUTO_REPLY_ALL_SWITCH]],
                                       @"type" : SOUL_HOOK_AUTO_REPLY_ALL_SWITCH
                                       }.mutableCopy;
        
        NSMutableDictionary *item1 = @{@"title" : @"自动回复带关键词消息",
                                       @"enable" : [NSNumber numberWithBool:[userDefaults boolForKey:SOUL_HOOK_AUTO_REPLY_KEY_SWITCH]],
                                       @"type" : SOUL_HOOK_AUTO_REPLY_KEY_SWITCH
                                       }.mutableCopy;
        
        NSMutableArray *keys = [[[NSUserDefaults standardUserDefaults] objectForKey:SOUL_HOOK_AUTO_REPLY_KEYS] mutableCopy];
        if (!keys.count) {
            keys = [self defaultKeys];
        } else {
            NSMutableArray *arr = [NSMutableArray array];
            
            [keys enumerateObjectsUsingBlock:^(NSDictionary  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [arr addObject:obj.mutableCopy];
            }];
            
            keys = arr;
        }
        
        NSMutableArray *texts = [[[NSUserDefaults standardUserDefaults] objectForKey:SOUL_HOOK_AUTO_REPLY_TEXTS] mutableCopy];
        if (!texts.count) {
            texts = [self defaultTexts];
        } else {
            NSMutableArray *arr = [NSMutableArray array];
            
            [texts enumerateObjectsUsingBlock:^(NSDictionary  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [arr addObject:obj.mutableCopy];
            }];
            
            texts = arr;
        }
        
        _dataSource = @[@[item0], @[item1], keys, texts].mutableCopy;
    }
    return _dataSource;
}

- (NSMutableArray *)defaultKeys {
    NSMutableDictionary *item0 = @{@"title" : @"头像"
                                   }.mutableCopy;
    NSMutableDictionary *item1 = @{@"title" : @"秃"
                                   }.mutableCopy;
    NSMutableDictionary *item2 = @{@"title" : @"头发"
                                   }.mutableCopy;
    NSMutableDictionary *item3 = @{@"title" : @"加班"
                                   }.mutableCopy;
    NSMutableDictionary *item4 = @{@"title" : @"格子衫"
                                   }.mutableCopy;
    
    NSArray *defaultKeys = @[item0, item1, item2, item3, item4];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:defaultKeys forKey:SOUL_HOOK_AUTO_REPLY_KEYS];
    
    return defaultKeys.mutableCopy;
}

- (NSMutableArray *)defaultTexts {
    NSMutableDictionary *item0 = @{@"title" : @"不好意思，还在工作中，不方便回复，等我下班吧",
                                   @"enable" : @(1),
                                   }.mutableCopy;
    
    NSMutableDictionary *item1 = @{@"title" : @"不好意思，在吃饭呢，不方便回复，等我一下吧",
                                   @"enable" : @(0),
                                   }.mutableCopy;
    
    NSMutableDictionary *item2 = @{@"title" : @"不好意思，不方便回复，等我一下吧",
                                   @"enable" : @(0),
                                   }.mutableCopy;
    
    NSArray *defaultTexts = @[item0, item1, item2];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:defaultTexts forKey:SOUL_HOOK_AUTO_REPLY_TEXTS];
    
    return defaultTexts.mutableCopy;
}

@end
