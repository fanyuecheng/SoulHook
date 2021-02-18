//
//  SORobot.m
//  SoulHookDylib
//
//  Created by fan on 2019/11/23.
//  Copyright © 2019 fancy. All rights reserved.
//

#import "SORobot.h"
#import "SOHeader.h"

#define SO_TOBOT_HOST        @"http://i.itpk.cn/api.php"
#define SO_TOBOT_API_KEY     @"7ab9524762524779626e9a04ef83bff7"
#define SO_TOBOT_API_SECRET  @"q02w2fla6dv7"

@implementation SOHookManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static SOHookManager *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

- (instancetype)init {
    if (self = [super init]) {
        Class nbIMService = NSClassFromString(@"NBIMService");
        SEL instance = NSSelectorFromString(@"sharedInstance");
        IMP instanceImp = [nbIMService methodForSelector:instance];
        id (*func2)(id, SEL) = (void *)instanceImp;
        id manager = func2(nbIMService, instance);
        ChatTransCenter *chatCenter = [manager valueForKey:@"chatCenter"];
        self.chatTransCenter = chatCenter;
    }
    return self;
}

@end

@implementation SONetworking

+ (NSURLSessionDataTask *)requestWithMethod:(SONetworkingMethod)method
                                        url:(NSString *)urlString
                                      param:(NSDictionary *)param
                                   finished:(void (^)(id responseObject, NSError *error))finished {
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        !finished ? : finished(nil, [NSError errorWithDomain:@"Illegal URL" code:NSURLErrorBadURL userInfo:nil]);
        return nil;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = (method == SONetworkingMethodGet) ? @"GET" : @"POST";
    
    if (param) {
        NSError *error = nil;
        NSData *HTTPBody = [NSJSONSerialization dataWithJSONObject:param options:0 error:&error];
        if (HTTPBody) {
            request.HTTPBody = HTTPBody;
        }
    }
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        id responseObject = nil;
        if (data) {
            NSError *error;
            responseObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            if (!responseObject) {
                responseObject = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
        }
        NSLog(@"请求结束：response:%p error:%@", data, error);
        dispatch_async(dispatch_get_main_queue(), ^{
           !finished ? : finished(responseObject, error);
        });
    }];
    [task resume];
    
    return task;
}

@end

@implementation SORobot

+ (void)answerWithKey:(NSString *)key
             finished:(void (^)(NSString *answer, NSError *error))finished {
    
    if (!key || !key.length) {
        !finished ? : finished(nil, [NSError errorWithDomain:@"key error" code:-9999 userInfo:nil]);
    }
    
    NSString *url = [[NSString stringWithFormat:@"%@?api_key=%@&api_secret=%@&question=%@", SO_TOBOT_HOST, SO_TOBOT_API_KEY, SO_TOBOT_API_SECRET, key] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [SONetworking requestWithMethod:SONetworkingMethodGet
                                url:url
                              param:nil
                           finished:^(id  _Nonnull responseObject, NSError * _Nonnull error) {
        !finished ? : finished(responseObject, error);
    }];
}

@end

@implementation SOIMManager

+ (void)sendText:(NSString *)text
          toUser:(NSString *)userId
        finished:(void (^)(void))finished {
    
    if (!text.length || !userId.length) {
        return;
    }
    
    Class soBuildMessageManager = NSClassFromString(@"SOBuildMessageManager");
    SEL build = NSSelectorFromString(@"buildTextIMMessage:to:senstive:messageExt:");
    IMP buildImp = [soBuildMessageManager methodForSelector:build];
    id (*func1)(id, SEL, NSString *, NSString *, int, id) = (void *)buildImp;
    id msg = func1(soBuildMessageManager, build, text, userId, 0, nil);

    ChatTransCenter *chatCenter = [SOHookManager sharedInstance].chatTransCenter;
               
    dispatch_block_t block = ^(){
        NSLog(@"发送成功");
        !finished ? : finished();
    };
               
    [chatCenter sendCommandsMessage:msg completion:block];
}

+ (void)sendRead:(NSString *)cmdId
          toUser:(NSString *)userId
        finished:(nullable void (^)(void))finished {
    
    if (!cmdId || !userId) {
        return;
    }
    
    Class soBuildMessageManager = NSClassFromString(@"SOBuildMessageManager");
    SEL build = NSSelectorFromString(@"buildSingleReadIMMessageTo:targetId:messageExt:");
    IMP buildImp = [soBuildMessageManager methodForSelector:build];
    id (*func1)(id, SEL, NSString *, NSString *, id) = (void *)buildImp;
    id msg = func1(soBuildMessageManager, build, userId, cmdId, nil);
               
    ChatTransCenter *chatCenter = [SOHookManager sharedInstance].chatTransCenter;
               
    dispatch_block_t block = ^(){
        NSLog(@"发送成功");
        !finished ? : finished();
    };
               
    [chatCenter sendCommandsMessage:msg completion:block];
}

@end
