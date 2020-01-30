//
//  SOHookSettingController.m
//  SoulHook
//
//  Created by 月成 on 2019/6/25.
//  Copyright © 2019 fancy. All rights reserved.
//

#import "SOHookSettingController.h"
#import "SOHookAutoReplyController.h"

@interface SOHookSettingController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy)   NSArray     *dataSource;
@property (nonatomic, strong) UIBarButtonItem *leftBarButtonItem;

@end

@implementation SOHookSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = @"Hook设置";
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationItem.leftBarButtonItem = self.leftBarButtonItem;
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithWhite:0 alpha:0.8];
    
    NSMutableDictionary *titleTextAttributes = @{}.mutableCopy;
    titleTextAttributes[NSFontAttributeName] = [UIFont systemFontOfSize:17];
    titleTextAttributes[NSForegroundColorAttributeName] = [UIColor colorWithWhite:0 alpha:0.8];
    
    self.navigationController.navigationBar.titleTextAttributes = titleTextAttributes;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES];
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
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
    
    NSDictionary *dic = self.dataSource[indexPath.row];
    
    cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    cell.textLabel.text = [dic valueForKey:@"title"];
    view.on = [[dic valueForKey:@"enable"] boolValue];
    view.hidden = (indexPath.row == 0);
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 88;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 88)];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        SOHookAutoReplyController *aotu = [[SOHookAutoReplyController alloc] init];
        [self.navigationController pushViewController:aotu animated:YES];
    } 
}

#pragma mark - Action
- (void)switchAction:(UISwitch *)sender {
    NSIndexPath *indexPath = [self indexPathForRowAtView:sender];
    NSDictionary *dic = self.dataSource[indexPath.row];
    [dic setValue:[NSNumber numberWithBool:sender.on] forKey:@"enable"];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([dic[@"title"] isEqualToString:@"机器人"] && sender.on) {
        [userDefaults setBool:NO forKey:SOUL_HOOK_AUTO_REPLY_ALL_SWITCH];
        [userDefaults setBool:NO forKey:SOUL_HOOK_AUTO_REPLY_KEY_SWITCH];
    }
    
    [userDefaults setBool:sender.on forKey:[dic valueForKey:@"type"]];
    [userDefaults synchronize];
}

- (void)leftBarButtonItemAction:(id)sender {
    if (self.navigationController.viewControllers.firstObject == self) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
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

- (NSArray *)dataSource {
    if (!_dataSource) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        NSMutableDictionary *item0 = @{@"title" : @"自动回复设置",
                                       @"enable" : @"0",
                                       @"type" : @"0"
                                       }.mutableCopy;
                    
        NSMutableDictionary *item1 = @{@"title" : @"防止消息撤回",
                                       @"enable" : [NSNumber numberWithBool:[userDefaults boolForKey:SOUL_HOOK_MSG_REVOKE_SWITCH]],
                                       @"type" : SOUL_HOOK_MSG_REVOKE_SWITCH
                                       }.mutableCopy;
        
        NSMutableDictionary *item2 = @{@"title" : @"防止阅后即焚",
                                       @"enable" : [NSNumber numberWithBool:[userDefaults boolForKey:SOUL_HOOK_MSG_FLASH_SWITCH]],
                                       @"type" : SOUL_HOOK_MSG_FLASH_SWITCH
                                       }.mutableCopy;
        
        NSMutableDictionary *item3 = @{@"title" : @"点击自动复制消息媒体URL",
                                       @"enable" : [NSNumber numberWithBool:[userDefaults boolForKey:SOUL_HOOK_MSG_COPY_SWITCH]],
                                       @"type" : SOUL_HOOK_MSG_COPY_SWITCH
                                       }.mutableCopy;
        
        NSMutableDictionary *item4 = @{@"title" : @"捏脸道具免费",
                                       @"enable" : [NSNumber numberWithBool:[userDefaults boolForKey:SOUL_HOOK_AVATAR_SWITCH]],
                                       @"type" : SOUL_HOOK_AVATAR_SWITCH
                                       }.mutableCopy;
        
        NSMutableDictionary *item5 = @{@"title" : @"设置头像仅设置背景色",
                                       @"enable" : [NSNumber numberWithBool:[userDefaults boolForKey:SOUL_HOOK_AVATAR_BG_SWITCH]],
                                       @"type" : SOUL_HOOK_AVATAR_BG_SWITCH
                                       }.mutableCopy;
        
        NSMutableDictionary *item6 = @{@"title" : @"设置自定义头像",
                                       @"enable" : [NSNumber numberWithBool:[userDefaults boolForKey:SOUL_HOOK_AVATAR_CUSTOM_SWITCH]],
                                       @"type" : SOUL_HOOK_AVATAR_CUSTOM_SWITCH
                                       }.mutableCopy;
        
        NSMutableDictionary *item7 = @{@"title" : @"掷骰子作弊",
                                       @"enable" : [NSNumber numberWithBool:[userDefaults boolForKey:SOUL_HOOK_DICE_SWITCH]],
                                       @"type" : SOUL_HOOK_DICE_SWITCH
                                       }.mutableCopy;
        
        NSMutableDictionary *item8 = @{@"title" : @"石头剪子布作弊",
                                       @"enable" : [NSNumber numberWithBool:[userDefaults boolForKey:SOUL_HOOK_FINGER_SWITCH]],
                                       @"type" : SOUL_HOOK_FINGER_SWITCH
                                       }.mutableCopy;
        
        NSMutableDictionary *item9 = @{@"title" : @"启动图屏蔽",
                                       @"enable" : [NSNumber numberWithBool:[userDefaults boolForKey:SOUL_HOOK_ADVERT_SWITCH]],
                                       @"type" : SOUL_HOOK_ADVERT_SWITCH
                                       }.mutableCopy;
        
        NSMutableDictionary *item10 = @{@"title" : @"soulmate邀请无限制",
                                        @"enable" : [NSNumber numberWithBool:[userDefaults boolForKey:SOUL_HOOK_SOULMATE_SWITCH]],
                                        @"type" : SOUL_HOOK_SOULMATE_SWITCH
                                        }.mutableCopy;
        
        NSMutableDictionary *item11 = @{@"title" : @"自定义瞬间发布位置",
                                        @"enable" : [NSNumber numberWithBool:[userDefaults boolForKey:SOUL_HOOK_LOCATION_SWITCH]],
                                        @"type" : SOUL_HOOK_LOCATION_SWITCH
                                        }.mutableCopy;
        
        NSMutableDictionary *item12 = @{@"title" : @"修改生日&性别",
                                        @"enable" : [NSNumber numberWithBool:[userDefaults boolForKey:SOUL_HOOK_BIRTHDAY_GENDER_SWITCH]],
                                        @"type" : SOUL_HOOK_BIRTHDAY_GENDER_SWITCH
                                        }.mutableCopy;
        
        NSMutableDictionary *item13 = @{@"title" : @"取消已读回执",
                                        @"enable" : [NSNumber numberWithBool:[userDefaults boolForKey:SOUL_HOOK_READ_SWITCH]],
                                        @"type" : SOUL_HOOK_READ_SWITCH
                                        }.mutableCopy;
        
        NSMutableDictionary *item14 = @{@"title" : @"禁止发送输入状态",
                                        @"enable" : [NSNumber numberWithBool:[userDefaults boolForKey:SOUL_HOOK_INPUT_STATE_SWITCH]],
                                        @"type" : SOUL_HOOK_INPUT_STATE_SWITCH
                                        }.mutableCopy;
        
        NSMutableDictionary *item15 = @{@"title" : @"禁止撤回消息两分钟限制解除",
                                        @"enable" : [NSNumber numberWithBool:[userDefaults boolForKey:SOUL_HOOK_MSG_RECALL_SWITCH]],
                                        @"type" : SOUL_HOOK_MSG_RECALL_SWITCH
                                        }.mutableCopy;
        
        NSMutableDictionary *item16 = @{@"title" : @"存图去除水印",
                                        @"enable" : [NSNumber numberWithBool:[userDefaults boolForKey:SOUL_HOOK_WATER_MARK_SWITCH]],
                                        @"type" : SOUL_HOOK_WATER_MARK_SWITCH
                                        }.mutableCopy;
        
        NSMutableDictionary *item17 = @{@"title" : @"机器人",
        @"enable" : [NSNumber numberWithBool:[userDefaults boolForKey:SOUL_HOOK_ROBOT_SWITCH]],
        @"type" : SOUL_HOOK_ROBOT_SWITCH
        }.mutableCopy;
 
        NSMutableDictionary *item18 = @{@"title" : @"自动已读",
             @"enable" : [NSNumber numberWithBool:[userDefaults boolForKey:SOUL_HOOK_AUTO_READ_KEY_SWITCH]],
             @"type" : SOUL_HOOK_AUTO_READ_KEY_SWITCH
             }.mutableCopy;
        
        _dataSource = @[item0, item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item11, item12, item13, item14, item15, item16, item17, item18];
    }
    return _dataSource;
}

- (UIBarButtonItem *)leftBarButtonItem {
    if (!_leftBarButtonItem) {
        BOOL modar = self.navigationController.viewControllers.firstObject == self;
        _leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:modar ? @"关闭" : @"返回" style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemAction:)];
    }
    return _leftBarButtonItem;
}

@end

@implementation NSArray (SOULLog)

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level {
    NSMutableString *desc = [NSMutableString string];
    
    NSMutableString *tabString = [[NSMutableString alloc] initWithCapacity:level];
    for (NSUInteger i = 0; i < level; ++i) {
        [tabString appendString:@"\t"];
    }
    
    NSString *tab = @"";
    if (level > 0) {
        tab = tabString;
    }
    [desc appendString:@"\t(\n"];
    
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *mark = (self.count - 1 == idx) ? @"" : @",";
        if ([obj isKindOfClass:[NSDictionary class]]
            || [obj isKindOfClass:[NSArray class]]
            || [obj isKindOfClass:[NSSet class]]) {
            NSString *str = [((NSDictionary *)obj) descriptionWithLocale:locale indent:level + 1];
            [desc appendFormat:@"%@\t%@%@\n", tab, str, mark];
        } else if ([obj isKindOfClass:[NSString class]]) {
            [desc appendFormat:@"%@\t\"%@\"%@\n", tab, obj, mark];
        } else if ([obj isKindOfClass:[NSData class]]) {
            
            NSError *error = nil;
            NSObject *result =  [NSJSONSerialization JSONObjectWithData:obj
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&error];
            
            if (error == nil && result != nil) {
                if ([result isKindOfClass:[NSDictionary class]]
                    || [result isKindOfClass:[NSArray class]]
                    || [result isKindOfClass:[NSSet class]]) {
                    NSString *str = [((NSDictionary *)result) descriptionWithLocale:locale indent:level + 1];
                    [desc appendFormat:@"%@\t%@%@\n", tab, str, mark];
                } else if ([obj isKindOfClass:[NSString class]]) {
                    [desc appendFormat:@"%@\t\"%@\"%@\n", tab, result, mark];
                }
            } else {
                @try {
                    NSString *str = [[NSString alloc] initWithData:obj encoding:NSUTF8StringEncoding];
                    if (str != nil) {
                        [desc appendFormat:@"%@\t\"%@\"%@\n", tab, str, mark];
                    } else {
                        [desc appendFormat:@"%@\t%@%@\n", tab, obj, mark];
                    }
                }
                @catch (NSException *exception) {
                    [desc appendFormat:@"%@\t%@%@\n", tab, obj, mark];
                }
            }
        } else {
            [desc appendFormat:@"%@\t%@%@\n", tab, obj, mark];
        }
    }];
    
    [desc appendFormat:@"%@)", tab];
    
    return desc;
}

@end

@implementation NSSet(SOULLog)

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level {
    NSMutableString *desc = [NSMutableString string];
    
    NSMutableString *tabString = [[NSMutableString alloc] initWithCapacity:level];
    for (NSUInteger i = 0; i < level; ++i) {
        [tabString appendString:@"\t"];
    }
    
    NSString *tab = @"\t";
    if (level > 0) {
        tab = tabString;
    }
    [desc appendString:@"\t{(\n"];
    
    for (id obj in self) {
        if ([obj isKindOfClass:[NSDictionary class]]
            || [obj isKindOfClass:[NSArray class]]
            || [obj isKindOfClass:[NSSet class]]) {
            NSString *str = [((NSDictionary *)obj) descriptionWithLocale:locale indent:level + 1];
            [desc appendFormat:@"%@\t%@,\n", tab, str];
        } else if ([obj isKindOfClass:[NSString class]]) {
            [desc appendFormat:@"%@\t\"%@\",\n", tab, obj];
        } else if ([obj isKindOfClass:[NSData class]]) {
            // if is NSData，try parse
            NSError *error = nil;
            NSObject *result =  [NSJSONSerialization JSONObjectWithData:obj
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&error];
            
            if (error == nil && result != nil) {
                if ([result isKindOfClass:[NSDictionary class]]
                    || [result isKindOfClass:[NSArray class]]
                    || [result isKindOfClass:[NSSet class]]) {
                    NSString *str = [((NSDictionary *)result) descriptionWithLocale:locale indent:level + 1];
                    [desc appendFormat:@"%@\t%@,\n", tab, str];
                } else if ([obj isKindOfClass:[NSString class]]) {
                    [desc appendFormat:@"%@\t\"%@\",\n", tab, result];
                }
            } else {
                @try {
                    NSString *str = [[NSString alloc] initWithData:obj encoding:NSUTF8StringEncoding];
                    if (str != nil) {
                        [desc appendFormat:@"%@\t\"%@\",\n", tab, str];
                    } else {
                        [desc appendFormat:@"%@\t%@,\n", tab, obj];
                    }
                }
                @catch (NSException *exception) {
                    [desc appendFormat:@"%@\t%@,\n", tab, obj];
                }
            }
        } else {
            [desc appendFormat:@"%@\t%@,\n", tab, obj];
        }
    }
    
    [desc appendFormat:@"%@)}", tab];
    
    return desc;
}

@end

@implementation NSDictionary (SOULLog)

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level {
    NSMutableString *desc = [NSMutableString string];
    
    NSMutableString *tabString = [[NSMutableString alloc] initWithCapacity:level];
    for (NSUInteger i = 0; i < level; ++i) {
        [tabString appendString:@"\t"];
    }
    
    NSString *tab = @"";
    if (level > 0) {
        tab = tabString;
    }
    
    [desc appendString:@"\t{\n"];
    
    // Through array, self is array
    [self.allKeys enumerateObjectsUsingBlock:^(id  _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *mark = (self.count - 1 == idx) ? @"" : @",";
        
        id obj = [self objectForKey:key];
        
        if ([obj isKindOfClass:[NSString class]]) {
            [desc appendFormat:@"%@\t%@ = \"%@\"%@\n", tab, key, obj, mark];
        } else if ([obj isKindOfClass:[NSArray class]]
                   || [obj isKindOfClass:[NSDictionary class]]
                   || [obj isKindOfClass:[NSSet class]]) {
            [desc appendFormat:@"%@\t%@ = %@%@\n", tab, key, [obj descriptionWithLocale:locale indent:level + 1], mark];
        } else if ([obj isKindOfClass:[NSData class]]) {
            
            NSError *error = nil;
            NSObject *result =  [NSJSONSerialization JSONObjectWithData:obj
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&error];
            
            if (error == nil && result != nil) {
                if ([result isKindOfClass:[NSDictionary class]]
                    || [result isKindOfClass:[NSArray class]]
                    || [result isKindOfClass:[NSSet class]]) {
                    NSString *str = [((NSDictionary *)result) descriptionWithLocale:locale indent:level + 1];
                    [desc appendFormat:@"%@\t%@ = %@%@\n", tab, key, str, mark];
                } else if ([obj isKindOfClass:[NSString class]]) {
                    [desc appendFormat:@"%@\t%@ = \"%@\"%@\n", tab, key, result, mark];
                }
            } else {
                @try {
                    NSString *str = [[NSString alloc] initWithData:obj encoding:NSUTF8StringEncoding];
                    if (str != nil) {
                        [desc appendFormat:@"%@\t%@ = \"%@\"%@\n", tab, key, str, mark];
                    } else {
                        [desc appendFormat:@"%@\t%@ = %@%@\n", tab, key, obj, mark];
                    }
                }
                @catch (NSException *exception) {
                    [desc appendFormat:@"%@\t%@ = %@%@\n", tab, key, obj, mark];
                }
            }
        } else {
            [desc appendFormat:@"%@\t%@ = %@%@\n", tab, key, obj, mark];
        }
    }];
    
    [desc appendFormat:@"%@}", tab];
    
    return desc;
}

@end

/*
 funcSetting =     {
 chatAlbumBar = 1,
 chatCameraBar = 1,
 modifyAgeTxt = "未成年人不可以随意修改年龄哦",
 isTeenageModeChatCard = 0,
 canDoAnonymous = 0,
 age = 20,
 isSubmitTeenMeasure = 1,
 isTeenageMode = 0,
 isTeenageModeHomepage = 0,
 isTeenageModeSquare = 1,
 teenageModelText = "为呵护未成年人健康成长，Soul特别推出青少年模式。如与青少年聊天涉黄，将负刑事责任。",
 teenageModeImageUrl = "https://img.soulapp.cn/501ad314b71362624d1bbe161f974f2d.jpg",
 canViewPlanetAge = 1,
 teenageModeUrl = "https://app.soulapp.cn/app/#/fbi",
 voiceMatchTeenagerText = "对方是青少年，涉黄将负刑事责任",
 isTeenageModeMatch = 0,
 sensitiveWordText = "对方是青少年，骚扰、诈骗、涉黄将负刑事责任"
 },
 */
