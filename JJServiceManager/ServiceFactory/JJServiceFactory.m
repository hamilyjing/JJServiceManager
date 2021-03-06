//
//  JJServiceFactory.m
//  ServiceFactory
//
//  Created by JJ on 11/29/15.
//  Copyright © 2015 JJ. All rights reserved.
//

#import "JJServiceFactory.h"

#import "JJService.h"
#import "JJServiceNotification.h"

@interface JJServiceFactory ()

@property (nonatomic, strong) NSMutableDictionary *serviceContainer;
@property (nonatomic, strong) dispatch_semaphore_t operateLock;

@property (nonatomic, strong) NSDate *beginDateOfUnloadingService;

@end

@implementation JJServiceFactory

#pragma mark - life cycle

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - public

+ (instancetype)sharedServiceFactory
{
    static dispatch_once_t once;
    static JJServiceFactory *instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
        instance.operateLock = dispatch_semaphore_create(1);
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
    
    [self jj_beginOperateLock];
    
    JJService *service = self.serviceContainer[serviceName_];
    if (service)
    {
        [self jj_endOperateLock];
        return service;
    }
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.beginDateOfUnloadingService];
    BOOL isNeedUnload = timeInterval > self.checkIntervalOfUnloadingService;
    if (isNeedUnload)
    {
        [self jj_unloadUnneededServiceWithNoLock];
        self.beginDateOfUnloadingService = [NSDate date];
    }
    
    service = [[NSClassFromString(serviceName_) alloc] init];
    [service serviceWillLoad];
    self.serviceContainer[serviceName_] = service;
    [service serviceDidLoad];
    
    [self jj_endOperateLock];
    
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
    
    [self jj_beginOperateLock];
    
    JJService *service = self.serviceContainer[serviceName_];
    
    if (!isForceUnload_ && ![service needUnloading])
    {
        [self jj_endOperateLock];
        
        return;
    }
    
    [service serviceWillUnload];
    [self.serviceContainer removeObjectForKey:serviceName_];
    [service serviceDidUnload];
    
    [self jj_endOperateLock];
}

#pragma mark - notification

- (void)loginSuccessNotification:(NSNotification *)notification_
{
    [[NSNotificationCenter defaultCenter] postNotificationName:JJServiceNotificationNameLoginSuccess object:nil];
}

- (void)logoutNotification:(NSNotification *)notification_
{
    [[NSNotificationCenter defaultCenter] postNotificationName:JJServiceNotificationNameLogOut object:nil];
}

#pragma mark - private

- (void)jj_beginOperateLock
{
    dispatch_semaphore_wait(_operateLock, DISPATCH_TIME_FOREVER);
}

- (void)jj_endOperateLock
{
    dispatch_semaphore_signal(_operateLock);
}

- (void)jj_unloadUnneededServiceWithNoLock
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

- (void)setLoginSuccessNotificationNameArray:(NSArray *)loginSuccessNotificationNameArray
{
    [_loginSuccessNotificationNameArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:obj object:nil];
    }];
    
    _loginSuccessNotificationNameArray = loginSuccessNotificationNameArray;
    
    [_loginSuccessNotificationNameArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessNotification:) name:obj object:nil];
    }];
}

- (void)setLogoutNotificationNameArray:(NSArray *)logoutNotificationNameArray
{
    [_logoutNotificationNameArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:obj object:nil];
    }];
    
    _logoutNotificationNameArray = logoutNotificationNameArray;
    
    [_logoutNotificationNameArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutNotification:) name:obj object:nil];
    }];
}

@end
