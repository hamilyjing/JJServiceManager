//
//  JJService.m
//  ServiceFactory
//
//  Created by JJ on 11/29/15.
//  Copyright © 2015 JJ. All rights reserved.
//

#import "JJService.h"

#import "JJFeatureSet.h"
#import "JJServiceNotification.h"
#import "JJCustomRequest.h"
#import "JJNSMutableDictionaryHelper.h"

@interface JJService ()

@property (nonatomic, strong) NSMutableDictionary *featureSetContainer;

@property (nonatomic, strong) dispatch_semaphore_t delegateListOperationLock;
@property (nonatomic, strong) NSHashTable *delegateList;

@property (nonatomic, strong) dispatch_semaphore_t spinLock;
@property (nonatomic, assign) NSInteger requestFinishCount;

@property (nonatomic, strong) dispatch_semaphore_t featureSetLock;

@property (nonatomic, strong) NSDate *recordExistBeginDate;

@end

@implementation JJService

#pragma mark - life cycle

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.unusedExistSecondTimeInterval = 20;
        self.recordExistBeginDate = [NSDate date];
        
        self.delegateListOperationLock = dispatch_semaphore_create(1);
        
        self.spinLock = dispatch_semaphore_create(1);
        
        self.featureSetLock = dispatch_semaphore_create(1);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessNotification:) name:JJServiceNotificationNameLoginSuccess object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutNotification:) name:JJServiceNotificationNameLogOut object:nil];
    }
    return self;
}

#pragma mark - public

- (NSString *)description
{
    NSString *string = [NSString stringWithFormat:@"%@:%p, requestFinishCount: %@, delegateList: %@", NSStringFromClass([self class]), self, @(self.requestFinishCount), self.delegateList];
    return string;
}

+ (NSString *)serviceName
{
    return NSStringFromClass(self.class);
}

- (BOOL)needUnloading
{
    BOOL need = ([self jj_isEmpty:self.delegateList] && (0 == self.requestFinishCount));
    if (need)
    {
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.recordExistBeginDate];
        need = timeInterval > self.unusedExistSecondTimeInterval;
    }
    
    return need;
}

- (void)serviceWillLoad
{
}

- (void)serviceDidLoad
{
}

- (void)serviceWillUnload
{
}

- (void)serviceDidUnload
{
}

- (void)addDelegate:(id<JJServiceDelegate>)delegate_
{
    [self jj_beginLockDelegateListOperation];
    
    [self.delegateList addObject:delegate_];
    
    [self jj_endLockDelegateListOperation];
}

- (void)removeDelegate:(id<JJServiceDelegate>)delegate_
{
    [self jj_beginLockDelegateListOperation];
    
    [self.delegateList removeObject:delegate_];
    
    [self jj_endLockDelegateListOperation];
}

- (void)removeAllDelegate
{
    [self jj_beginLockDelegateListOperation];
    
    self.delegateList = nil;
    
    [self jj_endLockDelegateListOperation];
}

- (id)featureSetWithFeatureSetName:(NSString *)featureSetName_
{
    NSParameterAssert(featureSetName_);
    
    [self jj_beginLockFeatureSetOperation];
    
    JJFeatureSet *featureSet = self.featureSetContainer[featureSetName_];
    if (featureSet)
    {
        [self jj_endLockFeatureSetOperation];
        return featureSet;
    }
    
    featureSet = [[NSClassFromString(featureSetName_) alloc] init];
    featureSet.service = self;
    [featureSet featureSetWillLoad];
    self.featureSetContainer[featureSetName_] = featureSet;
    [featureSet featureSetDidLoad];
    
    [self jj_endLockFeatureSetOperation];
    return featureSet;
}

- (void)unloadFeatureSetWithFeatureSetName:(NSString *)featureSetName_
{
    NSParameterAssert(featureSetName_);
    
    [self jj_beginLockFeatureSetOperation];
    
    JJFeatureSet *featureSet = self.featureSetContainer[featureSetName_];
    [featureSet featureSetWillUnload];
    [self.featureSetContainer removeObjectForKey:featureSetName_];
    [featureSet featureSetDidUnload];
    
    [self jj_endLockFeatureSetOperation];
}

- (void)serviceResponseCallBack:(NSString *)identity_
                      parameter:(id)parameter_
                        success:(BOOL)success_
                         object:(id)object_
                      otherInfo:(NSDictionary *)otherInfo_
         networkSuccessResponse:(void (^)(id object, id otherInfo))networkSuccessResponse_
            networkFailResponse:(void (^)(id error, id otherInfo))networkFailResponse_
{
    [self jj_beginLockDelegateListOperation];
    
    NSMutableArray *delegateListCopy = [NSMutableArray array];
    for (id<JJServiceDelegate> delegate in self.delegateList)
    {
        [delegateListCopy addObject:delegate];
    }
    
    [self jj_endLockDelegateListOperation];
    
    if (success_)
    {
        if (networkSuccessResponse_)
        {
            networkSuccessResponse_(object_, otherInfo_);
        }
        
        for (id<JJServiceDelegate> delegate in delegateListCopy)
        {
            if ([delegate respondsToSelector:@selector(networkSuccessResponse:identity:parameter:object:otherInfo:)])
            {
                [delegate networkSuccessResponse:self
                                        identity:identity_
                                       parameter:parameter_
                                          object:object_
                                       otherInfo:otherInfo_];
            }
        }
    }
    else
    {
        if (networkFailResponse_)
        {
            networkFailResponse_(object_, otherInfo_);
        }
        
        for (id<JJServiceDelegate> delegate in delegateListCopy)
        {
            if ([delegate respondsToSelector:@selector(networkFailResponse:identity:parameter:error:otherInfo:)])
            {
                [delegate networkFailResponse:self
                                     identity:identity_
                                    parameter:parameter_
                                        error:object_
                                    otherInfo:otherInfo_];
            }
        }
    }
    
    [self postServiceResponseNotification:identity_
                                parameter:parameter_
                                  success:success_
                                   object:object_
                                otherInfo:otherInfo_];
    
    [self recordRequestFinishCount:1];
}

- (void)postServiceResponseNotification:(NSString *)identity_
                              parameter:(id)parameter_
                                success:(BOOL)success_
                                 object:(id)object_
                              otherInfo:(NSDictionary *)otherInfo_
{
    NSString *notificationName = [NSString stringWithFormat:@"%@_%@", NSStringFromClass([self class]), identity_];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [JJNSMutableDictionaryHelper mDictionary:userInfo setObj:self forKey:JJServiceNotificationKeyService];
    [JJNSMutableDictionaryHelper mDictionary:userInfo setObj:parameter_ forKey:JJServiceNotificationKeyParameter];
    [JJNSMutableDictionaryHelper mDictionary:userInfo setObj:@(success_) forKey:JJServiceNotificationKeySuccess];
    [JJNSMutableDictionaryHelper mDictionary:userInfo setObj:object_ forKey:JJServiceNotificationKeyObject];
    [JJNSMutableDictionaryHelper mDictionary:userInfo setObj:otherInfo_ forKey:JJServiceNotificationKeyOtherInfo];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:notificationName
                      object:self
                    userInfo:userInfo];
}

- (void)actionAfterLogin
{
    for (JJFeatureSet *featureSet in [self.featureSetContainer allValues])
    {
        [featureSet actionAfterLogin];
    }
}

- (void)actionAfterLogout
{
    for (JJFeatureSet *featureSet in [self.featureSetContainer allValues])
    {
        [featureSet actionAfterLogout];
    }
}

- (void)recordRequestFinishCount:(NSInteger)count_
{
    dispatch_semaphore_wait(_spinLock, DISPATCH_TIME_FOREVER);
    
    self.requestFinishCount = self.requestFinishCount + count_;
    
    if (count_ > 0)
    {
        self.recordExistBeginDate = [NSDate date];
    }
    
    dispatch_semaphore_signal(_spinLock);
}

- (void)saveCustomModel:(id<NSCoding>)model
               identity:(NSString *)identity
             allAccount:(BOOL)allAccount
{
    JJCustomRequest *request = [self jj_customRequestWithidentity:identity allAccount:allAccount];
    
    [request saveObjectToDiskCache:model];
}

- (void)removeCustomModelWithidentity:(NSString *)identity
                           allAccount:(BOOL)allAccount
{
    JJCustomRequest *request = [self jj_customRequestWithidentity:identity allAccount:allAccount];
    
    [request removeDiskCache];
}

- (id)customModelWithidentity:(NSString *)identity
                   allAccount:(BOOL)allAccount
{
    JJCustomRequest *request = [self jj_customRequestWithidentity:identity allAccount:allAccount];
    
    id model = [request cacheModel];
    return model;
}

#pragma mark - notification

- (void)loginSuccessNotification:(NSNotification *)notification_
{
    [self actionAfterLogin];
}

- (void)logoutNotification:(NSNotification *)notification_
{
    [self actionAfterLogout];
}

#pragma mark - private

- (void)jj_beginLockDelegateListOperation
{
    dispatch_semaphore_wait(_delegateListOperationLock, DISPATCH_TIME_FOREVER);
}

- (void)jj_endLockDelegateListOperation
{
    dispatch_semaphore_signal(_delegateListOperationLock);
}

- (void)jj_beginLockFeatureSetOperation
{
    dispatch_semaphore_wait(_featureSetLock, DISPATCH_TIME_FOREVER);
}

- (void)jj_endLockFeatureSetOperation
{
    dispatch_semaphore_signal(_featureSetLock);
}

- (BOOL)jj_isEmpty:(NSHashTable *)hashTable
{
    NSEnumerator *enumerator = [hashTable objectEnumerator];
    id value;
    
    while ((value = [enumerator nextObject]))
    {
        return NO;
    }
    
    return YES;
}

- (JJCustomRequest *)jj_customRequestWithidentity:(NSString *)identity
                                       allAccount:(BOOL)allAccount
{
    JJCustomRequest *request = [[JJCustomRequest alloc] initWithIdentity:identity parameters:nil modelClass:nil isSaveToMemory:NO isSaveToDisk:YES];
    if (allAccount) {
        request.sensitiveDataForSavedFileName = @"";
    }
    
    request.userCacheDirectory = [[self class] serviceName];
    
    return request;
}

#pragma mark getter and setter

- (NSMutableDictionary *)featureSetContainer
{
    if (_featureSetContainer)
    {
        return _featureSetContainer;
    }
    
    _featureSetContainer = [NSMutableDictionary dictionary];
    return _featureSetContainer;
}

- (NSHashTable *)delegateList
{
    if (_delegateList)
    {
        return _delegateList;
    }
    
    _delegateList = [NSHashTable weakObjectsHashTable];
    return _delegateList;
}

@end

