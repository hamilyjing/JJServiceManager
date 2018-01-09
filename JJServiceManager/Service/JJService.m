//
//  JJService.m
//  ServiceFactory
//
//  Created by JJ on 11/29/15.
//  Copyright © 2015 JJ. All rights reserved.
//

#import "JJService.h"

#import <libkern/OSAtomic.h>

#import "JJFeatureSet.h"
#import "JJServiceNotification.h"
#import "JJCustomRequest.h"
#import <JJ_iOS_HttpTransportService/JJNSMutableDictionaryHelper.h>

// login
extern NSString *JJLoginServiceLoginSuccessNotification;       //JJLoginService_LoginSuccess

// logout
extern NSString *JJLoginServiceServerForceLogoutNotification;  //JJLoginServiceServerForceLogoutNotification
extern NSString *JJLoginServiceLogOutNotification;             //JJLoginService_logOut

@interface JJService ()

@property (nonatomic, strong) NSMutableDictionary *featureSetContainer;

@property (nonatomic, assign) OSSpinLock delegateListOperationLock;
@property (nonatomic, strong) NSHashTable *delegateList;

@property (nonatomic, assign) OSSpinLock spinLock;
@property (nonatomic, assign) NSInteger requestFinishCount;

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
        
        self.delegateListOperationLock = OS_SPINLOCK_INIT;
        
        self.spinLock = OS_SPINLOCK_INIT;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessNotification:) name:@"JJLoginService_LoginSuccess" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutNotification:) name:@"JJLoginServiceServerForceLogoutNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutNotification:) name:@"JJLoginService_logOut" object:nil];
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
    BOOL need = ([self yzt_isEmpty:self.delegateList] && (0 == self.requestFinishCount));
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
    [self yzt_beginLockDelegateListOperation];
    
    [self.delegateList addObject:delegate_];
    
    [self yzt_endLockDelegateListOperation];
}

- (void)removeDelegate:(id<JJServiceDelegate>)delegate_
{
    [self yzt_beginLockDelegateListOperation];
    
    [self.delegateList removeObject:delegate_];
    
    [self yzt_endLockDelegateListOperation];
}

- (void)removeAllDelegate
{
    [self yzt_beginLockDelegateListOperation];
    
    self.delegateList = nil;
    
    [self yzt_endLockDelegateListOperation];
}

- (id)featureSetWithFeatureSetName:(NSString *)featureSetName_
{
    NSParameterAssert(featureSetName_);
    
    JJFeatureSet *featureSet = self.featureSetContainer[featureSetName_];
    if (featureSet)
    {
        return featureSet;
    }
    
    featureSet = [[NSClassFromString(featureSetName_) alloc] init];
    featureSet.service = self;
    [featureSet featureSetWillLoad];
    self.featureSetContainer[featureSetName_] = featureSet;
    [featureSet featureSetDidLoad];
    
    return featureSet;
}

- (void)unloadFeatureSetWithFeatureSetName:(NSString *)featureSetName_
{
    NSParameterAssert(featureSetName_);
    
    JJFeatureSet *featureSet = self.featureSetContainer[featureSetName_];
    [featureSet featureSetWillUnload];
    [self.featureSetContainer removeObjectForKey:featureSetName_];
    [featureSet featureSetDidUnload];
}

- (void)serviceResponseCallBack:(NSString *)requestType_
                      parameter:(id)parameter_
                        success:(BOOL)success_
                         object:(id)object_
                      otherInfo:(id)otherInfo_
         networkSuccessResponse:(void (^)(id object, id otherInfo))networkSuccessResponse_
            networkFailResponse:(void (^)(id error, id otherInfo))networkFailResponse_
{
    [self yzt_beginLockDelegateListOperation];
    
    NSMutableArray *delegateListCopy = [NSMutableArray array];
    for (id<JJServiceDelegate> delegate in self.delegateList)
    {
        [delegateListCopy addObject:delegate];
    }
    
    [self yzt_endLockDelegateListOperation];
    
    if (success_)
    {
        if (networkSuccessResponse_)
        {
            networkSuccessResponse_(object_, otherInfo_);
        }
        for (id<JJServiceDelegate> delegate in delegateListCopy)
        {
            if ([delegate respondsToSelector:@selector(networkSuccessResponse:requestType:parameter:object:otherInfo:)])
            {
                [delegate networkSuccessResponse:self
                                     requestType:requestType_
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
            if ([delegate respondsToSelector:@selector(networkFailResponse:requestType:parameter:error:otherInfo:)])
            {
                [delegate networkFailResponse:self
                                  requestType:requestType_
                                    parameter:parameter_
                                        error:object_
                                    otherInfo:otherInfo_];
            }
        }
    }
    
    [self postServiceResponseNotification:requestType_
                                parameter:parameter_
                                  success:success_
                                   object:object_
                                otherInfo:otherInfo_];
    
    [self recordRequestFinishCount:1];
}

- (void)postServiceResponseNotification:(NSString *)requestType_
                              parameter:(id)parameter_
                                success:(BOOL)success_
                                 object:(id)object_
                              otherInfo:(id)otherInfo_
{
    NSString *notificationName = [NSString stringWithFormat:@"%@_%@", NSStringFromClass([self class]), requestType_];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [JJNSMutableDictionaryHelper mDictionary:userInfo setObj:self forKey:JJServiceNotificationKeyService];
    [JJNSMutableDictionaryHelper mDictionary:userInfo setObj:parameter_ forKey:JJServiceNotificationKeyParameter];
    [JJNSMutableDictionaryHelper mDictionary:userInfo setObj:@(success_) forKey:JJServiceNotificationKeySuccess];
    [JJNSMutableDictionaryHelper mDictionary:userInfo setObj:object_ forKey:JJServiceNotificationKeyObject];
    [JJNSMutableDictionaryHelper mDictionary:userInfo setObj:otherInfo_ forKey:JJServiceNotificationKeyOtherInfo];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:notificationName
                      object:nil
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
    OSSpinLockLock(&_spinLock);
    
    self.requestFinishCount = self.requestFinishCount + count_;
    
    if (count_ > 0)
    {
        self.recordExistBeginDate = [NSDate date];
    }
    
    OSSpinLockUnlock(&_spinLock);
}

- (void)saveCustomModel:(id<NSCoding>)model
          operationType:(NSString *)operationType
             allAccount:(BOOL)allAccount
{
    JJCustomRequest *request = [self yzt_customRequestWithOperationType:operationType allAccount:allAccount];
    
    [request saveObjectToDiskCache:model];
}

- (void)removeCustomModelWithOperationType:(NSString *)operationType
                                allAccount:(BOOL)allAccount
{
    JJCustomRequest *request = [self yzt_customRequestWithOperationType:operationType allAccount:allAccount];
    
    [request removeDiskCache];
}

- (id)customModelWithOperationType:(NSString *)operationType
                        allAccount:(BOOL)allAccount
{
    JJCustomRequest *request = [self yzt_customRequestWithOperationType:operationType allAccount:allAccount];
    
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

- (void)yzt_beginLockDelegateListOperation
{
    OSSpinLockLock(&_delegateListOperationLock);
}

- (void)yzt_endLockDelegateListOperation
{
    OSSpinLockUnlock(&_delegateListOperationLock);
}

- (BOOL)yzt_isEmpty:(NSHashTable *)hashTable
{
    NSEnumerator *enumerator = [hashTable objectEnumerator];
    id value;
    
    while ((value = [enumerator nextObject]))
    {
        return NO;
    }
    
    return YES;
}

- (JJCustomRequest *)yzt_customRequestWithOperationType:(NSString *)operationType
                                              allAccount:(BOOL)allAccount
{
    JJCustomRequest *request = [[JJCustomRequest alloc] initWithOperationType:operationType parameters:nil modelClass:nil isSaveToMemory:NO isSaveToDisk:YES];
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
