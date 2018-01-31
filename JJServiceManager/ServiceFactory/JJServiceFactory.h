//
//  JJServiceFactory.h
//  ServiceFactory
//
//  Created by JJ on 11/29/15.
//  Copyright © 2015 JJ. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Service factory manages all service, include loading and unloading service. You can use jj_SERVICE macro to get specific service.
 */
@interface JJServiceFactory : NSObject

@property (nonatomic, assign) NSTimeInterval checkIntervalOfUnloadingService;

@property (nonatomic, strong) NSArray *loginSuccessNotificationNameArray;
@property (nonatomic, strong) NSArray *logoutNotificationNameArray;

+ (instancetype)sharedServiceFactory;

- (id)serviceWithServiceName:(NSString *)serviceName;

- (void)unloadServiceWithServiceName:(NSString *)serviceName;
- (void)unloadServiceWithServiceName:(NSString *)serviceName
                       isForceUnload:(BOOL)isForceUnload;

@end

#pragma mark - Service Macro

#define jj_SERVICE(service) ((service *)[[JJServiceFactory sharedServiceFactory] serviceWithServiceName:[service serviceName]])

#define jj_UNLOAD_SERVICE(service) [[JJServiceFactory sharedServiceFactory] unloadServiceWithServiceName:[service serviceName]]

#pragma mark - Feature Set Macro

#define jj_FEATURE_SET(service, featureSet) ((featureSet *)[[[JJServiceFactory sharedServiceFactory] serviceWithServiceName:[service serviceName]] featureSetWithFeatureSetName:[featureSet featureSetName]])

#define jj_UNLOAD_FEATURE_SET(service, featureSet) [[[JJServiceFactory sharedServiceFactory] serviceWithServiceName:[service serviceName]] unloadFeatureSetWithFeatureSetName:[featureSet featureSetName]]
