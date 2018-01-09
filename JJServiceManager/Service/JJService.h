//
//  JJService.h
//  ServiceFactory
//
//  Created by JJ on 11/29/15.
//  Copyright © 2015 JJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class JJService;

@protocol JJServiceDelegate <NSObject>

@optional

- (void)networkSuccessResponse:(JJService *)service
                   requestType:(NSString *)requestType
                     parameter:(id)parameter
                        object:(id)object
                     otherInfo:(id)otherInfo;

- (void)networkFailResponse:(JJService *)service
                requestType:(NSString *)requestType
                  parameter:(id)parameter
                      error:(id)error
                  otherInfo:(id)otherInfo;

@end

@interface JJService : NSObject

@property (nonatomic, assign) NSTimeInterval unusedExistSecondTimeInterval;

/**
 *  Return the class name of service, subClass must overwrite.
 *
 *  @return Service class name.
 */
+ (NSString *)serviceName;

/**
 *  Judge if service will be unloaded if no user used it.
 *
 *  @return YES: need
 */
- (BOOL)needUnloading;

- (void)serviceWillLoad;
- (void)serviceDidLoad;

- (void)serviceWillUnload;
- (void)serviceDidUnload;

- (void)addDelegate:(id<JJServiceDelegate>)delegate;
- (void)removeDelegate:(id<JJServiceDelegate>)delegate;
- (void)removeAllDelegate;

- (id)featureSetWithFeatureSetName:(NSString *)featureSetName;

- (void)unloadFeatureSetWithFeatureSetName:(NSString *)featureSetName;

- (void)serviceResponseCallBack:(NSString *)requestType
                      parameter:(id)parameter
                        success:(BOOL)success
                         object:(id)object
                      otherInfo:(id)otherInfo
         networkSuccessResponse:(void (^)(id object, id otherInfo))networkSuccessResponse
            networkFailResponse:(void (^)(id error, id otherInfo))networkFailResponse;

- (void)postServiceResponseNotification:(NSString *)requestType
                              parameter:(id)parameter
                                success:(BOOL)success
                                 object:(id)object
                              otherInfo:(id)otherInfo;

- (void)actionAfterLogin;
- (void)actionAfterLogout;

- (void)recordRequestFinishCount:(NSInteger)count;

- (void)saveCustomModel:(id<NSCoding>)model
          operationType:(NSString *)operationType
             allAccount:(BOOL)allAccount;
- (void)removeCustomModelWithOperationType:(NSString *)operationType
                                allAccount:(BOOL)allAccount;
- (id)customModelWithOperationType:(NSString *)operationType
                        allAccount:(BOOL)allAccount;

@end

#pragma mark - Feature Set Macro

#define jj_SERVICE_FEATURE_SET(serviceObj, featureSet) ((featureSet *)[serviceObj featureSetWithFeatureSetName:[featureSet featureSetName]])

#define jj_SERVICE_UNLOAD_FEATURE_SET(serviceObj, featureSet) [serviceObj unloadFeatureSetWithFeatureSetName:[featureSet featureSetName]]
