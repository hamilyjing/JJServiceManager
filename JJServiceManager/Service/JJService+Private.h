//
//  JJService+Private.h
//  
//
//  Created by JJ on 16/8/15.
//  Copyright © 2016年 JJ. All rights reserved.
//

#import "JJService.h"
#import "JJGPRequest.h"
#import "JJSFCRequest.h"

extern NSString *const JJServiceErrorDomain;
extern NSString *const JJServiceErrorResponseKey;

@interface JJService (Private)

- (id)GPCacheModelWithOperationType:(NSString *)operationType parameters:(NSDictionary *)parameters requestClass:(Class)requestClass modelClass:(Class)modelClass;

- (void)requestGPWithOperationType:(NSString *)operationType parameters:(NSDictionary *)parameters isSaveToDisk:(BOOL)isSaveToDisk requestClass:(Class)requestClass modelClass:(Class)modelClass networkSuccessResponse:(void (^)(id object, id otherInfo))networkSuccessResponse networkFailResponse:(void (^)(NSError *error, id otherInfo))networkFailResponse;

- (JJGPRequest *)GPRequestWithOperationType:(NSString *)operationType parameters:(NSDictionary *)parameters requestClass:(Class)requestClass modelClass:(Class)modelClass isSaveToDisk:(BOOL)isSaveToDisk;



- (id)SFCGPCacheModelWithOperationType:(NSString *)operationType parameters:(NSDictionary *)parameters requestClass:(Class)requestClass isNeedEncryption:(BOOL)isNeedEncryption modelClass:(Class)modelClass;

- (void)requestSFCGPWithOperationType:(NSString *)operationType parameters:(NSDictionary *)parameters isSaveToDisk:(BOOL)isSaveToDisk isNeedEncryption:(BOOL)isNeedEncryption requestClass:(Class)requestClass modelClass:(Class)modelClass networkSuccessResponse:(void (^)(id object, id otherInfo))networkSuccessResponse networkFailResponse:(void (^)(NSError *error, id otherInfo))networkFailResponse;


@end
