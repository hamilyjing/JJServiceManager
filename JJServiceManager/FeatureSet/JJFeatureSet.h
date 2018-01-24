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

- (void)actionAfterLogin;
- (void)actionAfterLogout;

- (void)startRequest:(JJBaseRequest *)request
            identity:(NSString *)identity
           parameter:(id)parameter
           otherInfo:(NSDictionary *)otherInfo
       successAction:(void (^)(id object, JJBaseRequest *request))successAction
          failAction:(void (^)(NSError *error, JJBaseRequest *request))failAction;

- (void)startRequest:(JJBaseRequest *)request
            identity:(NSString *)identity
           parameter:(id)parameter
           otherInfo:(NSDictionary *)otherInfo;

- (void)startRequest:(JJBaseRequest *)request
           otherInfo:(NSDictionary *)otherInfo
       successAction:(void (^)(id object, JJBaseRequest *request))successAction
          failAction:(void (^)(NSError *error, JJBaseRequest *request))failAction;

- (void)startRequest:(JJBaseRequest *)request
           otherInfo:(NSDictionary *)otherInfo;

- (id)cacheModelWithParameters:(NSDictionary *)parameters
                  requestClass:(Class)requestClass
                      identity:(NSString *)identity
                    modelClass:(Class)modelClass
                  isSaveToDisk:(BOOL)isSaveToDisk;

- (void)removeCacheModelWithParameters:(NSDictionary *)parameters
                          requestClass:(Class)requestClass
                              identity:(NSString *)identity
                            modelClass:(Class)modelClass
                          isSaveToDisk:(BOOL)isSaveToDisk;

- (JJBaseRequest *)requestWithParameters:(NSDictionary *)parameters
                            requestClass:(Class)requestClass
                                identity:(NSString *)identity
                              modelClass:(Class)modelClass
                            isSaveToDisk:(BOOL)isSaveToDisk
                  networkSuccessResponse:(void(^)(id object, id otherinfo))networkSuccessResponse
                     networkFailResponse:(void (^)(NSError *error, id otherinfo))networkFailResponse;

@end

