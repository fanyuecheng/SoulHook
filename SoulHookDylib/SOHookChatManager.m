//
//  SOHookChatManager.m
//  SoulHookDylib
//
//  Created by 月成 on 2019/7/17.
//  Copyright © 2019 fancy. All rights reserved.
//

#import "SOHookChatManager.h"
#import "SoulHeader.h"
#import "SOHookSettingController.h"

@interface SOHookChatManager ()

@end

@implementation SOHookChatManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static SOHookChatManager *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

- (void)dealloc {
    [self removeObserver];
}

#pragma mark - Method
- (void)addMessageObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessage:) name:SOUL_HOOK_NOTI_CHAT_MESSAGE_RECEIVED object:nil];
}

- (void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Noti
- (void)receiveMessage:(NSNotification *)sender {
    IMPCommandMessage *msg = sender.object;
 
    IMPMsgCommand *msgCommand = [msg valueForKey:@"msgCommand"];
 
    BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_AUTO_REPLY_ALL_SWITCH];
    
    if (enable) {
        //0=text 1=image 3=video 4=voice 8=RECALL 11=finger 12=dice 29=position
        if (msgCommand.type == 1 ||
            msgCommand.type == 3 ||
            msgCommand.type == 4 ||
            msgCommand.type == 11 ||
            msgCommand.type == 12 ||
            msgCommand.type == 29 ||
            (msgCommand.type == 0 && msgCommand.textMsg)) {
            
            SoulIMMessage *mesage = [SoulIMMessage new];
            
            TextIMModel *text = [TextIMModel new];
            text.text = @"你好，我现在不方便回消息";
 
            Class clz = NSClassFromString(@"NBIMService");
            SEL instance = NSSelectorFromString(@"sharedInstance");
            IMP imp = [clz methodForSelector:instance];
            id (*func)(id, SEL) = (void *)imp;
            id manager = func(clz, instance);
            
            ChatTransCenter *chatCenter = [manager valueForKey:@"chatCenter"];
            
            [chatCenter sendCommandsMessage:mesage completion:nil];
        }
    }
    
}

@end
