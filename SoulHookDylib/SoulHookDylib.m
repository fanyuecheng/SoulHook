//  weibo: http://weibo.com/xiaoqing28
//  blog:  http://www.alonemonkey.com
//
//  SoulHookDylib.m
//  SoulHookDylib
//
//  Created by miniSeven on 2019/12/30.
//  Copyright (c) 2019 fancy. All rights reserved.
//

#import "SoulHookDylib.h"
#import <CaptainHook/CaptainHook.h>
#import <UIKit/UIKit.h>
#import <Cycript/Cycript.h>
#import <MDCycriptManager.h>
#import "SOHeader.h"
#import "SORobot.h"

CHConstructor{
    printf(INSERT_SUCCESS_WELCOME);
 
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
#ifndef __OPTIMIZE__
        CYListenServer(6666);
        
        MDCycriptManager *manager = [MDCycriptManager sharedInstance];
        [manager loadCycript:NO];
        
        NSError *error;
        NSString *result = [manager evaluateCycript:@"UIApp" error:&error];
        NSLog(@"result: %@", result);
        if(error.code != 0){
            NSLog(@"error: %@", error.localizedDescription);
        }
 
#endif
         
        ExtendImplementationOfVoidMethodWithoutArguments([UIViewController class], @selector(viewDidLoad), ^(__kindof UIViewController *selfObject) {
            NSLog(@"class = %@", selfObject.class);
        });
    }];
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"

/*
 1.hook类
 CHDeclareClass(<#name#>)
 
 2.hook类方法
 CHOptimizedClassMethod0(<#optimization#>, <#return_type#>, <#class_type#>, <#name#>)
 
 3.hook对象方法
 CHOptimizedMethod0(<#optimization#>, <#return_type#>, <#class_type#>, <#name#>)
 2.新增函数
 
 1.新增属性
 CHPropertyRetainNonatomic(<#class#>, <#type#>, <#getter#>, <#setter#>)
 
 2.新增方法
 1.新增类方法
 CHDeclareClassMethod0(<#return_type#>, <#class_type#>, <#name#>)
 2.新增对象方法
 CHDeclareMethod0(<#return_type#>, <#class_type#>, <#name#>)
 3.构造函数
 
 CHConstructor{}
 在构造函数中
 CHLoadLateClass(<#name#>);            hook类
 CHClassHook0(<#class#>, <#name#>)     hook方法
 CHHook0(<#class#>, <#name#>)          添加属性时,需要这样写对应的set, get
 
 */

#pragma clang diagnostic pop

//================================Hook================================

//埋点
CHDeclareClass(TalkingData)

CHOptimizedClassMethod2(self, void, TalkingData, sessionStarted, NSString *, appKey, withChannelId, NSString *, channelId) {
    NSLog(@"TalkingData == %@ %@", appKey, channelId);
    return;
}

CHOptimizedClassMethod2(self, void, TalkingData, initWithAppID, NSString *, AppId, channelID, NSString *, channelId) {
    NSLog(@"TalkingData == %@ %@", AppId, channelId);
    return;
}

CHDeclareClass(KochavaTracker)

CHOptimizedMethod2(self, void, KochavaTracker, configureWithParametersDictionary, NSDictionary *, dic, delegate, id, delegate) {
    NSLog(@"KochavaTracker == %@ %@", dic, delegate);
}

CHDeclareClass(Bugly)
CHOptimizedClassMethod1(self, void, Bugly, startWithAppId, NSString *, appId) {
    NSLog(@"Bugly == %@", appId);
    return;
}

CHOptimizedClassMethod2(self, void, Bugly, startWithAppId, NSString *, appId, config, BuglyConfig *, config) {
    NSLog(@"Bugly == %@ %@", appId, config);
    return;
}

//修改头像
CHDeclareClass(AvatarModifyViewController)

CHOptimizedMethod5(self, void, AvatarModifyViewController, updateUserInfWithAvatarName, NSString *, arg1, originAvatarName, NSString *, arg2, image, UIImage *, arg3, originImage, UIImage *, arg4, svgInfo, NSString *, arg5) {
    
    BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_AVATAR_SWITCH];
    if (enable) {
        NSData *jsonData = [arg5 dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&err];
        NSMutableDictionary *svgInfo = [NSMutableDictionary dictionaryWithDictionary:json];
        NSMutableArray *resources = [NSMutableArray array];
        [svgInfo[@"resources"] enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:obj];
            [dic setObject:@0 forKey:@"id"];
            [dic setObject:@[] forKey:@"color"];
            [resources addObject:dic];
        }];
        [svgInfo setObject:resources forKey:@"resources"];
        
        jsonData = [NSJSONSerialization dataWithJSONObject:svgInfo options:0 error:NULL];
        arg5 = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    CHSuper5(AvatarModifyViewController, updateUserInfWithAvatarName, arg1, originAvatarName, arg2, image, arg3, originImage, arg4, svgInfo, arg5);
    
    NSLog(@"AvatarModifyViewController 11 == %@ %@ %@ %@ %@", arg1, arg2, arg3, arg4, arg5);
}

CHOptimizedMethod5(self, void, AvatarModifyViewController, uploadToQiniu, UIImage *, arg1, svginfo, id, arg2, token, NSDictionary *, arg3, imageName, NSString *, arg4, completion, dispatch_block_t, arg5) {
    
    NSLog(@"上传11 %@ %@ %@", arg1, arg3, arg4);
    BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_AVATAR_CUSTOM_SWITCH];
    if (enable) {
        if (arg1.size.width == 520) {
            self.avatarName = [[arg3[@"key"] stringByReplacingOccurrencesOfString:@"heads/" withString:@""] stringByReplacingOccurrencesOfString:@".png" withString:@""];
        } else {
            self.avatarOriginName = [[arg3[@"key"] stringByReplacingOccurrencesOfString:@"heads/" withString:@""] stringByReplacingOccurrencesOfString:@".png" withString:@""];
        }
        
        dispatch_block_t block = ^() {
            if (self.avatarName && self.avatarOriginName && self.customImage) {
                [self updateUserInfWithAvatarName:self.avatarName originAvatarName:self.avatarOriginName image:[self resizeImage:CGSizeMake(520, 520)] originImage:[self resizeImage:CGSizeMake(650, 650)] svgInfo:arg2];
            }
        };
        
        CHSuper5(AvatarModifyViewController, uploadToQiniu, arg1, svginfo, arg2, token, arg3, imageName, arg4, completion, block);
        
    } else {
        CHSuper5(AvatarModifyViewController, uploadToQiniu, arg1, svginfo, arg2, token, arg3, imageName, arg4, completion, arg5);
    }
}

CHOptimizedMethod2(self, void, AvatarModifyViewController, uploadOriginAvatar, UIImage *, arg1, avatarSVGInfo, id, arg2) {
    NSLog(@"上传2 %@", arg1);//650
    BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_AVATAR_CUSTOM_SWITCH];
    if (enable && self.customImage) {
        arg1 = [self resizeImage:CGSizeMake(650, 650)];
    }
    
    CHSuper2(AvatarModifyViewController, uploadOriginAvatar, arg1, avatarSVGInfo, arg2);
}

CHOptimizedMethod2(self, void, AvatarModifyViewController, uploadAvatar, UIImage *, arg1, avatarSVGInfo, id, arg2) {
    NSLog(@"上传3 %@", arg1);//520
    BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_AVATAR_CUSTOM_SWITCH];
    if (enable && self.customImage) {
        arg1 = [self resizeImage:CGSizeMake(520, 520)];
    }
    
    CHSuper2(AvatarModifyViewController, uploadAvatar, arg1, avatarSVGInfo, arg2);
}

CHOptimizedMethod0(self, void, AvatarModifyViewController, viewDidLoad) {
    CHSuper0(AvatarModifyViewController, viewDidLoad);
    BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_AVATAR_CUSTOM_SWITCH];
    
    if (enable) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 175, [UIApplication sharedApplication].statusBarFrame.size.height + 14, 80, 36)];
        button.backgroundColor = SO_THEME_COLOR;
        button.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
        button.layer.cornerRadius = 18;
        button.layer.masksToBounds = YES;
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitle:@"自定义" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(customAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.webView addSubview:button];
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"

CHDeclareMethod1(void, AvatarModifyViewController, customAction, UIButton *, arg1) {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
            // 请在'设置'中打开相机权限
            return;
        }
        
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            // 照相机不可用
            return;
        }
        UIImagePickerController *vc = [[UIImagePickerController alloc] init];
        vc.delegate = self;
        vc.allowsEditing = YES;
        vc.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:vc animated:YES completion:nil];
    }];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UIImagePickerController *vc = [[UIImagePickerController alloc] init];
        vc.delegate = self;
        vc.allowsEditing = YES;
        vc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:vc animated:YES completion:nil];
        
    }];
    
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:action1];
    [alert addAction:action2];
    [alert addAction:action3];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

CHDeclareMethod1(void, AvatarModifyViewController, imagePickerControllerDidCancel, UIImagePickerController *, arg1) {
    self.customImage = nil;
    [arg1 dismissViewControllerAnimated:YES completion:nil];
}

CHDeclareMethod2(void, AvatarModifyViewController, imagePickerController, UIImagePickerController *, arg1, didFinishPickingMediaWithInfo, NSDictionary *, arg2) {
    UIImage *image = [arg2 objectForKey:UIImagePickerControllerEditedImage];
    [arg1 dismissViewControllerAnimated:YES completion:nil];
    
    UIView *contentView = [self.view viewWithTag:1000];
    if (!contentView) {
        contentView = [[UIView alloc] initWithFrame:self.view.bounds];
        contentView.backgroundColor = [UIColor whiteColor];
        contentView.tag = 1000;
        
        CGFloat width = CGRectGetWidth(self.view.frame);
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height + 20, width, width)];
        imageView.tag = 1001;
        
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(imageView.frame) + 30, 100, 44)];
        cancelButton.backgroundColor = SO_THEME_COLOR;
        cancelButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
        cancelButton.layer.cornerRadius = 22;
        cancelButton.layer.masksToBounds = YES;
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(width - 110, CGRectGetMaxY(imageView.frame) + 30, 100, 44)];
        confirmButton.backgroundColor = SO_THEME_COLOR;
        confirmButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
        confirmButton.layer.cornerRadius = 22;
        confirmButton.layer.masksToBounds = YES;
        [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [confirmButton addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [contentView addSubview:imageView];
        [contentView addSubview:cancelButton];
        [contentView addSubview:confirmButton];
        [self.view addSubview:contentView];
    }
    contentView.hidden = NO;
    UIImageView *imageView = [contentView viewWithTag:1001];
    imageView.image = image;
    self.customImage = image;
}

CHPropertyRetainNonatomic(AvatarModifyViewController, UIImage *, customImage, setCustomImage);

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"

CHDeclareMethod1(void, AvatarModifyViewController, cancelAction, UIButton *, arg1) {
    arg1.superview.hidden = YES;
}

CHDeclareMethod1(void, AvatarModifyViewController, confirmAction, UIButton *, arg1) {
    NSString *info = @"{\"bgColor\":\"1:1\",\"sex\":\"1\",\"resources\":[{\"id\":0,\"color\":[],\"type\":\"body\"},{\"id\":0,\"transform\":{\"y\":0,\"x\":0,\"rotate\":0,\"scale\":1},\"type\":\"dress\",\"color\":[]},{\"id\":0,\"transform\":{\"y\":0,\"x\":0,\"rotate\":0,\"scale\":1},\"type\":\"eyes\",\"color\":[]},{\"id\":0,\"transform\":{\"y\":-9,\"x\":4,\"rotate\":9.9629001547108462,\"scale\":0.99934891161352746},\"type\":\"eyeslid\",\"color\":[]},{\"id\":0,\"transform\":{\"y\":0,\"x\":0,\"rotate\":0,\"scale\":1},\"type\":\"nose\",\"color\":[]},{\"id\":0,\"transform\":{\"y\":0,\"x\":0,\"rotate\":0,\"scale\":1},\"type\":\"face\",\"color\":[]},{\"id\":0,\"transform\":{\"y\":1,\"x\":0,\"rotate\":-0.56784177160274973,\"scale\":0.97628700328111562},\"type\":\"hat\",\"color\":[]},{\"id\":0,\"transform\":{\"y\":-2,\"x\":0,\"rotate\":0,\"scale\":1},\"type\":\"mouth\",\"color\":[]},{\"id\":0,\"transform\":{\"y\":-6,\"x\":9,\"rotate\":-2.2325100697840816,\"scale\":1.0463911147977312},\"type\":\"eyebrow\",\"color\":[]},{\"id\":0,\"transform\":{\"y\":0,\"x\":0,\"rotate\":0,\"scale\":1},\"type\":\"hair\",\"color\":[]}]}";
    
    [self uploadAvatar:[self resizeImage:CGSizeMake(520, 520)] avatarSVGInfo:info];
    [self uploadOriginAvatar:[self resizeImage:CGSizeMake(650, 650)] avatarSVGInfo:info];
}


CHDeclareMethod1(UIImage *, AvatarModifyViewController, resizeImage, CGSize, size) {
    UIGraphicsBeginImageContextWithOptions(size, NO, self.customImage.scale);
    UIGraphicsGetCurrentContext();
    [self.customImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *imageOut = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageOut;
}

// 消息接收
CHDeclareClass(ChatTransCenter)

CHOptimizedMethod2(self, void, ChatTransCenter, sendCommandsMessage, SoulIMMessage *, arg1, completion, id, arg2) {
    //319:结束输入 318:开始输入 333:unreadCount 321:read
    BOOL read = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_READ_SWITCH];
    
    if (read) {
        if (arg1.type == 321) {
            NSArray *list = [[NSUserDefaults standardUserDefaults] arrayForKey:SOUL_HOOK_WHITE_LIST];
            
            if (![list containsObject:arg1.toUid]) {
                return;
            }
        }
    }
    
    BOOL input = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_INPUT_STATE_SWITCH];
    
    if (input) {
        if (arg1.type == 319 || arg1.type == 318) {
            return;
        }
    }
    
    
    NSLog(@"sendCommandsMessage = %@", arg1);
    
    CHSuper2(ChatTransCenter, sendCommandsMessage, arg1, completion, arg2);
    
}

CHOptimizedMethod1(self, void, ChatTransCenter, receiveMessage, NSArray *, arg1) {
    IMPCommandMessage *msg = arg1[0];
    //type: 5=RESP 3=ACK
    NSLog(@"ChatTransCenter_receiveMessage = %@ type = %d soulId = %@", msg, msg.type, msg.soulId);
    
    IMPMsgCommand *msgCommand = [msg valueForKey:@"msgCommand"];
    NSLog(@"msgCommand = %@ type = %d", msgCommand, msgCommand.type);
    
    BOOL enable1 = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_AUTO_REPLY_ALL_SWITCH];
    BOOL enable2 = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_AUTO_REPLY_KEY_SWITCH];
    BOOL enable3 = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_ROBOT_SWITCH];
    BOOL enable4 = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_AUTO_READ_KEY_SWITCH];
    
    if (enable4) {
        if (msgCommand.type == 1 ||
        msgCommand.type == 3 ||
        msgCommand.type == 4 ||
        msgCommand.type == 11 ||
        msgCommand.type == 12 ||
        msgCommand.type == 29 ||
            (msgCommand.type == 0 && msgCommand.textMsg.text.length)) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [SOIMManager sendRead:msg.cmdId toUser:msg.soulId finished:nil];
            });
        }
    }
    
    if (enable1 || enable2) {
        if (msgCommand.type == 1 ||
            msgCommand.type == 3 ||
            msgCommand.type == 4 ||
            msgCommand.type == 11 ||
            msgCommand.type == 12 ||
            msgCommand.type == 29 ||
            (msgCommand.type == 0 && msgCommand.textMsg.text.length)) {
            
            if (enable2) {
                if (msgCommand.type == 0) {
                    NSArray *keys = [[NSUserDefaults standardUserDefaults] objectForKey:SOUL_HOOK_AUTO_REPLY_KEYS];
                    
                    __block BOOL autoReply = NO;
                    
                    [keys enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([msgCommand.textMsg.text containsString:obj[@"title"]]) {
                            autoReply = YES;
                            *stop = YES;
                        }
                    }];
                    
                    if (!autoReply) {
                        CHSuper1(ChatTransCenter, receiveMessage, arg1);
                        return;
                    }
                    
                } else {
                    CHSuper1(ChatTransCenter, receiveMessage, arg1);
                    return;
                }
            }
            
            NSArray *texts = [[NSUserDefaults standardUserDefaults] objectForKey:SOUL_HOOK_AUTO_REPLY_TEXTS];
            
            __block NSString *text = nil;
            [texts enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj[@"enable"] boolValue]) {
                    text = obj[@"title"];
                    *stop = YES;
                }
            }];
            
            if (!text.length) {
                text = @"你好，我现在不方便回消息";
            }
            
            [SOIMManager sendText:text toUser:msgCommand.from finished:nil];
        }
    } else if (enable3) {
        if ((msgCommand.type == 0 && msgCommand.textMsg.text.length) || msgCommand.type == 1 || msgCommand.type == 3 || msgCommand.type == 4 || msgCommand.type == 7) {
 
            if (msgCommand.type == 0 && msgCommand.textMsg.text.length) {
                 [SORobot answerWithKey:msgCommand.textMsg.text finished:^(NSString * _Nonnull answer, NSError * _Nonnull error) {
                     NSString *text = answer ? answer : @"本机器人好像出了一点问题";
                
                     [SOIMManager sendText:text toUser:msgCommand.from finished:nil];
                 }];
            } else {
                NSString *text = @"";
                if (msgCommand.type == 1) {
                    text = @"图片我可看不了呀，除非是你漂酿的自拍~";
                } else if (msgCommand.type == 3) {
                    text = @"视频我可看不了哦，咱还是老老实实的打字吧~";
                } else if (msgCommand.type == 4) {
                    text = @"语音我可听不了哦，咱还是老老实实的打字吧~";
                } else if (msgCommand.type == 7) {
                    NSArray *arr = @[@"欺负我表情包没你多是不是？",
                                     @"斗图我可比不上你呀，认输认输~",
                                     @"我没有表情回你岂不是很尬嘛~",
                                     @"不要发表情啦，跟我打字聊天很麻烦吗~"];
                    
                    NSUInteger i = arc4random_uniform(3);
                    
                    text = arr[i];
                }
            
                [SOIMManager sendText:text toUser:msgCommand.from finished:nil];
            }
        }
    }
    
    if (msgCommand.type == 8) {
        ////0=text 1=image 3=video 4=voice 7=emotion 8=RECALL 11=finger 12=dice 29=position
        BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_MSG_REVOKE_SWITCH];
        
        if (enable) {
            NSString *from = [msgCommand valueForKey:@"from"];
            NSString *cmdId = [msg valueForKey:@"cmdId"]; //消息id
            
            Class clz = NSClassFromString(@"IMDBManager");
            SEL instance = NSSelectorFromString(@"sharedInstance");
            IMP imp = [clz methodForSelector:instance];
            id (*func)(id, SEL) = (void *)imp;
            id manager = func(clz, instance);
            //            SEL selector = NSSelectorFromString(@"getSigleChatDBModel:");
            SEL selector = NSSelectorFromString(@"getSigleIMMessage:");
            
            SoulIMMessage *soulIMmessage = [manager performSelector:selector withObject:cmdId];
            NSString *type = nil;
            NSString *msgContent = nil;
            //text:300 image:301 video:303 voice:304 emotion:307 猜拳:311 骰子:312
            switch (soulIMmessage.type) {
                case 300:
                    type = @"文本";
                    msgContent = [soulIMmessage.textIMModel valueForKey:@"text"];
                    break;
                case 301:
                    type = @"图片";
                    msgContent = [soulIMmessage.imageModel valueForKey:@"url"];
                    break;
                case 303:
                    type = @"视频";
                    msgContent = [soulIMmessage.videoModel valueForKey:@"url"];
                    break;
                case 304:
                    type = @"语音";
                    msgContent = [soulIMmessage.voiceIMModel valueForKey:@"remoteURL"];
                    break;
                case 307:
                    type = @"表情";
                    break;
                case 311:
                    type = @"猜拳";
                    break;
                case 312:
                    type = @"骰子";
                    break;
                default:
                    type = @"其他类型";
                    break;
            }
            
            SOChatListViewController *list = [[[[[UIApplication sharedApplication].delegate.window.rootViewController valueForKey:@"centerViewController"] valueForKey:@"viewControllers"] objectAtIndex:3] valueForKey:@"rootViewController"];
            NSArray *dataArr = list.dataArr;
            
            __block SOChatListModel *model = nil;
            
            [dataArr enumerateObjectsUsingBlock:^(SOChatListModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.userID isEqualToString:from]) {
                    model = obj;
                    *stop = YES;
                }
            }];
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"拦截到 %@ 撤回 %@ 消息", model.signatrue, type] message:msgContent preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                if (msgContent) {
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    pasteboard.string = msgContent;
                    pasteboard.persistent = YES;
                }
            }]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:alertController animated:YES completion:nil];
            });
            
            NSLog(@"拦截到一条消息撤回 %d", soulIMmessage.type);
            [msg setValue:nil forKey:@"msgCommand"];
        }
    }
    
    CHSuper1(ChatTransCenter, receiveMessage, arg1);
}

//阅后即焚

CHDeclareClass(SOMovieVC)
CHOptimizedMethod0(self, void, SOMovieVC, viewDidLoad) {
    self.isFlashVideo = NO;
    CHSuper0(SOMovieVC, viewDidLoad);
}


CHDeclareClass(SOChatFlashPhotoMessageTableViewCell)

CHOptimizedMethod0(self, void, SOChatFlashPhotoMessageTableViewCell, tapFlashPhoto) {
    
    CHSuper0(SOChatFlashPhotoMessageTableViewCell, tapFlashPhoto);
    
    BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_MSG_COPY_SWITCH];
    if (enable) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.model.imageIMModel.url;
        pasteboard.persistent = YES;
    }
}

CHDeclareClass(SOLookFlashPhotoView)

CHOptimizedMethod3(self, id, SOLookFlashPhotoView, initWithFrame, CGRect, arg1, WithImage, NSData *, arg2, andIsSelf, BOOL, arg3) {
    id instance = CHSuper3(SOLookFlashPhotoView, initWithFrame, arg1, WithImage, arg2, andIsSelf, arg3);
    
    BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_MSG_FLASH_SWITCH];
    if (enable) {
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[UIVisualEffectView class]] || [obj isKindOfClass:NSClassFromString(@"DACircularProgressView")]) {
                obj.hidden = YES;
            }
            
            if ([obj isKindOfClass:[UIImageView class]]) {
                obj.userInteractionEnabled = YES;
                [obj addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)]];
            }
        }];
    }
    
    return instance;
}

CHOptimizedMethod1(self, void, SOLookFlashPhotoView, tapImage, id, arg1) {
    BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_MSG_FLASH_SWITCH];
    if (enable) {
        [self removeFromSuperview];
    } else {
        CHSuper1(SOLookFlashPhotoView, tapImage, arg1);
    }
}

CHOptimizedMethod1(self, void, SOLookFlashPhotoView, longPressBgView, UILongPressGestureRecognizer *, arg1) {
    BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_MSG_FLASH_SWITCH];
    if (!enable) {
        CHSuper1(SOLookFlashPhotoView, longPressBgView, arg1);
    }
}

CHOptimizedMethod1(self, void, SOLookFlashPhotoView, tapbgView, UITapGestureRecognizer *, arg1) {
    BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_MSG_FLASH_SWITCH];
    if (!enable) {
        CHSuper1(SOLookFlashPhotoView, tapbgView, arg1);
    }
}

CHDeclareClass(SOChatPhotoMessageTableViewCell)

CHOptimizedMethod0(self, void, SOChatPhotoMessageTableViewCell, tapIamge) {
    
    CHSuper0(SOChatPhotoMessageTableViewCell, tapIamge);
    
    BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_MSG_COPY_SWITCH];
    if (enable) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.model.imageIMModel.url;
        pasteboard.persistent = YES;
    }
}

CHDeclareClass(SOUserDefinedEmoticonTableViewCell)

CHOptimizedMethod0(self, void, SOUserDefinedEmoticonTableViewCell, tapIamge) {
    
    CHSuper0(SOUserDefinedEmoticonTableViewCell, tapIamge);
    
    BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_MSG_COPY_SWITCH];
    if (enable) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.model.imageIMModel.url;
        pasteboard.persistent = YES;
    }
}

CHDeclareClass(SOChatAudioMessageTableViewCell)

CHOptimizedMethod0(self, void, SOChatAudioMessageTableViewCell, run) {
    
    CHSuper0(SOChatAudioMessageTableViewCell, run);
    
    BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_MSG_COPY_SWITCH];
    if (enable) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.model.voiceIMModel.remoteURL;
        pasteboard.persistent = YES;
    }
}

CHDeclareClass(SOChatVideoMessageTableViewCell)

CHOptimizedMethod0(self, void, SOChatVideoMessageTableViewCell, tap) {
    
    CHSuper0(SOChatVideoMessageTableViewCell, tap);
    
    BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_MSG_COPY_SWITCH];
    if (enable) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.model.videoIMModel.url;
        pasteboard.persistent = YES;
    }
}

CHOptimizedMethod1(self, void, SOChatVideoMessageTableViewCell, UpdateSubclassingUIWithChatMessageModel, SOChatMessageModel *, arg1) {
    
    BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_MSG_FLASH_SWITCH];
    if (enable) {
        arg1.snap = NO;
        arg1.videoIMModel.mark = -1;
    }
    
    CHSuper1(SOChatVideoMessageTableViewCell, UpdateSubclassingUIWithChatMessageModel, arg1);
}

CHDeclareClass(SOCollectEmoticonView)

CHOptimizedMethod2(self, void, SOCollectEmoticonView, collectionView, UICollectionView *, arg1, didSelectItemAtIndexPath, NSIndexPath *, arg2) {
    
    if (arg2.item == 1) {
        BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_FINGER_SWITCH];
        if (!enable) {
            CHSuper2(SOCollectEmoticonView, collectionView, arg1, didSelectItemAtIndexPath, arg2);
            return;
        }
        
        UIView *view = [self viewWithTag:1000];
        if (!view) {
            view = [[UIView alloc] initWithFrame:self.bounds];
            view.backgroundColor = [UIColor whiteColor];
            view.tag = 1000;
            
            CGFloat width = self.bounds.size.width;
            CGFloat height = self.bounds.size.height;
            NSArray *titleArray = @[@"🖐🏻", @"✌🏻", @"✊🏻", @"取消"];
            
            for (NSInteger i = 0; i < 4; i ++) {
                UIButton *button = [[UIButton alloc] init];
                button.tag = 1001 + i;
                button.frame = (i < 3) ? CGRectMake(i * width / 3, 0, width / 3, width / 3) : CGRectMake(0, height - 44, width, 44);
                button.titleLabel.font = (i < 3) ? [UIFont systemFontOfSize:30] : [UIFont fontWithName:@"PingFangSC-Regular" size:14];
                
                [button setTitle:titleArray[i] forState:UIControlStateNormal];
                [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [button addTarget:self action:@selector(fingerAction:) forControlEvents:UIControlEventTouchUpInside];
                
                [view addSubview:button];
            }
            
            [self addSubview:view];
        }
        
        view.hidden = NO;
        
    } else if (arg2.item == 2) {
        BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_DICE_SWITCH];
        if (!enable) {
            CHSuper2(SOCollectEmoticonView, collectionView, arg1, didSelectItemAtIndexPath, arg2);
            return;
        }
        
        UIView *view = [self viewWithTag:2000];
        if (!view) {
            view = [[UIView alloc] initWithFrame:self.bounds];
            view.backgroundColor = [UIColor whiteColor];
            view.tag = 2000;
            
            CGFloat width = self.bounds.size.width;
            CGFloat height = self.bounds.size.height;
            
            NSArray *titleArray = @[@"骰子1", @"骰子2", @"骰子3", @"骰子4", @"骰子5", @"骰子6", @"取消"];
            
            for (NSInteger i = 0; i < 7; i ++) {
                UIButton *button = [[UIButton alloc] init];
                button.tag = 2001 + i;
                button.frame = (i < 6) ? CGRectMake((i < 3) ? i * width / 3 : (i - 3) * width / 3, (i < 3) ? 0 : 80, width / 3, 70) : CGRectMake(0, height - 44, width, 44);
                
                [button setTitle:titleArray[i] forState:UIControlStateNormal];
                [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [button addTarget:self action:@selector(diceAction:) forControlEvents:UIControlEventTouchUpInside];
                
                [view addSubview:button];
            }
            
            [self addSubview:view];
        }
        
        view.hidden = NO;
    } else {
        CHSuper2(SOCollectEmoticonView, collectionView, arg1, didSelectItemAtIndexPath, arg2);
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"

CHDeclareMethod1(void, SOCollectEmoticonView, fingerAction, UIButton *, arg1) {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (arg1.tag == 1004) {
        arg1.superview.hidden = YES;
    } else {
        NSString *finger = [@(arg1.tag - 1000) stringValue];
        
        [userDefaults setObject:finger forKey:SOUL_HOOK_FINGER_TYPE];
        [userDefaults synchronize];
        arg1.superview.hidden = YES;
        !self.fingerBlock ? : self.fingerBlock();
    }
}

CHDeclareMethod1(void, SOCollectEmoticonView, diceAction, UIButton *, arg1) {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (arg1.tag == 2007) {
        arg1.superview.hidden = YES;
    } else {
        NSString *dice = [@(arg1.tag - 2000) stringValue];
        
        [userDefaults setObject:dice forKey:SOUL_HOOK_DICE_TYPE];
        [userDefaults synchronize];
        arg1.superview.hidden = YES;
        !self.diceBlock ? : self.diceBlock();
    }
}

CHDeclareClass(SOSettingsVC)

CHOptimizedMethod0(self, void, SOSettingsVC, viewDidLoad) {
    CHSuper0(SOSettingsVC, viewDidLoad);
 
    [self so_rightItemWithTitle:@"SO设置"];
}

CHOptimizedMethod1(self, void, SOSettingsVC, rightItemClick, id, arg1) {
    SOHookSettingController *setting = [[SOHookSettingController alloc] init];
    [self.navigationController pushViewController:setting animated:YES];
}

CHDeclareClass(SOBuildMessageManager)

CHOptimizedClassMethod2(self, id, SOBuildMessageManager, buildRollDiceMessageTo, NSString *, arg1, info, NSString *, arg2) {
    
    BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_DICE_SWITCH];
    if (enable) {
        arg2 = [[NSUserDefaults standardUserDefaults] valueForKey:SOUL_HOOK_DICE_TYPE];
    }
    
    id msg = CHSuper2(SOBuildMessageManager, buildRollDiceMessageTo, arg1, info, arg2);
    
    return msg;
}

CHOptimizedClassMethod2(self, id, SOBuildMessageManager, buildFingerGuessMessageTo, NSString *, arg1, info, NSString *, arg2) {
    
    BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_FINGER_SWITCH];
    if (enable) {
        arg2 = [[NSUserDefaults standardUserDefaults] valueForKey:SOUL_HOOK_FINGER_TYPE];
    }
    
    id msg = CHSuper2(SOBuildMessageManager, buildFingerGuessMessageTo, arg1, info, arg2);
    
    return msg;
}

CHDeclareClass(SOUserInfoViewController)

CHOptimizedMethod2(self, void, SOUserInfoViewController, tableView, UITableView *, tableView, didSelectRowAtIndexPath, NSIndexPath *, indexPath) {
    
    NSLog(@"%@", indexPath);
    
    if (indexPath.row == 16) {
        BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_SOULMATE_SWITCH];
        if (enable) {
            self.isCanCreatSoulMate = YES;
        }
        CHSuper2(SOUserInfoViewController, tableView, tableView, didSelectRowAtIndexPath, indexPath);
    } else {
        CHSuper2(SOUserInfoViewController, tableView, tableView, didSelectRowAtIndexPath, indexPath);
    }
}


CHDeclareClass(AppShell)

CHOptimizedMethod0(self, void, AppShell, displayAdvert) {
    BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_ADVERT_SWITCH];
    if (!enable) {
        CHSuper0(AppShell, displayAdvert);
    }
}

CHDeclareClass(HeaderTwoViewController)

CHOptimizedMethod1(self, void, HeaderTwoViewController, confirmClick, id, arg1) {
    BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_AVATAR_BG_SWITCH];
    if (enable) {
        self.headImageName = @"avatar";
    }
    
    CHSuper1(HeaderTwoViewController, confirmClick, arg1);
}
 
CHDeclareClass(SOReleaseViewController)

CHOptimizedMethod1(self, void, SOReleaseViewController, tagEditContainerViewDidLocationItemClick, id, arg1) {
    
    BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_LOCATION_SWITCH];
    if (!enable) {
        CHSuper1(SOReleaseViewController, tagEditContainerViewDidLocationItemClick, arg1);
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"搜索" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        CHSuper1(SOReleaseViewController, tagEditContainerViewDidLocationItemClick, arg1);
    }];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"自定义" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UIAlertController *alertChild = [UIAlertController alertControllerWithTitle:nil message:@"请输入自定义位置" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertChild addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"请输入自定义位置";
        }];
        
        [alertChild addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UITextField *textField = alertChild.textFields.firstObject;
            if (textField.text) {
                UILabel *titleLabel = [[[[self valueForKey:@"tagEditView"] valueForKey:@"tagEditToolBarView"] valueForKey:@"locationView"] valueForKey:@"titleLabel"];
                titleLabel.text = textField.text;
                
                id releaseModel = [self valueForKey:@"releaseModel"];
                [releaseModel setValue:textField.text forKey:@"position"];
                
                id selectedModel = [[self valueForKey:@"tagEditView"] valueForKey:@"selectedModel"];
                [selectedModel setValue:textField.text forKey:@"name"];
            }
        }]];
        
        [alertChild addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertChild animated:YES completion:nil];
    }];
    
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:action1];
    [alert addAction:action2];
    [alert addAction:action3];
    
    [self presentViewController:alert animated:YES completion:nil];
}

CHDeclareClass(ScrollerWebController)
CHOptimizedMethod0(self, void, ScrollerWebController, viewDidLoad) {
    
    CHSuper0(ScrollerWebController, viewDidLoad);
    //    https://app.soulapp.cn/app/#/friendPraise?disableShare=true&userIdEcpt=QUJNYU5qdmVsa0hWVlgvZUh1NEExdz09
    NSLog(@"ScrollerWebController-viewDidLoad = %@", self.url);
}

CHOptimizedMethod2(self, void, ScrollerWebController, actionForStartNetworkRequst, id, arg1, callBack, dispatch_block_t, arg2) {
    
    NSLog(@"ScrollerWebController-actionForStartNetworkRequst = %@", arg1);
    CHSuper2(ScrollerWebController, actionForStartNetworkRequst, arg1, callBack, arg2);
}

CHOptimizedMethod2(self, void, ScrollerWebController, webView, UIWebView *, arg1, didFailLoadWithError, NSError *, arg2) {
    
    NSLog(@"ScrollerWebController-didFailLoadWithError = %@ %@", arg1, arg2);
    CHSuper2(ScrollerWebController, webView, arg1, didFailLoadWithError, arg2);
}

CHOptimizedMethod1(self, void, ScrollerWebController, webViewDidFinishLoad, UIWebView *, arg1) {
    NSLog(@"ScrollerWebController-webViewDidFinishLoad = %@", arg1);
    CHSuper1(ScrollerWebController, webViewDidFinishLoad, arg1);
}

CHOptimizedMethod3(self, BOOL, ScrollerWebController, webView, UIWebView *, arg1, shouldStartLoadWithRequest, NSURLRequest *, arg2, navigationType, UIWebViewNavigationType, arg3) {
    NSLog(@"ScrollerWebController-shouldStartLoadWithRequest = %@ %ld", arg2, arg3);
    return CHSuper3(ScrollerWebController, webView, arg1, shouldStartLoadWithRequest, arg2, navigationType, arg3);
}

CHDeclareClass(AFHTTPSessionManager)
 
CHMethod8(NSURLSessionDataTask *, AFHTTPSessionManager, dataTaskWithHTTPMethod, NSString *, method, URLString, NSString *, URLString, parameters, id, parameters, headers, NSDictionary *, headers, uploadProgress, progressBlock, uploadProgress, downloadProgress, progressBlock, downloadProgress, success, successBlock, success, failure, failureBlock, failure) {
    
    /* device-id 和 sdi 是必须传参数, 不传导致接口失败, 乱改 **可能引起封号**
     code = 9000006,
     message = "服务器有些小异常，可以通过意见反馈或关注官博Soul社交反馈哦~",
     data = <null>,
     success = 0
     */
    /*
    NSMutableDictionary *header = [NSMutableDictionary dictionaryWithDictionary:headers];
    header[@"device-id"] = @"";
    header[@"sdi"] = @"";
    headers = header;
    */
    //注册设备限制
    if ([URLString containsString:@"v6/account/register"]) {
        NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:parameters];
        param[@"sMDeviceId"] = @"20200409004134d1156bb82762ccac4528aa3e138abc7501901de5c16ac9a4";
        parameters = param;
    }
    
 
    successBlock successB = ^(NSURLSessionDataTask *task, id _Nullable responseObject) {
        NSLog(@"AFHTTPSessionManager:\nmethod=%@ \nURLString=%@ \nparameters=%@ \nheaders=%@ \nresponseObject=%@", method, URLString, parameters, headers, responseObject);
        
         if ([URLString containsString:@"/v2/user/info"]) {
//             Class soulUserManager = NSClassFromString(@"SoulUserManager");
//             SEL instance = NSSelectorFromString(@"sharedInstance");
//             IMP instanceImp = [soulUserManager methodForSelector:instance];
//             id (*func2)(id, SEL) = (void *)instanceImp;
//             id manager = func2(soulUserManager, instance);
//
//             id currentUser = [manager valueForKey:@"currentUser"];
//             NSString *useridEcpt = [currentUser valueForKey:@"useridEcpt"];
//
//             if ([useridEcpt isEqualToString:parameters[@"userIdEcpt"]]) {
//                 [[NSNotificationCenter defaultCenter] postNotificationName:SOHOOK_NOTIFICATION_USER_DATA object:responseObject[@"data"]];
//             }
             NSLog(@"个人信息：%@ ", parameters);
         }
        
        if ([URLString containsString:@"cuteface/getAllItems"]) {
            BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_AVATAR_SWITCH];
            if (enable) {
               responseObject = [NSMutableDictionary dictionaryWithDictionary:responseObject];
               NSMutableDictionary *data = [NSMutableDictionary dictionary];
               data[@"cuteFaceItems"] = @[];
               responseObject[@"data"] = data;
            }
        }
        
        if ([URLString containsString:@"account/fastLogin"]) {
            BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_BIRTHDAY_GENDER_SWITCH];
            if (enable && ![responseObject[@"data"] isKindOfClass:[NSNull class]]) {
                responseObject = [NSMutableDictionary dictionaryWithDictionary:responseObject];
                NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:responseObject[@"data"]];
                NSMutableDictionary *funcSetting = [NSMutableDictionary dictionaryWithDictionary:data[@"funcSetting"]];
                
                [funcSetting setObject:@"0" forKey:@"isTeenageModeChatCard"];
                [funcSetting setObject:@"0" forKey:@"isTeenageMode"];
                [funcSetting setObject:@"0" forKey:@"isTeenageModeHomepage"];
                
                [data setObject:funcSetting forKey:@"funcSetting"];
                [data setObject:@"0" forKey:@"setBirthday"];
                [data setObject:@"0" forKey:@"setGender"];
                [data setObject:@"0" forKey:@"updateBirthdayCount"];
                [data setObject:@"0" forKey:@"updateGenderCount"];
                
                [responseObject setObject:data forKey:@"data"];
            }
        }
        
        if ([URLString containsString:@"post/homepage"]) {
            BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_POST_VISIBILITY_SWITCH];
            if (enable) {
                responseObject = [NSMutableDictionary dictionaryWithDictionary:responseObject];
                
                id originData = responseObject[@"data"];
                
                if ([originData isKindOfClass:[NSArray class]]) {
                    NSMutableArray *data = [NSMutableArray arrayWithArray:originData];
                    
                    NSMutableArray *newData = [NSMutableArray array];
                    [data enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSMutableDictionary *dic = [obj mutableCopy];
                        [dic setObject:@"PUBLIC" forKey:@"visibility"];//PRIVATE STRANGER HOMEPAGE PUBLIC
                        [newData addObject:dic];
                    }];
                    [responseObject setObject:newData forKey:@"data"];
                }
            }
        }
        
        if ([URLString containsString:@"getMatchValue"]) {
            responseObject = [NSMutableDictionary dictionaryWithDictionary:responseObject];
            
            CGFloat value =  [[NSUserDefaults standardUserDefaults] floatForKey:SOUL_HOOK_MATCH_VALUE];
            
            if (value) {
                responseObject[@"data"] = @{@"value" : [NSString stringWithFormat:@"%.2f", (value / 100)]};
            }
        }
        
        if ([URLString containsString:@"user/chatCard/info"]) {
            responseObject = [NSMutableDictionary dictionaryWithDictionary:responseObject];
            
            CGFloat value =  [[NSUserDefaults standardUserDefaults] floatForKey:SOUL_HOOK_MATCH_VALUE];
            
            if (value) {
                if ([responseObject[@"data"] isKindOfClass:[NSDictionary class]]) {
                     NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:responseObject[@"data"]];
                     data[@"matchDegree"] = @(value);
                     responseObject[@"data"] = data;
                }
            }
        }
        
        /* 直接修改SOPost的值 不在此处修改
        if ([URLString containsString:@"post/detail"]) {
            responseObject = [NSMutableDictionary dictionaryWithDictionary:responseObject];
                    
            if (responseObject[@"data"] && [responseObject[@"data"] isKindOfClass:[NSDictionary class]]) {
                NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:responseObject[@"data"]];
                data[@"officialTag"] = [NSNull null];
                 
                responseObject[@"data"] = data;
            }
        }
         */
        
        if ([URLString containsString:@"officialTag/extInfo"]) {
            responseObject = [NSMutableDictionary dictionaryWithDictionary:responseObject];
            if (responseObject[@"data"] && [responseObject[@"data"] isKindOfClass:[NSDictionary class]]) {
                NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:responseObject[@"data"]];
                if (![data[@"canPost"] integerValue]) {
                    data[@"canPost"] = @1;
                    responseObject[@"data"] = data;
                }
            }
        }
        
        !success ? : success(task, responseObject);
    };
 
    
/*
      self->_requestSerializer->_mutableHTTPRequestHeaders:
    {
 app-id = "10000001",
 os = "ios",
 api-sign = "2E6FB3B4F934EEAF06FA2CF75BA5E9A676064193",
 app-time = "1602321122845",
 api-sign-version = "v5",
 device-id = "706A718D-FD39-43A3-81CD-E3A45AF46724",
 sdi = "62F903ED-99D2-441D-AAEF-F4C3F565F9F7",
 User-Agent = "TlUyYjJJbzdzZldpMU9uVThNL1NQbzBIR1VEb1N1SVg1ZXJ0UmIvZ0RVdXFBQ1VJSXhDYUFRT2tBbUszMHExeA==",
 request-nonce = "68254330748351005018073691005927",
 app-version = "3.53.0",
 X-Auth-UserId = "-1"
    }
 */
    NSURLSessionDataTask *task = CHSuper8(AFHTTPSessionManager, dataTaskWithHTTPMethod, method, URLString, URLString, parameters, parameters, headers, headers, uploadProgress, uploadProgress, downloadProgress, downloadProgress, success, successB, failure, failure);
    
    return task;
}

CHDeclareClass(SOPrivateChatViewController)

CHOptimizedMethod0(self, void, SOPrivateChatViewController, viewDidLoad) {
    CHSuper0(SOPrivateChatViewController, viewDidLoad);
    
    UIButton *button = [self.customNavBar viewWithTag:999];
    if (!button) {
        button = [[UIButton alloc] initWithFrame:CGRectMake(60, [UIApplication sharedApplication].statusBarFrame.size.height + 11, 50, 22)];
        button.tag = 999;
        button.layer.cornerRadius = 11;
        button.layer.masksToBounds = YES;
        button.backgroundColor = [UIColor redColor];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        [button setTitle:@"更多" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.customNavBar addSubview:button];
    }
}

CHDeclareMethod1(void, SOPrivateChatViewController, moreAction, UIButton *, arg1) {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
 
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"消息轰炸" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
         UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"输入文本及消息次数" message:nil preferredStyle:UIAlertControllerStyleAlert];
         
         UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            }];
            
         __weak __typeof(self)weakSelf = self;
         UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
             __strong __typeof(weakSelf)strongSelf = weakSelf;
             [alert dismissViewControllerAnimated:YES completion:nil];
             UITextField *textField1 = alert.textFields[0];
             UITextField *textField2 = alert.textFields[1];
             
             NSInteger count = [textField2.text intValue];
             
             if (count && textField1.text.length) {
                 __block NSInteger time = 0;
                 for (NSInteger i = 0; i < count; i++) {
                     CGFloat delay = 0.03 * i;
                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                         [SOIMManager sendText:textField1.text toUser:strongSelf.chatId finished:^{
                             time ++;
                             
                             if (time == count) {
                                 UIAlertController *tip = [UIAlertController alertControllerWithTitle:@"轰炸结束" message:nil preferredStyle:UIAlertControllerStyleAlert];
                                 [strongSelf presentViewController:tip animated:YES completion:nil];
                                 
                                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                     [tip dismissViewControllerAnimated:YES completion:nil];
                                 });
                             }
                         }];
                     });
                 }
             }
         }];

         [alert addAction:cancelAction];
         [alert addAction:okAction];
         [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
              textField.placeholder = @"自动回复文本";
         }];
         
         [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
              textField.placeholder = @"轰炸次数";
         }];
         
         [self presentViewController:alert animated:YES completion:nil];
    }];
        
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"可已读白名单" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        NSMutableArray *list = [userDefaults arrayForKey:SOUL_HOOK_WHITE_LIST].mutableCopy;
        if (!list) {
            list = [NSMutableArray array];
        }
        
        if (![list containsObject:self.chatId]) {
            [list addObject:self.chatId];
        }
        
        [userDefaults setObject:list forKey:SOUL_HOOK_WHITE_LIST];
        [userDefaults synchronize];
    }];
  
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:action1];
    [alert addAction:action2];
    [alert addAction:action3];
      
    [self presentViewController:alert animated:YES completion:nil];
}


CHMethod1(void, SOPrivateChatViewController, _showMenuViewIndexPath, NSIndexPath *, arg1) {
    CHSuper1(SOPrivateChatViewController, _showMenuViewIndexPath, arg1);
    
    UIMenuItem *revokeflagMenuItem = [self valueForKey:@"revokeflagMenuItem"];
    id privateChatIMManager = [self valueForKey:@"privateChatIMManager"];//SOPrivateChatIMManager
    NSArray *dataArr = [privateChatIMManager valueForKey:@"dataArr"];
    id messageModel = [dataArr objectAtIndex:arg1.row];
    BOOL fromMine = [[messageModel valueForKey:@"fromMine"] boolValue];
    BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_MSG_RECALL_SWITCH];
    if (enable && fromMine && ![self.menuController.menuItems containsObject:revokeflagMenuItem]) {
        NSMutableArray *items = self.menuController.menuItems.mutableCopy;
        [items addObject:revokeflagMenuItem];
        self.menuController.menuItems = items;
        [self.menuController update];
    }
    
}

CHDeclareClass(NewTabBarController)

CHOptimizedMethod0(self, void, NewTabBarController, viewDidLoad) {
    CHSuper0(NewTabBarController, viewDidLoad);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSArray <UITabBarItem *>*arr = self.tabBar.items;
        
        NSArray *titles = @[@"全随缘", @"光看脸", @"", @"虾扯蛋", @"烹鱼宴"];
        
        [arr enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *title = titles[idx];
            
            if (title.length) {
                obj.title = title;
            }
        }];
        
        NSArray *subViews = self.tabBar.subviews;
        
        [subViews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[UIImageView class]] && obj.bounds.size.height == 46 && obj.bounds.size.width == 46) {
                UIImageView *imageView = (UIImageView *)obj;
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 46, 46)];
                label.layer.cornerRadius = 23;
                label.layer.masksToBounds = YES;
                label.font = [UIFont systemFontOfSize:12];
                label.textColor = [UIColor whiteColor];
                label.numberOfLines = 0;
                label.textAlignment = NSTextAlignmentCenter;
                label.backgroundColor = SO_THEME_COLOR;
                label.text = @"开始\n装逼";
                
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(46, 46), NO, 0);
                CGContextRef context = UIGraphicsGetCurrentContext();
                [label.layer renderInContext:context];
                UIImage *imageOut = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();

                imageView.image = imageOut;
        
                *stop = YES;
            }
        }];
    });
}

CHDeclareClass(SoulUtils)

CHOptimizedClassMethod2(self, id, SoulUtils, makeWatermarkPhotoImageWithImage, id, arg1, watermark, id, arg2) {
    
    NSLog(@"水印 11 %@ %@", arg1, arg2);
    
    BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_WATER_MARK_SWITCH];
    
    if (enable) {
        arg2 = nil;
    }
    return CHSuper2(SoulUtils, makeWatermarkPhotoImageWithImage, arg1, watermark, arg2);
}

CHOptimizedClassMethod1(self, id, SoulUtils, makeWatermarkPhotoImageWithImage, id, arg1) {
    
    NSLog(@"水印 22 %@", arg1);
    
    BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_WATER_MARK_SWITCH];
    
    if (enable) {
        return arg1;
    }
    return CHSuper1(SoulUtils, makeWatermarkPhotoImageWithImage, arg1);
}

CHDeclareClass(StrangerViewController)

CHOptimizedMethod0(self, void, StrangerViewController, viewDidLoad) {
    CHSuper0(StrangerViewController, viewDidLoad);
    
    UIButton *filter = [[UIButton alloc] init];
    [filter setTitle:@"筛选" forState:UIControlStateNormal];
    [filter setTitleColor:SO_THEME_COLOR forState:normal];
    filter.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    filter.layer.cornerRadius = 15;
    filter.layer.masksToBounds = YES;
    filter.layer.borderColor = SO_THEME_COLOR.CGColor;
    filter.layer.borderWidth = 1;
    [filter addTarget:self action:@selector(filterAction:) forControlEvents:UIControlEventTouchUpInside];

    UIView *leftView = [self.nav valueForKey:@"leftView"];
    UIView *navigationBarView = [self.nav valueForKey:@"navigationBarView"];
    
    CGRect leftViewFrame = leftView.frame;
    
    filter.frame = CGRectMake(leftViewFrame.origin.x + leftViewFrame.size.width + 20, leftViewFrame.origin.y + 2, 50, 30);
    
    [navigationBarView addSubview:filter];
}

CHOptimizedMethod0(self, void, StrangerViewController, endRefresh) {
    CHSuper0(StrangerViewController, endRefresh);
    
    NSMutableDictionary *avatarModel = [NSMutableDictionary dictionaryWithDictionary:self.avatarModel];
    NSMutableDictionary *dataDic = avatarModel[@"dataDic"];
    
    if (!dataDic) {
        dataDic = [NSMutableDictionary dictionary];
        avatarModel[@"dataDic"] = dataDic;
    }
    
    [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [dataDic setObject:obj forKey:[[obj valueForKeyPath:@"id"] stringValue]];
    }];
    
   
    avatarModel[@"dataDic"] = dataDic;
    
    self.avatarModel = avatarModel;
}
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"

CHDeclareMethod1(void, StrangerViewController, filterAction, UIButton *, arg1) {
    NSMutableDictionary *avatarModel = [NSMutableDictionary dictionaryWithDictionary:self.avatarModel];
    NSMutableDictionary *dataDic = avatarModel[@"dataDic"];
    NSMutableArray *dataArray = [dataDic allValues].mutableCopy;
    
    [dataArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj2 valueForKey:@"createTime"] compare:[obj1 valueForKey:@"createTime"]];
    }];
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
//    TEXT  IMAGE  VIDEO  AUDIO
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"全部瞬间" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.dataArray = dataArray;
        [self.tableView reloadData];
    }];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"仅看带图/视频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSMutableArray *data = [NSMutableArray array];
        
        for (id post in dataArray) {
            NSString *type = [post valueForKey:@"type"];
            
            if ([type isEqualToString:@"IMAGE"] || [type isEqualToString:@"VIDEO"]) {
                [data addObject:post];
            }
        }
        self.dataArray = data;
        [self.tableView reloadData];
    }];
    
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"仅看带音频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSMutableArray *data = [NSMutableArray array];
        
        for (id post in dataArray) {
            NSString *type = [post valueForKey:@"type"];
            
            if ([type isEqualToString:@"AUDIO"]) {
                [data addObject:post];
            }
        }
        self.dataArray = data;
        [self.tableView reloadData];
        
    }];
    
    UIAlertAction *action4 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:action1];
    [alert addAction:action2];
    [alert addAction:action3];
    [alert addAction:action4];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

CHDeclareClass(SOWebItemViewController)

CHOptimizedMethod0(self, void, SOWebItemViewController, viewDidLoad) {
    CHSuper0(SOWebItemViewController, viewDidLoad);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_AVATAR_CUSTOM_SWITCH];
        
        if (enable && ([self.model.url isEqualToString:@"avatar/#/own/create"] || [self.model.url isEqualToString:@"avatar/#/ta/create"])) {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 175, [UIApplication sharedApplication].statusBarFrame.size.height + 14, 80, 36)];
            button.backgroundColor = SO_THEME_COLOR;
            button.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
            button.layer.cornerRadius = 18;
            button.layer.masksToBounds = YES;
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitle:@"自定义" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(customAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.webView addSubview:button];
        }
    });
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"

CHDeclareMethod1(void, SOWebItemViewController, customAction, UIButton *, arg1) {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
            // 请在'设置'中打开相机权限
            return;
        }
        
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            // 照相机不可用
            return;
        }
        UIImagePickerController *vc = [[UIImagePickerController alloc] init];
        vc.delegate = self;
        vc.allowsEditing = YES;
        vc.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:vc animated:YES completion:nil];
    }];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UIImagePickerController *vc = [[UIImagePickerController alloc] init];
        vc.delegate = self;
        vc.allowsEditing = YES;
        vc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:vc animated:YES completion:nil];
        
    }];
    
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:action1];
    [alert addAction:action2];
    [alert addAction:action3];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

CHDeclareMethod1(void, SOWebItemViewController, imagePickerControllerDidCancel, UIImagePickerController *, arg1) {
    self.userBridge.customImage = nil;
    [arg1 dismissViewControllerAnimated:YES completion:nil];
}

CHDeclareMethod2(void, SOWebItemViewController, imagePickerController, UIImagePickerController *, arg1, didFinishPickingMediaWithInfo, NSDictionary *, arg2) {
    UIImage *image = [arg2 objectForKey:UIImagePickerControllerEditedImage];
    [arg1 dismissViewControllerAnimated:YES completion:nil];
    
    self.userBridge.customImage = image;
    
    NSLog(@"customImage === %@", self.userBridge.customImage);
}

CHDeclareClass(SOUserBridgeManager)
CHPropertyRetainNonatomic(SOUserBridgeManager, UIImage *, customImage, setCustomImage);

CHOptimizedMethod2(self, void, SOUserBridgeManager, uploadOriginAvatar, UIImage *, arg1, avatarSVGInfo, id, arg2) {
    BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_AVATAR_CUSTOM_SWITCH];
    if (enable && self.customImage) {
        arg1 = [self resizeImage:self.customImage size:arg1.size];
    }
    
    CHSuper2(SOUserBridgeManager, uploadOriginAvatar, arg1, avatarSVGInfo, arg2);
}

CHOptimizedMethod2(self, void, SOUserBridgeManager, uploadAvatar, UIImage *, arg1, avatarSVGInfo, id, arg2) {
    //520
    BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_AVATAR_CUSTOM_SWITCH];
    if (enable && self.customImage) {
        arg1 = [self resizeImage:self.customImage size:arg1.size];
    }
    
    CHSuper2(SOUserBridgeManager, uploadAvatar, arg1, avatarSVGInfo, arg2);
}


CHDeclareMethod2(UIImage *, SOUserBridgeManager, resizeImage, UIImage *, img, size, CGSize, size) {
    
    UIGraphicsBeginImageContextWithOptions(size, NO, img.scale);
    UIGraphicsGetCurrentContext();
    [self.customImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *imageOut = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageOut;
}

CHOptimizedMethod5(self, void, SOUserBridgeManager, updateUserInfWithAvatarName, NSString *, arg1, originAvatarName, NSString *, arg2, image, UIImage *, arg3, originImage, UIImage *, arg4, svgInfo, NSString *, arg5) {
    
    BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_AVATAR_CUSTOM_SWITCH];
    if (enable && self.customImage) {
        arg3 = [self resizeImage:self.customImage size:arg3.size];
        arg4 = [self resizeImage:self.customImage size:arg4.size];
        
        CHSuper5(SOUserBridgeManager, updateUserInfWithAvatarName, arg1, originAvatarName, arg2, image, arg3, originImage, arg4, svgInfo, arg5);
    } else {
        CHSuper5(SOUserBridgeManager, updateUserInfWithAvatarName, arg1, originAvatarName, arg2, image, arg3, originImage, arg4, svgInfo, arg5);
    }
}

CHDeclareClass(SOPersonalInfoVC)

CHOptimizedMethod2(self, NSInteger, SOPersonalInfoVC, tableView, UITableView *, arg1, numberOfRowsInSection, NSInteger, arg2) {
 
    NSInteger num = CHSuper2(SOPersonalInfoVC, tableView, arg1, numberOfRowsInSection, arg2);

    if (arg2 == 0) {
        return 3;
    } else {
        return num;
    }
}

CHOptimizedMethod2(self, CGFloat, SOPersonalInfoVC, tableView, UITableView *, arg1, heightForRowAtIndexPath, NSIndexPath *, arg2) {
    return 50.0;
}

CHOptimizedMethod2(self, UITableViewCell *, SOPersonalInfoVC, tableView, UITableView *, arg1, cellForRowAtIndexPath, NSIndexPath *, arg2) {

    UITableViewCell *cell = CHSuper2(SOPersonalInfoVC, tableView, arg1, cellForRowAtIndexPath, arg2);
    if (arg2.section == 0) {
        cell.hidden = NO;
    }
    
    return cell;
}

CHDeclareClass(SoulChatLimitGiftViewController)

CHOptimizedMethod1(self, void, SoulChatLimitGiftViewController, clickCancelButtonAction, id, arg1) {
    self.cancelBlock = ^{
        NSLog(@"取消送礼");
    };
       
    CHSuper1(SoulChatLimitGiftViewController, clickCancelButtonAction, arg1);
}

CHDeclareClass(SOPost)
 
CHOptimizedMethod0(self, long long, SOPost, officialTag) {
    return 0;
}

CHDeclareClass(SOTopicInfoViewController)
 
CHOptimizedMethod0(self, void, SOTopicInfoViewController, viewDidLoad) {
    CHSuper0(SOTopicInfoViewController, viewDidLoad);
    
    self.deletePostBlock = ^{
        NSLog(@"删除瞬间");
    };
}

CHDeclareClass(BellNotifyInfoModel)
 
CHOptimizedMethod0(self, NSString *, BellNotifyInfoModel, officialTag) {
    return nil;
}

CHDeclareClass(SOMainSquareViewController)
CHOptimizedMethod0(self, void, SOMainSquareViewController, viewDidLoad) {
    CHSuper0(SOMainSquareViewController, viewDidLoad);
    
    UIButton *button = [self.view viewWithTag:1000];
    
    if (!button) {
        button = [[UIButton alloc] initWithFrame:CGRectMake(50, [UIApplication sharedApplication].statusBarFrame.size.height + 6, 30, 30)];
        button.tag = 1000;
        button.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitle:@"匿名" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(noNameController:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"

CHDeclareMethod1(void, SOMainSquareViewController, noNameController, UIButton *, arg1) {
    UIViewController *noName = [SOHookManager sharedInstance].aSubSquareNoNameViewController;
    
    if (!noName) {
        noName = [NSClassFromString(@"SubSquareNoNameViewController") new];
        noName.hidesBottomBarWhenPushed = YES;
        [SOHookManager sharedInstance].aSubSquareNoNameViewController = noName;
    }
    [self.navigationController pushViewController:noName animated:YES];
}

CHConstructor {
    CHLoadLateClass(SOMainSquareViewController);
    CHHook0(SOMainSquareViewController, viewDidLoad);
    
    CHLoadLateClass(BellNotifyInfoModel);
    CHHook0(BellNotifyInfoModel, officialTag);
    
    CHLoadLateClass(SOTopicInfoViewController);
    CHHook0(SOTopicInfoViewController, viewDidLoad);
    
    CHLoadLateClass(SOPost);
    CHHook0(SOPost, officialTag);
    
    CHLoadLateClass(SoulChatLimitGiftViewController);
    CHHook1(SoulChatLimitGiftViewController, clickCancelButtonAction);
    
    //设置个人信息 - 旧版头像
    CHLoadLateClass(SOPersonalInfoVC);
    CHHook2(SOPersonalInfoVC, tableView, numberOfRowsInSection);
    CHHook2(SOPersonalInfoVC, tableView, heightForRowAtIndexPath);
    CHHook2(SOPersonalInfoVC, tableView, cellForRowAtIndexPath);
    
    //新版本设置头像
    CHLoadLateClass(SOUserBridgeManager);
    CHHook0(SOUserBridgeManager, customImage);
    CHHook1(SOUserBridgeManager, setCustomImage);
    CHHook2(SOUserBridgeManager, uploadOriginAvatar, avatarSVGInfo);
    CHHook2(SOUserBridgeManager, uploadAvatar, avatarSVGInfo);
    CHHook5(SOUserBridgeManager, updateUserInfWithAvatarName, originAvatarName, image, originImage, svgInfo);

    CHLoadLateClass(SOWebItemViewController);
    CHHook0(SOWebItemViewController, viewDidLoad);
    
    CHLoadLateClass(StrangerViewController);
    CHHook0(StrangerViewController, viewDidLoad);
    CHHook0(StrangerViewController, endRefresh);
 
    CHLoadLateClass(SoulUtils);
    CHClassHook2(SoulUtils, makeWatermarkPhotoImageWithImage, watermark);
    CHClassHook1(SoulUtils, makeWatermarkPhotoImageWithImage);
    
    CHLoadLateClass(NewTabBarController);
    CHHook0(NewTabBarController, viewDidLoad);
    
    CHLoadLateClass(SOPrivateChatViewController);
    CHHook0(SOPrivateChatViewController, viewDidLoad);
    CHHook1(SOPrivateChatViewController, _showMenuViewIndexPath);
    
    CHLoadLateClass(AFHTTPSessionManager);
    CHHook8(AFHTTPSessionManager, dataTaskWithHTTPMethod, URLString, parameters, headers,  uploadProgress, downloadProgress, success, failure);
    
    CHLoadLateClass(ScrollerWebController);
    CHHook0(ScrollerWebController, viewDidLoad);
    CHHook2(ScrollerWebController, actionForStartNetworkRequst, callBack);
    CHHook2(ScrollerWebController, webView, didFailLoadWithError);
    CHHook3(ScrollerWebController, webView, shouldStartLoadWithRequest, navigationType);
    CHHook1(ScrollerWebController, webViewDidFinishLoad);
    
    //埋点
    CHLoadLateClass(TalkingData);
    CHClassHook2(TalkingData, sessionStarted, withChannelId);
    CHClassHook2(TalkingData, initWithAppID, channelID);
    
    CHLoadLateClass(KochavaTracker);
    CHHook2(KochavaTracker, configureWithParametersDictionary, delegate);
    
    //bugly
    CHLoadLateClass(Bugly);
    CHHook1(Bugly, startWithAppId);
    CHHook2(Bugly, startWithAppId, config);
    
    //设置头像
    CHLoadLateClass(AvatarModifyViewController);
    CHHook5(AvatarModifyViewController, updateUserInfWithAvatarName, originAvatarName, image, originImage, svgInfo);
    
    CHHook5(AvatarModifyViewController, uploadToQiniu, svginfo, token, imageName, completion);
    CHHook2(AvatarModifyViewController, uploadOriginAvatar, avatarSVGInfo);
    CHHook2(AvatarModifyViewController, uploadAvatar, avatarSVGInfo);
    CHHook0(AvatarModifyViewController, viewDidLoad);
    
    CHHook0(AvatarModifyViewController, customImage);
    CHHook1(AvatarModifyViewController, setCustomImage);
    
    //消息撤回
    CHLoadLateClass(ChatTransCenter);
    CHHook1(ChatTransCenter, receiveMessage);
    CHHook2(ChatTransCenter, sendCommandsMessage, completion);
    
    //阅后即焚
    CHLoadLateClass(SOChatFlashPhotoMessageTableViewCell);
    CHHook0(SOChatFlashPhotoMessageTableViewCell, tapFlashPhoto);
    
    CHLoadLateClass(SOChatPhotoMessageTableViewCell);
    CHHook0(SOChatPhotoMessageTableViewCell, tapIamge);
    
    CHLoadLateClass(SOChatAudioMessageTableViewCell);
    CHHook0(SOChatAudioMessageTableViewCell, run);
    
    CHLoadLateClass(SOChatVideoMessageTableViewCell);
    CHHook0(SOChatVideoMessageTableViewCell, tap);
    CHHook1(SOChatVideoMessageTableViewCell, UpdateSubclassingUIWithChatMessageModel);
    
    CHLoadLateClass(SOUserDefinedEmoticonTableViewCell);
    CHHook0(SOUserDefinedEmoticonTableViewCell, tapIamge);
    
    CHLoadLateClass(SOLookFlashPhotoView);
    CHHook3(SOLookFlashPhotoView, initWithFrame, WithImage, andIsSelf);
    CHHook1(SOLookFlashPhotoView, tapImage);
    CHHook1(SOLookFlashPhotoView, longPressBgView);
    CHHook1(SOLookFlashPhotoView, tapbgView);
    
    
    //表情键盘
    CHLoadLateClass(SOCollectEmoticonView);
    CHHook2(SOCollectEmoticonView, collectionView, didSelectItemAtIndexPath);
    
    //设置页
    CHLoadLateClass(SOSettingsVC);
    CHHook0(SOSettingsVC, viewDidLoad);
    CHHook1(SOSettingsVC, rightItemClick);
    
    //掷骰子&猜拳
    CHLoadLateClass(SOBuildMessageManager);
    CHClassHook2(SOBuildMessageManager, buildRollDiceMessageTo, info);
    CHClassHook2(SOBuildMessageManager, buildFingerGuessMessageTo, info);
    
    //soulmate
    CHLoadLateClass(SOUserInfoViewController);
    CHHook2(SOUserInfoViewController, tableView, didSelectRowAtIndexPath);
    
    //启动图
    CHLoadLateClass(AppShell);
    CHHook0(AppShell, displayAdvert);
    
    //更改头像
    CHLoadLateClass(HeaderTwoViewController);
    CHHook1(HeaderTwoViewController, confirmClick);
    
    CHLoadLateClass(SOMovieVC);
    CHHook0(SOMovieVC, viewDidLoad);

    CHLoadLateClass(SOReleaseViewController);
    CHHook1(SOReleaseViewController, tagEditContainerViewDidLocationItemClick);
}

