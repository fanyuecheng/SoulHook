//
//  SOHookChatManager.h
//  SoulHookDylib
//
//  Created by 月成 on 2019/7/17.
//  Copyright © 2019 fancy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define SOUL_HOOK_NOTI_CHAT_MESSAGE_RECEIVED  @"SOUL_HOOK_NOTI_CHAT_MESSAGE_RECEIVED"

@interface SOHookChatManager : NSObject

+ (instancetype)sharedInstance;
- (void)addMessageObserver;

@end

NS_ASSUME_NONNULL_END
