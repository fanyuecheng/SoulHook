//
//  SOHomeHeaderView.h
//  SoulHookDylib
//
//  Created by fan on 2019/7/21.
//  Copyright © 2019 fancy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define SOHOOK_NOTIFICATION_USER_DATA   @"SOHOOK_NOTIFICATION_USER_DATA"

@interface SOHomeHeaderView : UIView

- (void)configViewWithOffset:(CGFloat)offset;

@property (nonatomic, copy) void (^bgBlock)(void);
@property (nonatomic, copy) void (^avatarBlock)(void);
@property (nonatomic, copy) void (^nameBlock)(void);
@property (nonatomic, copy) void (^kkBlock)(void);
@property (nonatomic, copy) void (^visitBlock)(void);
@property (nonatomic, copy) void (^tagBlock)(void);

@end

NS_ASSUME_NONNULL_END
