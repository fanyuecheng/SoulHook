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

#pragma mark - Table
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
        case 0:
        case 1:
            return 10;
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5;
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

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section == 2 || indexPath.section == 3);
}
// <iOS 11
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self deleteItemWithIndexPath:indexPath];
}
// <iOS 11
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}
// >iOS 11
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) {
    UIContextualAction *action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
      
        [self deleteItemWithIndexPath:indexPath];
        completionHandler(YES);
    }];
 
    action.backgroundColor = [UIColor systemRedColor];
    
    UISwipeActionsConfiguration *configuration = [UISwipeActionsConfiguration configurationWithActions:@[action]];
    configuration.performsFirstActionWithFullSwipe = NO;
    
    return configuration;
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

- (void)deleteItemWithIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *items = (NSMutableArray *)self.dataSource[indexPath.section];
    [items removeObjectAtIndex:indexPath.row];
    [self.tableView reloadData];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:items forKey:indexPath.section == 2 ? SOUL_HOOK_AUTO_REPLY_KEYS : SOUL_HOOK_AUTO_REPLY_TEXTS];
}

- (void)addAction:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"添加关键词或自动回复文本" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
       }];
    
    UIAlertAction *key = [UIAlertAction actionWithTitle:@"关键词" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self addText:YES];
    }];
    
    UIAlertAction *text = [UIAlertAction actionWithTitle:@"文本" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self addText:NO];
    }];
    
    [alertController addAction:key];
    [alertController addAction:text];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)addText:(BOOL)isKey {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:isKey ? @"添加关键词" : @"添加自动回复文本" message:nil preferredStyle:UIAlertControllerStyleAlert];
      
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    
    __weak __typeof(self)weakSelf = self;
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
      __strong __typeof(weakSelf)strongSelf = weakSelf;
      [alertController dismissViewControllerAnimated:YES completion:nil];
      UITextField *textField = alertController.textFields[0];
      
      NSMutableArray *items = (NSMutableArray *)strongSelf.dataSource.lastObject;
      if (textField.text.length) {
          [items addObject:isKey ? @{@"title" : textField.text}.mutableCopy : @{@"title" : textField.text, @"enable" : @(0)}.mutableCopy];
          [strongSelf.tableView reloadData];
          
          NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
          [userDefaults setObject:items forKey:isKey ? SOUL_HOOK_AUTO_REPLY_KEYS :  SOUL_HOOK_AUTO_REPLY_TEXTS];
      }
    }];

    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
      textField.placeholder = @"自动回复文本";
    }];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)goIdAcion:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"输入对方ID" message:nil preferredStyle:UIAlertControllerStyleAlert];
      
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
 
    __weak __typeof(self)weakSelf = self;
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [alertController dismissViewControllerAnimated:YES completion:nil];
        UITextField *textField = alertController.textFields[0];

        if (textField.text.length) {
            Class clz = NSClassFromString(@"StrangerViewController");
            UIViewController *vc = (UIViewController *)[clz new];
            [vc setValue:textField.text forKey:@"userID"];
            [strongSelf.navigationController pushViewController:vc animated:YES];
        }
    }];

    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
      textField.placeholder = @"对方ID";
    }];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)valueAcion:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"匹配值" message:nil preferredStyle:UIAlertControllerStyleAlert];
         
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
       
        [alertController dismissViewControllerAnimated:YES completion:nil];
        UITextField *textField = alertController.textFields[0];

        if (textField.text.length) {
            [[NSUserDefaults standardUserDefaults] setDouble:[textField.text doubleValue] forKey:SOUL_HOOK_MATCH_VALUE];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }];

    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"0 ~ 100";
    }];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Get
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 50;
        
        CGFloat w = [UIScreen mainScreen].bounds.size.width;
        
        UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, w * 0.5, 50)];
        [button1 setTitle:@"去指定用户主页" forState:UIControlStateNormal];
        [button1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button1 addTarget:self action:@selector(goIdAcion:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(w * 0.5, 0, w * 0.5, 50)];
        [button2 setTitle:@"自定义匹配度" forState:UIControlStateNormal];
        [button2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button2 addTarget:self action:@selector(valueAcion:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, 50)];
        [header addSubview:button1];
        [header addSubview:button2];
        
        _tableView.tableHeaderView = header;
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

- (UIBarButtonItem *)rightBarButtonItem {
    if (!_rightBarButtonItem) {
        _rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction:)];
    }
    return _rightBarButtonItem;
}

@end
