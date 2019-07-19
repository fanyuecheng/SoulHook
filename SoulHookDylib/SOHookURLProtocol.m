//
//  SOHookURLProtocol.m
//  SoulHookDylib
//
//  Created by 月成 on 2019/7/15.
//  Copyright © 2019 fancy. All rights reserved.
//

#import "SOHookURLProtocol.h"

#define kProtocolKey @"SOSessionProtocolKey"

@interface SOHookURLProtocol() <NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation SOHookURLProtocol

+ (void)load {
    [super load];
    
//    [NSURLProtocol registerClass:[SOHookURLProtocol class]];
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static SOHookURLProtocol *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    // 修改了请求的头部信息
    // NSMutableURLRequest * mutableReq = [request mutableCopy];
    // NSMutableDictionary * headers = [mutableReq.allHTTPHeaderFields mutableCopy];
    // NSURL *URL = request.URL;
    return [[SOHookURLProtocol sharedInstance] requestBlockForRequst:request];
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if ([NSURLProtocol propertyForKey:kProtocolKey inRequest:request]) {
        return NO;
    }

    return YES;
}

- (void)startLoading {
    NSMutableURLRequest * request = [self.request mutableCopy];
    [NSURLProtocol setProperty:@(YES) forKey:kProtocolKey inRequest:request];
    NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask * task = [self.session dataTaskWithRequest:request];
    [task resume];
}

- (void)stopLoading {
    [self.session invalidateAndCancel];
    self.session = nil;
}

+ (BOOL)isUrl:(NSString *)url {
    return [url.lowercaseString containsString:@"http"] || [url.lowercaseString containsString:@"https"];
}

- (NSURLRequest *)requestBlockForRequst:(NSURLRequest *)request {
    if (self.requestBlock) {
        return self.requestBlock(request);
    } else {
        return request;
    }
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        [self.client URLProtocol:self didFailWithError:error];
    } else {
        [self.client URLProtocolDidFinishLoading:self];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler {
    completionHandler(proposedResponse);
}

@end
