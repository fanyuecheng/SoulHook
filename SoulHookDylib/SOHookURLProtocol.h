//
//  SOHookURLProtocol.h
//  SoulHookDylib
//
//  Created by 月成 on 2019/7/15.
//  Copyright © 2019 fancy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOHookURLProtocol : NSURLProtocol

@property (nonatomic, copy) NSURLRequest *(^requestBlock)(NSURLRequest *request);

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
