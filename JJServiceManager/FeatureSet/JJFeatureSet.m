//
//  JJFeatureSet.m
//  
//
//  Created by JJ on 12/2/15.
//  Copyright © 2015 JJ. All rights reserved.
//

#import "JJFeatureSet.h"

#import <JJ_iOS_HttpTransportService/JJ_iOS_HttpTransportService.h>
#import "JJService.h"
#import "JJServiceFactory.h"

extern NSString *JJServiceNotificationKeyOtherInfoResponseStringKey;
extern NSString *JJServiceNotificationKeyOtherInfo;

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
         requestType:(NSString *)requestType_
           parameter:(id)parameter_
           otherInfo:(id)otherInfo_
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
         
         id tempOtherInfo = otherInfo_;
         
         NSMutableDictionary *responseOtherInfo = [NSMutableDictionary dictionary];
         if (!otherInfo_ || [otherInfo_ isKindOfClass:[NSDictionary class]])
         {
             if (otherInfo_)
             {
                 [responseOtherInfo addEntriesFromDictionary:otherInfo_];
             }
             
             NSString *responseString = request.responseString;
             if ([request isKindOfClass:[JJGPRequest class]])
             {
                 responseString = [(JJGPRequest *)request filterResponseString:request.responseString];
             }
             [JJNSMutableDictionaryHelper mDictionary:responseOtherInfo setObj:responseString forKey:JJServiceNotificationKeyOtherInfoResponseStringKey];
             
             tempOtherInfo = responseOtherInfo;
         }
         
         [self.service serviceResponseCallBack:requestType_
                                     parameter:parameter_
                                       success:YES
                                        object:object
                                     otherInfo:tempOtherInfo
                        networkSuccessResponse:request_.networkSuccessResponse
                           networkFailResponse:request_.networkFailResponse];
         
     }failure:^(YTKBaseRequest *request)
     {
         id object = request_.error; //request_.requestOperationError
         
         if (failAction_)
         {
             failAction_(object, request_);
         }
         
         [self.service serviceResponseCallBack:requestType_
                                     parameter:parameter_
                                       success:NO
                                        object:object
                                     otherInfo:otherInfo_
                        networkSuccessResponse:request_.networkSuccessResponse
                           networkFailResponse:request_.networkFailResponse];
     }];
}

- (void)startRequest:(JJBaseRequest *)request_
         requestType:(NSString *)requestType_
           parameter:(id)parameter_
           otherInfo:(id)otherInfo_
{
    [self startRequest:request_
           requestType:requestType_
             parameter:parameter_
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

#pragma mark -- GP

- (void)startGPRequest:(JJGPRequest *)request_
             otherInfo:(id)otherInfo_
         successAction:(void (^)(id object, JJGPRequest *request))successAction_
            failAction:(void (^)(NSError *error, JJGPRequest *request))failAction_
{
    [self startRequest:request_
           requestType:request_.operationType
             parameter:request_.parameters
             otherInfo:otherInfo_
         successAction:(void (^)(id object, JJBaseRequest *request))successAction_
            failAction:(void (^)(NSError *error, JJBaseRequest *request))failAction_];
}

- (void)startGPRequest:(JJGPRequest *)request_
             otherInfo:(id)otherInfo_
{
    [self startGPRequest:request_
               otherInfo:otherInfo_
           successAction:nil
              failAction:nil];
}

- (id)cacheModelWithParameters:(NSDictionary *)parameters_
                  requestClass:(Class)requestClass_
                   requestType:(NSString *)requestType_
                    modelClass:(Class)modelClass_
                  isSaveToDisk:(BOOL)isSaveToDisk_
{
    JJGPRequest *request = [self yzt_requestWithParameters:parameters_ requestClass:requestClass_ requestType:requestType_ modelClass:modelClass_ isSaveToDisk:isSaveToDisk_];
    id model = [request cacheModel];
    return model;
}

- (void)removeCacheModelWithParameters:(NSDictionary *)parameters
                          requestClass:(Class)requestClass
                           requestType:(NSString *)requestType
                            modelClass:(Class)modelClass
                          isSaveToDisk:(BOOL)isSaveToDisk
{
    JJGPRequest *request = [self yzt_requestWithParameters:parameters requestClass:requestClass requestType:requestType modelClass:modelClass isSaveToDisk:isSaveToDisk];
    [request removeAllCache];
}

- (JJGPRequest *)requestWithParameters:(NSDictionary *)parameters_
                           requestClass:(Class)requestClass_
                            requestType:(NSString *)requestType_
                             modelClass:(Class)modelClass_
                           isSaveToDisk:(BOOL)isSaveToDisk_
                 networkSuccessResponse:(void(^)(id object, id otherinfo))networkSuccessResponse_
                    networkFailResponse:(void (^)(NSError *error, id otherinfo))networkFailResponse_
{
    JJGPRequest *request = [self yzt_requestWithParameters:parameters_ requestClass:requestClass_ requestType:requestType_ modelClass:modelClass_ isSaveToDisk:isSaveToDisk_];
    request.networkSuccessResponse = networkSuccessResponse_;
    request.networkFailResponse = networkFailResponse_;
    
    [self startGPRequest:request otherInfo:nil];
    
    return request;
}

- (JJGPRequest *)requestWithParameters:(NSDictionary *)parameters_
                 requestClass:(Class)requestClass_
                  requestType:(NSString *)requestType_
                   modelClass:(Class)modelClass_
                 isSaveToDisk:(BOOL)isSaveToDisk_
             isEncryptRequest:(BOOL)isEncryptRequest_
       networkSuccessResponse:(void(^)(id object, id otherinfo))networkSuccessResponse_
          networkFailResponse:(void (^)(NSError *error, id otherinfo))networkFailResponse_
{
    JJGPRequest *request = [self yzt_requestWithParameters:parameters_ requestClass:requestClass_ requestType:requestType_ modelClass:modelClass_ isSaveToDisk:isSaveToDisk_ isEncryptRequest:isEncryptRequest_];
    request.networkSuccessResponse = networkSuccessResponse_;
    request.networkFailResponse = networkFailResponse_;
    
    [self startGPRequest:request otherInfo:nil];
    
    return request;
}

#pragma mark - private

- (JJGPRequest *)yzt_requestWithParameters:(NSDictionary *)parameters_
                               requestClass:(Class)requestClass_
                                requestType:(NSString *)requestType_
                                 modelClass:(Class)modelClass_
                               isSaveToDisk:(BOOL)isSaveToDisk_
{
    JJGPRequest *request = [[requestClass_ alloc] initWithOperationType:requestType_ parameters:parameters_ modelClass:modelClass_ isSaveToMemory:NO isSaveToDisk:isSaveToDisk_];
    return request;
}

- (JJGPRequest *)yzt_requestWithParameters:(NSDictionary *)parameters_
                               requestClass:(Class)requestClass_
                                requestType:(NSString *)requestType_
                                 modelClass:(Class)modelClass_
                               isSaveToDisk:(BOOL)isSaveToDisk_
                           isEncryptRequest:(BOOL)isEncryptRequest_
{
    JJGPRequest *request = [[requestClass_ alloc] initWithOperationType:requestType_ parameters:parameters_ modelClass:modelClass_ isSaveToMemory:NO isSaveToDisk:isSaveToDisk_ isEncryptRequest:isEncryptRequest_];
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
