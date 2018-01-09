//
//  JJFeatureSet.h
//
//
//  Created by JJ on 12/2/15.
//  Copyright © 2015 JJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JJBaseRequest;
@class JJService;
@class JJBaseRequest;
@class JJGPModel;

@interface JJFeatureSet : NSObject

@property (nonatomic, weak) JJService *service;

/**
 *  Return the class name of feature set, subClass must overwrite.
 *
 *  @return Feature set class name.
 */
+ (NSString *)featureSetName;

- (void)featureSetWillLoad;
- (void)featureSetDidLoad;

- (void)featureSetWillUnload;
- (void)featureSetDidUnload;

- (void)startRequest:(JJBaseRequest *)request
         requestType:(NSString *)requestType
           parameter:(id)parameter
           otherInfo:(id)otherInfo
       successAction:(void (^)(id object, JJBaseRequest *request))successAction
          failAction:(void (^)(NSError *error, JJBaseRequest *request))failAction;

- (void)startRequest:(JJBaseRequest *)request
         requestType:(NSString *)requestType
           parameter:(id)parameter
           otherInfo:(id)otherInfo;

- (void)actionAfterLogin;
- (void)actionAfterLogout;

#pragma mark - GP

- (void)startGPRequest:(JJBaseRequest *)request
             otherInfo:(id)otherInfo
         successAction:(void (^)(id object, JJBaseRequest *request))successAction
            failAction:(void (^)(NSError *error, JJBaseRequest *request))failAction;

- (void)startGPRequest:(JJBaseRequest *)request
             otherInfo:(id)otherInfo;

- (id)cacheModelWithParameters:(NSDictionary *)parameters
                  requestClass:(Class)requestClass
                   requestType:(NSString *)requestType
                    modelClass:(Class)modelClass
                  isSaveToDisk:(BOOL)isSaveToDisk;

- (JJBaseRequest *)requestWithParameters:(NSDictionary *)parameters
                 requestClass:(Class)requestClass
                  requestType:(NSString *)requestType
                   modelClass:(Class)modelClass
                 isSaveToDisk:(BOOL)isSaveToDisk
       networkSuccessResponse:(void(^)(id object, id otherinfo))networkSuccessResponse
          networkFailResponse:(void (^)(NSError *error, id otherinfo))networkFailResponse;

- (JJBaseRequest *)requestWithParameters:(NSDictionary *)parameters_
                           requestClass:(Class)requestClass_
                            requestType:(NSString *)requestType_
                             modelClass:(Class)modelClass_
                           isSaveToDisk:(BOOL)isSaveToDisk_
                       isEncryptRequest:(BOOL)isEncryptRequest_
                 networkSuccessResponse:(void(^)(id object, id otherinfo))networkSuccessResponse_
                    networkFailResponse:(void (^)(NSError *error, id otherinfo))networkFailResponse_;

- (void)removeCacheModelWithParameters:(NSDictionary *)parameters
                  requestClass:(Class)requestClass
                   requestType:(NSString *)requestType
                    modelClass:(Class)modelClass
                  isSaveToDisk:(BOOL)isSaveToDisk;
@end
