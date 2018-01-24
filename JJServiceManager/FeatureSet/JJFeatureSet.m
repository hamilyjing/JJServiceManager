//
//  JJFeatureSet.m
//
//
//  Created by JJ on 12/2/15.
//  Copyright © 2015 JJ. All rights reserved.
//

#import "JJFeatureSet.h"

#import "JJService.h"
#import "JJServiceFactory.h"
#import "JJBaseRequest.h"
#import "JJNSMutableDictionaryHelper.h"
#import "JJServiceNotification.h"

@interface JJFeatureSet ()

@property (nonatomic, copy) NSString *serviceName;

@end

@implementation JJFeatureSet

@synthesize service = _service;

#pragma mark - life cycle

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - public

+ (NSString *)featureSetName
{
    return NSStringFromClass(self.class);
}

- (void)featureSetWillLoad
{
}

- (void)featureSetDidLoad
{
}

- (void)featureSetWillUnload
{
}

- (void)featureSetDidUnload
{
}

- (void)startRequest:(JJBaseRequest *)request_
            identity:(NSString *)identity_
           parameter:(id)parameter_
           otherInfo:(NSDictionary *)otherInfo_
       successAction:(void (^)(id object, JJBaseRequest *request))successAction_
          failAction:(void (^)(NSError *error, JJBaseRequest *request))failAction_
{
    [self.service recordRequestFinishCount:-1];
    
    [request_ startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request)
     {
         id object = [request_ currentResponseModel];
         
         if (successAction_)
         {
             successAction_(object, request_);
         }
         
         NSMutableDictionary *tempOtherInfo = [NSMutableDictionary dictionary];
         if (otherInfo_)
         {
             [tempOtherInfo addEntriesFromDictionary:otherInfo_];
         }
         NSString *responseString = [request_ filterResponseString:request.responseString];
         [JJNSMutableDictionaryHelper mDictionary:tempOtherInfo setObj:responseString forKey:JJServiceNotificationKeyOtherInfoResponseStringKey];
         
         [self.service serviceResponseCallBack:identity_
                                     parameter:parameter_
                                       success:YES
                                        object:object
                                     otherInfo:tempOtherInfo
                        networkSuccessResponse:request_.networkSuccessResponse
                           networkFailResponse:request_.networkFailResponse];
         
     }failure:^(YTKBaseRequest *request)
     {
         id object = request_.error;
         
         if (failAction_)
         {
             failAction_(object, request_);
         }
         
         [self.service serviceResponseCallBack:identity_
                                     parameter:parameter_
                                       success:NO
                                        object:object
                                     otherInfo:otherInfo_
                        networkSuccessResponse:request_.networkSuccessResponse
                           networkFailResponse:request_.networkFailResponse];
     }];
}

- (void)startRequest:(JJBaseRequest *)request_
            identity:(NSString *)identity_
           parameter:(id)parameter_
           otherInfo:(NSDictionary *)otherInfo_
{
    [self startRequest:request_
              identity:identity_
             parameter:parameter_
             otherInfo:otherInfo_
         successAction:nil
            failAction:nil];
}

- (void)startRequest:(JJBaseRequest *)request_
           otherInfo:(NSDictionary *)otherInfo_
       successAction:(void (^)(id object, JJBaseRequest *request))successAction_
          failAction:(void (^)(NSError *error, JJBaseRequest *request))failAction_
{
    [self startRequest:request_
              identity:request_.identity
             parameter:request_.parametersForSavedFileName
             otherInfo:otherInfo_
         successAction:(void (^)(id object, JJBaseRequest *request))successAction_
            failAction:(void (^)(NSError *error, JJBaseRequest *request))failAction_];
}

- (void)startRequest:(JJBaseRequest *)request_
           otherInfo:(NSDictionary *)otherInfo_
{
    [self startRequest:request_
             otherInfo:otherInfo_
         successAction:nil
            failAction:nil];
}

- (void)actionAfterLogin
{
}

- (void)actionAfterLogout
{
}

- (id)cacheModelWithParameters:(NSDictionary *)parameters_
                  requestClass:(Class)requestClass_
                      identity:(NSString *)identity_
                    modelClass:(Class)modelClass_
                  isSaveToDisk:(BOOL)isSaveToDisk_
{
    JJBaseRequest *request = [self jj_requestWithParameters:parameters_ requestClass:requestClass_ identity:identity_ modelClass:modelClass_ isSaveToDisk:isSaveToDisk_];
    id model = [request cacheModel];
    return model;
}

- (void)removeCacheModelWithParameters:(NSDictionary *)parameters
                          requestClass:(Class)requestClass
                              identity:(NSString *)identity
                            modelClass:(Class)modelClass
                          isSaveToDisk:(BOOL)isSaveToDisk
{
    JJBaseRequest *request = [self jj_requestWithParameters:parameters requestClass:requestClass identity:identity modelClass:modelClass isSaveToDisk:isSaveToDisk];
    [request removeAllCache];
}

- (JJBaseRequest *)requestWithParameters:(NSDictionary *)parameters_
                            requestClass:(Class)requestClass_
                                identity:(NSString *)identity_
                              modelClass:(Class)modelClass_
                            isSaveToDisk:(BOOL)isSaveToDisk_
                  networkSuccessResponse:(void(^)(id object, id otherinfo))networkSuccessResponse_
                     networkFailResponse:(void (^)(NSError *error, id otherinfo))networkFailResponse_
{
    JJBaseRequest *request = [self jj_requestWithParameters:parameters_ requestClass:requestClass_ identity:identity_ modelClass:modelClass_ isSaveToDisk:isSaveToDisk_];
    request.networkSuccessResponse = networkSuccessResponse_;
    request.networkFailResponse = networkFailResponse_;
    
    [self startRequest:request otherInfo:nil];
    
    return request;
}

#pragma mark - private

- (JJBaseRequest *)jj_requestWithParameters:(NSDictionary *)parameters_
                               requestClass:(Class)requestClass_
                                   identity:(NSString *)identity_
                                 modelClass:(Class)modelClass_
                               isSaveToDisk:(BOOL)isSaveToDisk_
{
    JJBaseRequest *request = [[requestClass_ alloc] init];
    request.identity = identity_;
    request.parametersForSavedFileName = parameters_;
    request.modelClass = modelClass_;
    request.isSaveToDisk = isSaveToDisk_;
    return request;
}

#pragma mark - getter & setter

- (JJService *)service
{
    if (_service)
    {
        return _service;
    }
    
    if (!self.serviceName)
    {
        return nil;
    }
    
    _service = [[JJServiceFactory sharedServiceFactory] serviceWithServiceName:self.serviceName];
    return _service;
}

- (void)setService:(JJService *)service
{
    _service = service;
    self.serviceName = NSStringFromClass(_service.class);
}

@end

