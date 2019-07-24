//  weibo: http://weibo.com/xiaoqing28
//  blog:  http://www.alonemonkey.com
//
//  SoulHookDylib.m
//  SoulHookDylib
//
//  Created by 月成 on 2019/7/15.
//  Copyright (c) 2019 fancy. All rights reserved.
//

#import "SoulHookDylib.h"
#import <CaptainHook/CaptainHook.h>
#import <UIKit/UIKit.h>
#import <Cycript/Cycript.h>
#import <MDCycriptManager.h>
#import "SoulHeader.h"

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

CHDeclareClass(KochavaTracker)

CHOptimizedMethod2(self, void, KochavaTracker, configureWithParametersDictionary, NSDictionary *, dic, delegate, id, delegate) {
    NSLog(@"KochavaTracker == %@ %@", dic, delegate);
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
            if (self.avatarName && self.avatarOriginName) {
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
        button.backgroundColor = [UIColor colorWithRed:37/255.0 green:212/255.0 blue:208/255.0 alpha:1];
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
        cancelButton.backgroundColor = [UIColor colorWithRed:37/255.0 green:212/255.0 blue:208/255.0 alpha:1];
        cancelButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
        cancelButton.layer.cornerRadius = 22;
        cancelButton.layer.masksToBounds = YES;
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(width - 110, CGRectGetMaxY(imageView.frame) + 30, 100, 44)];
        confirmButton.backgroundColor = [UIColor colorWithRed:37/255.0 green:212/255.0 blue:208/255.0 alpha:1];
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
            return;
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
            
            Class soBuildMessageManager = NSClassFromString(@"SOBuildMessageManager");
            SEL build = NSSelectorFromString(@"buildTextIMMessage:to:senstive:messageExt:");
            IMP buildImp = [soBuildMessageManager methodForSelector:build];
            id (*func1)(id, SEL, NSString *, NSString *, int, id) = (void *)buildImp;
            id msg = func1(soBuildMessageManager, build, text, msgCommand.from, 0, nil);
            
            Class nbIMService = NSClassFromString(@"NBIMService");
            SEL instance = NSSelectorFromString(@"sharedInstance");
            IMP instanceImp = [nbIMService methodForSelector:instance];
            id (*func2)(id, SEL) = (void *)instanceImp;
            id manager = func2(nbIMService, instance);
            
            ChatTransCenter *chatCenter = [manager valueForKey:@"chatCenter"];
            
            dispatch_block_t block = ^(){
                NSLog(@"自动回复成功");
            };
            
            [chatCenter sendCommandsMessage:msg completion:block];
        }
    }
    
    if (msgCommand.type == 8) {
        ////0=text 1=image 3=video 4=voice 8=RECALL 11=finger 12=dice 29=position
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
                    msgContent = [soulIMmessage.voiceIMModel valueForKey:@"url"];
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
        pasteboard.string = self.model.voiceIMModel.url;
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

CHDeclareClass(MoveViewController)

CHOptimizedMethod0(self, void, MoveViewController, viewDidLoad) {
    CHSuper0(MoveViewController, viewDidLoad);
    
    NSMutableArray <NSArray *>*titleArr = [self valueForKey:@"titleArr"];
    NSMutableArray <NSArray *>*iconArr =  [self valueForKey:@"iconArr"];
    
    NSMutableArray *lastTitleSection = titleArr.lastObject.mutableCopy;
    [lastTitleSection addObject:@"Hook设置"];
    NSMutableArray *lastImageSection = iconArr.lastObject.mutableCopy;
    [lastImageSection addObject:@"more_icon_set"];
    
    [titleArr replaceObjectAtIndex:titleArr.count - 1 withObject:lastTitleSection];
    [iconArr replaceObjectAtIndex:iconArr.count - 1 withObject:lastImageSection];
    
    [self.tableView reloadData];
}


CHOptimizedMethod2(self, void, MoveViewController, tableView, UITableView *, tableView, didSelectRowAtIndexPath, NSIndexPath *, indexPath) {
    if (indexPath.section == 3 && indexPath.row == 2) {
        SOHookSettingController *setting = [[SOHookSettingController alloc] init];
        [self.navigationController pushViewController:setting animated:YES];
    } else {
        CHSuper2(MoveViewController, tableView, tableView, didSelectRowAtIndexPath, indexPath);
    }
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
    
    if (indexPath.row == 12) {
        BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_SOULMATE_SWITCH];
        if (enable) {
            self.isCanCreatSoulMate = YES;
        }
        CHSuper2(SOUserInfoViewController, tableView, tableView, didSelectRowAtIndexPath, indexPath);
    } else {
        CHSuper2(SOUserInfoViewController, tableView, tableView, didSelectRowAtIndexPath, indexPath);
    }
}



CHDeclareClass(AppDelegate)

CHOptimizedMethod0(self, void, AppDelegate, displayAdvert) {
    BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_ADVERT_SWITCH];
    if (!enable) {
        CHSuper0(AppDelegate, displayAdvert);
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

CHDeclareClass(MatchChatViewController)

CHOptimizedMethod0(self, void, MatchChatViewController, playmusic) {
    BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_MATCH_BGM_SWITCH];
    if (enable) {
        return;
    }
    CHSuper0(MatchChatViewController, playmusic);
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

CHMethod7(NSURLSessionDataTask *, AFHTTPSessionManager, dataTaskWithHTTPMethod, NSString *, method, URLString, NSString *, URLString, parameters, id, parameters, uploadProgress, progressBlock, uploadProgress, downloadProgress, progressBlock, downloadProgress, success, successBlock, success, failure, failureBlock, failure) {
    
    successBlock successB = ^(NSURLSessionDataTask *task, id _Nullable responseObject) {
        NSLog(@"AFHTTPSessionManager:\nmethod=%@ \nURLString=%@ \nparameters=%@ \nresponseObject=%@", method, URLString, parameters, responseObject);
        
        if ([URLString isEqualToString:@"https://pay.soulapp.cn/face/product/get-paid-list"]) {
            BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_AVATAR_SWITCH];
            if (enable) {
                responseObject = [NSMutableDictionary dictionaryWithDictionary:responseObject];
                [responseObject setObject:@[] forKey:@"data"];
            }
        }
        
        if ([URLString containsString:@"account/fastLogin"]) {
            BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_BIRTHDAY_GENDER_SWITCH];
            if (enable) {
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
        
        
        !success ? : success(task, responseObject);
    };
    
    
    NSURLSessionDataTask *task = CHSuper7(AFHTTPSessionManager, dataTaskWithHTTPMethod, method, URLString, URLString, parameters, parameters, uploadProgress, uploadProgress, downloadProgress, downloadProgress, success, successB, failure, failure);
    
    return task;
}

CHDeclareClass(SOPrivateChatViewController)

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
    });
}

CHDeclareClass(SoulUtils)

CHOptimizedClassMethod2(self, id, SoulUtils, makeWatermarkPhotoImageWithImage, id, arg1, watermark, id, arg2) {
    
    BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SOUL_HOOK_WATER_MARK_SWITCH];
    
    if (enable) {
        arg2 = nil;
    }
    return CHSuper2(SoulUtils, makeWatermarkPhotoImageWithImage, arg1, watermark, arg2);
}

CHConstructor {
    CHLoadLateClass(SoulUtils);
    CHClassHook2(SoulUtils, makeWatermarkPhotoImageWithImage, watermark);
    
    CHLoadLateClass(NewTabBarController);
    CHHook0(NewTabBarController, viewDidLoad);
    
    CHLoadLateClass(SOPrivateChatViewController);
    CHHook1(SOPrivateChatViewController, _showMenuViewIndexPath);
    
    CHLoadLateClass(AFHTTPSessionManager);
    CHHook7(AFHTTPSessionManager, dataTaskWithHTTPMethod, URLString, parameters, uploadProgress, downloadProgress, success, failure);
    
    CHLoadLateClass(ScrollerWebController);
    CHHook0(ScrollerWebController, viewDidLoad);
    CHHook2(ScrollerWebController, actionForStartNetworkRequst, callBack);
    CHHook2(ScrollerWebController, webView, didFailLoadWithError);
    CHHook3(ScrollerWebController, webView, shouldStartLoadWithRequest, navigationType);
    CHHook1(ScrollerWebController, webViewDidFinishLoad);
    
    //埋点
    CHLoadLateClass(TalkingData);
    CHClassHook2(TalkingData, sessionStarted, withChannelId);
    
    CHLoadLateClass(KochavaTracker);
    CHHook2(KochavaTracker, configureWithParametersDictionary, delegate);
    
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
    CHLoadLateClass(MoveViewController);
    CHHook0(MoveViewController, viewDidLoad);
    CHHook2(MoveViewController, tableView, didSelectRowAtIndexPath);
    
    //掷骰子&猜拳
    CHLoadLateClass(SOBuildMessageManager);
    CHClassHook2(SOBuildMessageManager, buildRollDiceMessageTo, info);
    CHClassHook2(SOBuildMessageManager, buildFingerGuessMessageTo, info);
    
    //soulmate
    CHLoadLateClass(SOUserInfoViewController);
    CHHook2(SOUserInfoViewController, tableView, didSelectRowAtIndexPath);
    
    //启动图
    CHLoadLateClass(AppDelegate);
    CHHook0(AppDelegate, displayAdvert);
    
    //更改头像
    CHLoadLateClass(HeaderTwoViewController);
    CHHook1(HeaderTwoViewController, confirmClick);
    
    //匹配时音乐播放
    CHLoadLateClass(MatchChatViewController);
    CHHook0(MatchChatViewController, playmusic);
    
    CHLoadLateClass(SOMovieVC);
    CHHook0(SOMovieVC, viewDidLoad);
    
    
    CHLoadLateClass(SOReleaseViewController);
    CHHook1(SOReleaseViewController, tagEditContainerViewDidLocationItemClick);
}

