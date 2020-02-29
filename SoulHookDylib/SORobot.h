//
//  SORobot.h
//  SoulHookDylib
//
//  Created by fan on 2019/11/23.
//  Copyright © 2019 fancy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SONetworkingMethod) {
    SONetworkingMethodGet,
    SONetworkingMethodPost
};

@class UIViewController;
@interface SOHookManager : NSObject

@property (nonatomic, strong) UIViewController *aSubSquareNoNameViewController;

+ (instancetype)sharedInstance;

@end

@interface SONetworking : NSObject

+ (NSURLSessionDataTask *)requestWithMethod:(SONetworkingMethod)method
                                        url:(NSString *)urlString
                                      param:(nullable NSDictionary *)param
                                   finished:(void (^)(id _Nullable responseObject, NSError * _Nullable error))finished;

@end


@interface SORobot : NSObject

+ (void)answerWithKey:(NSString *)key
             finished:(void (^)(NSString * _Nullable answer, NSError * _Nullable error))finished;

@end

@interface SOIMManager : NSObject

+ (void)sendText:(NSString *)text
          toUser:(NSString *)userId
        finished:(nullable void (^)(void))finished;

+ (void)sendRead:(NSString *)cmdId
          toUser:(NSString *)userId
        finished:(nullable void (^)(void))finished;

@end

NS_ASSUME_NONNULL_END
