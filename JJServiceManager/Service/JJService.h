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
                      identity:(NSString *)identity
                     parameter:(id)parameter
                        object:(id)object
                     otherInfo:(NSDictionary *)otherInfo;

- (void)networkFailResponse:(JJService *)service
                   identity:(NSString *)identity
                  parameter:(id)parameter
                      error:(id)error
                  otherInfo:(NSDictionary *)otherInfo;

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

- (void)serviceResponseCallBack:(NSString *)identity
                      parameter:(id)parameter
                        success:(BOOL)success
                         object:(id)object
                      otherInfo:(NSDictionary *)otherInfo
         networkSuccessResponse:(void (^)(id object, id otherInfo))networkSuccessResponse
            networkFailResponse:(void (^)(id error, id otherInfo))networkFailResponse;

- (void)postServiceResponseNotification:(NSString *)identity
                              parameter:(id)parameter
                                success:(BOOL)success
                                 object:(id)object
                              otherInfo:(NSDictionary *)otherInfo;

- (void)actionAfterLogin;
- (void)actionAfterLogout;

- (void)recordRequestFinishCount:(NSInteger)count;

- (void)saveCustomModel:(id<NSCoding>)model
               identity:(NSString *)identity
             allAccount:(BOOL)allAccount;
- (void)removeCustomModelWithidentity:(NSString *)identity
                           allAccount:(BOOL)allAccount;
- (id)customModelWithidentity:(NSString *)identity
                   allAccount:(BOOL)allAccount;

@end

#pragma mark - Feature Set Macro

#define JJ_SERVICE_FEATURE_SET(serviceObj, featureSet) ((featureSet *)[serviceObj featureSetWithFeatureSetName:[featureSet featureSetName]])

#define JJ_SERVICE_UNLOAD_FEATURE_SET(serviceObj, featureSet) [serviceObj unloadFeatureSetWithFeatureSetName:[featureSet featureSetName]]
