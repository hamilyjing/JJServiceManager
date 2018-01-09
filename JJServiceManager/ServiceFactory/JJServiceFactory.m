//
//  JJServiceFactory.m
//  ServiceFactory
//
//  Created by JJ on 11/29/15.
//  Copyright © 2015 JJ. All rights reserved.
//

#import "JJServiceFactory.h"

#import <os/lock.h>

#import "JJService.h"

@interface JJServiceFactory ()

@property (nonatomic, strong) NSMutableDictionary *serviceContainer;
@property (nonatomic, assign) os_unfair_lock_t operateLock;

@property (nonatomic, strong) NSDate *beginDateOfUnloadingService;

@end

@implementation JJServiceFactory

#pragma mark - public

+ (instancetype)sharedServiceFactory
{
    static dispatch_once_t once;
    static JJServiceFactory *instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
        instance.operateLock = &(OS_UNFAIR_LOCK_INIT);
        instance.checkIntervalOfUnloadingService = 10;
        instance.beginDateOfUnloadingService = [NSDate date];
    });
    return instance;
}

- (id)serviceWithServiceName:(NSString *)serviceName_
{
    if (nil == serviceName_)
    {
        NSParameterAssert(serviceName_);
        return nil;
    }
    
    [self yzt_beginOperateLock];
    
    JJService *service = self.serviceContainer[serviceName_];
    if (service)
    {
        [self yzt_endOperateLock];
        return service;
    }
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.beginDateOfUnloadingService];
    BOOL isNeedUnload = timeInterval > self.checkIntervalOfUnloadingService;
    if (isNeedUnload)
    {
        [self yzt_unloadUnneededServiceWithNoLock];
        self.beginDateOfUnloadingService = [NSDate date];
    }
    
    service = [[NSClassFromString(serviceName_) alloc] init];
    [service serviceWillLoad];
    self.serviceContainer[serviceName_] = service;
    [service serviceDidLoad];
    
    [self yzt_endOperateLock];
    
    return service;
}

- (void)unloadServiceWithServiceName:(NSString *)serviceName_
{
    [self unloadServiceWithServiceName:serviceName_ isForceUnload:NO];
}

- (void)unloadServiceWithServiceName:(NSString *)serviceName_
                       isForceUnload:(BOOL)isForceUnload_
{
    NSParameterAssert(serviceName_);
    
    [self yzt_beginOperateLock];
    
    JJService *service = self.serviceContainer[serviceName_];
    
    if (!isForceUnload_ && ![service needUnloading])
    {
        [self yzt_endOperateLock];
        
        return;
    }
    
    [service serviceWillUnload];
    [self.serviceContainer removeObjectForKey:serviceName_];
    [service serviceDidUnload];
    
    [self yzt_endOperateLock];
}

#pragma mark - private

- (void)yzt_beginOperateLock
{
    os_unfair_lock_lock(self.operateLock);
}

- (void)yzt_endOperateLock
{
    os_unfair_lock_unlock(self.operateLock);
}

- (void)yzt_unloadUnneededServiceWithNoLock
{
    NSMutableArray *unloadingKeys = [NSMutableArray array];
    
    [self.serviceContainer enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, JJService * _Nonnull obj, BOOL * _Nonnull stop)
    {
        if ([obj needUnloading])
        {
            [unloadingKeys addObject:key];
        }
    }];
    
    [self.serviceContainer removeObjectsForKeys:unloadingKeys];
}

#pragma mark - getter and setter

- (NSMutableDictionary *)serviceContainer
{
    if (_serviceContainer)
    {
        return _serviceContainer;
    }
    
    _serviceContainer = [NSMutableDictionary dictionary];
    return _serviceContainer;
}

@end
