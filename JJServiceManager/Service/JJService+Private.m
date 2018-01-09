//
//  JJService+Private.m
//  
//
//  Created by JJ on 16/8/15.
//  Copyright © 2016年 JJ. All rights reserved.
//

#import "JJService+Private.h"
#import "JJFeatureSet.h"
#import "JJGPModel.h"

NSString *const JJServiceErrorDomain = @"JJServiceErrorDomain";
NSString *const JJServiceErrorResponseKey = @"response";

@implementation JJService (Private)

- (id)GPCacheModelWithOperationType:(NSString *)operationType parameters:(NSDictionary *)parameters requestClass:(Class)requestClass modelClass:(Class)modelClass
{
    JJGPRequest *request = [self GPRequestWithOperationType:operationType parameters:parameters requestClass:requestClass modelClass:modelClass isSaveToDisk:YES];
    return [request cacheModel];
}

- (void)requestGPWithOperationType:(NSString *)operationType parameters:(NSDictionary *)parameters isSaveToDisk:(BOOL)isSaveToDisk requestClass:(Class)requestClass modelClass:(Class)modelClass networkSuccessResponse:(void (^)(id, id))networkSuccessResponse networkFailResponse:(void (^)(NSError *, id))networkFailResponse
{
    JJGPRequest *request = [self GPRequestWithOperationType:operationType parameters:parameters requestClass:requestClass modelClass:modelClass isSaveToDisk:isSaveToDisk];
    
    if (networkSuccessResponse || networkFailResponse) {
        request.networkSuccessResponse = ^(id response, id otherInfo) {
            if ([response isKindOfClass:[JJGPModel class]]) {
                if ([response success]) {
                    if (networkSuccessResponse) {
                        networkSuccessResponse(response, otherInfo);
                    }
                } else {
                    if (networkFailResponse) {
                        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                        userInfo[NSLocalizedDescriptionKey] = [response responseMessage] ?: @"似乎已断开与互联网的连接";
                        if (response) {
                            userInfo[JJServiceErrorResponseKey] = response;
                        }
                        NSError *error = [NSError errorWithDomain:JJServiceErrorDomain code:-1 userInfo:userInfo];
                        networkFailResponse(error, otherInfo);
                    }
                }
            } else {
                if (networkSuccessResponse) {
                    networkSuccessResponse(response, otherInfo);
                }
            }
        };
    }
    
    if (networkFailResponse) {
        request.networkFailResponse = ^(NSError *error, id otherInfo) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            userInfo[NSLocalizedDescriptionKey] = @"似乎已断开与互联网的连接";
            if ([error isKindOfClass:[NSError class]]) {
                userInfo[NSUnderlyingErrorKey] = error;
            }
            error = [NSError errorWithDomain:JJServiceErrorDomain code:error.code userInfo:userInfo];
            networkFailResponse(error, otherInfo);
        };
    }
    
    [JJ_SERVICE_FEATURE_SET(self, JJFeatureSet) startGPRequest:request otherInfo:nil];
}

- (JJGPRequest *)GPRequestWithOperationType:(NSString *)operationType parameters:(NSDictionary *)parameters requestClass:(Class)requestClass modelClass:(Class)modelClass isSaveToDisk:(BOOL)isSaveToDisk
{
    if (!requestClass) {
        requestClass = [JJGPRequest class];
    }
    if (!modelClass) {
        modelClass = [JJGPModel class];
    }
    JJGPRequest *request = [[requestClass alloc] initWithOperationType:operationType parameters:parameters modelClass:modelClass isSaveToMemory:NO isSaveToDisk:isSaveToDisk];
    if (requestClass == [JJGPRequest class]) {
        request.userCacheDirectory = [[self class] serviceName];
    }
    return request;
}

- (id)SFCGPCacheModelWithOperationType:(NSString *)operationType parameters:(NSDictionary *)parameters requestClass:(Class)requestClass isNeedEncryption:(BOOL)isNeedEncryption modelClass:(Class)modelClass
{
    JJSFCRequest *request = [self SFCGPRequestWithOperationType:operationType parameters:parameters requestClass:requestClass modelClass:modelClass isSaveToDisk:YES isNeedEncryption:isNeedEncryption];
    return [request cacheModel];
}

- (void)requestSFCGPWithOperationType:(NSString *)operationType parameters:(NSDictionary *)parameters isSaveToDisk:(BOOL)isSaveToDisk isNeedEncryption:(BOOL)isNeedEncryption requestClass:(Class)requestClass modelClass:(Class)modelClass networkSuccessResponse:(void (^)(id, id))networkSuccessResponse networkFailResponse:(void (^)(NSError *, id))networkFailResponse
{
    JJSFCRequest *request = [self SFCGPRequestWithOperationType:operationType parameters:parameters requestClass:requestClass modelClass:modelClass isSaveToDisk:isSaveToDisk isNeedEncryption:isNeedEncryption];
    if (networkSuccessResponse || networkFailResponse) {
        request.networkSuccessResponse = ^(id response, id otherInfo) {
            if ([response isKindOfClass:[JJGPModel class]]) {
                if ([response success]) {
                    if (networkSuccessResponse) {
                        networkSuccessResponse(response, otherInfo);
                    }
                } else {
                    if (networkFailResponse) {
                        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                        userInfo[NSLocalizedDescriptionKey] = [response responseMessage] ?: @"似乎已断开与互联网的连接";
                        if (response) {
                            userInfo[JJServiceErrorResponseKey] = response;
                        }
                        NSError *error = [NSError errorWithDomain:JJServiceErrorDomain code:-1 userInfo:userInfo];
                        networkFailResponse(error, otherInfo);
                    }
                }
            } else {
                if (networkSuccessResponse) {
                    networkSuccessResponse(response, otherInfo);
                }
            }
        };
    }
    
    if (networkFailResponse) {
        request.networkFailResponse = ^(NSError *error, id otherInfo) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            userInfo[NSLocalizedDescriptionKey] = @"似乎已断开与互联网的连接";
            if ([error isKindOfClass:[NSError class]]) {
                userInfo[NSUnderlyingErrorKey] = error;
            }
            error = [NSError errorWithDomain:JJServiceErrorDomain code:error.code userInfo:userInfo];
            networkFailResponse(error, otherInfo);
        };
    }
    
    [JJ_SERVICE_FEATURE_SET(self, JJFeatureSet) startGPRequest:request otherInfo:nil];
}

- (JJSFCRequest *)SFCGPRequestWithOperationType:(NSString *)operationType parameters:(NSDictionary *)parameters requestClass:(Class)requestClass modelClass:(Class)modelClass isSaveToDisk:(BOOL)isSaveToDisk isNeedEncryption:(BOOL)isNeedEncryption
{
    if (!requestClass) {
        requestClass = [JJSFCRequest class];
    }
    if (!modelClass) {
        modelClass = [JJSFCRequest class];
    }
    JJSFCRequest *request = [[requestClass alloc] initWithOperationType:operationType parameters:parameters modelClass:modelClass isSaveToMemory:NO isSaveToDisk:isSaveToDisk];
    if (requestClass == [JJSFCRequest class]) {
        request.userCacheDirectory = [[self class] serviceName];
    }
    request.isNeedEncryption = isNeedEncryption;
    return request;
}

@end
