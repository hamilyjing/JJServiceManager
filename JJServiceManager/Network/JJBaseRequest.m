
//
//  JJBaseRequest.m
//  
//
//  Created by JJ on 12/12/15.
//  Copyright © 2015 JJ. All rights reserved.
//

#import "JJBaseRequest.h"
#import <YYModel/YYModel.h>
#import "JJNSStringHelper.h"
#import "JJNSMutableDictionaryHelper.h"
#import "JJEncryptUtil.h"

static long g_networkRequestIndex = 1;

@interface JJBaseRequest ()

@property (nonatomic, strong) id jjCacheModel;

@property (nonatomic, strong) id oldModel;

@end

@implementation JJBaseRequest

#pragma mark - life cycle

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.requestIndex = g_networkRequestIndex;
        ++g_networkRequestIndex;
    }
    
    return self;
}

#pragma mark - overwrite

- (BOOL)ignoreCache
{
    return YES;
}

- (YTKRequestMethod)requestMethod
{
    return self.requestMethodType;
}

- (void)requestCompleteFilter
{
    if (!self.isSaveToMemory && !self.isSaveToDisk)
    {
        return;
    }
    
    id model = [self convertToModel:[self responseString]];
    
    self.oldModel = [self cacheModel];
    
    NSInteger updateCount;
    model = [self operateWithNewObject:model oldObject:self.oldModel updateCount:&updateCount];
    
    if (![self successForBussiness:model])
    {
        return;
    }
    
    if (self.isSaveToMemory)
    {
        self.jjCacheModel = model;
    }
    
    if (self.isSaveToDisk)
    {
        [self saveObjectToDiskCache:model];
    }
}

#pragma mark - public

- (id)cacheModel
{
    id cacheModel = self.jjCacheModel;
    if (!self.isSaveToMemory)
    {
        self.jjCacheModel = nil;
    }
    
    return cacheModel;
}

- (id)currentResponseModel
{
    id model = [self convertToModel:[self filterResponseString:self.responseString]];
    NSInteger updateCount;
    model = [self operateWithNewObject:model oldObject:self.oldModel updateCount:&updateCount];
    
    return model;
}

- (void)saveObjectToMemory:(id)object_
{
    self.jjCacheModel = object_;
}

- (BOOL)saveObjectToDiskCache:(id)object_
{
    NSParameterAssert(object_);
    
    if (!object_)
    {
        return YES;
    }
    
    NSString *filePath = [self savedFilePath];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object_];
    if (data.length > 0) {
        data = [[JJEncryptUtil encryptUseDES:data key:[JJEncryptUtil getCacheDesKey]] dataUsingEncoding:NSUTF8StringEncoding];
    }
    BOOL success = [data writeToFile:filePath atomically:YES];
    return success;
}

- (BOOL)haveDiskCache
{
    NSString *filePath = [self savedFilePath];
    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    return fileExist;
}

- (void)removeMemoryCache
{
    self.jjCacheModel = nil;
}

- (void)removeDiskCache
{
    NSString *filePath = [self savedFilePath];
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
}

- (void)removeAllCache
{
    [self removeMemoryCache];
    [self removeDiskCache];
}

- (id)convertToModel:(NSString *)JSONString_
{
    return nil;
}

- (id)operateWithNewObject:(id)newObject_
                 oldObject:(id)oldObject_
               updateCount:(NSInteger *)updateCount_
{
    if (self.operation)
    {
        return self.operation(newObject_, oldObject_);
    }
    
    *updateCount_ = 1;
    return newObject_;
}

- (BOOL)successForBussiness:(id)model_
{
    return NO;
}

- (NSString *)savedFilePath
{
    NSString *directory = [self savedFileDirectory];
    NSString *fileName = [self savedFileName];
    NSString *filePath = [directory stringByAppendingPathComponent:fileName];
    return filePath;
}

- (NSString *)savedFileDirectory
{
    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    cachesDirectory = [cachesDirectory stringByAppendingPathComponent:@"JJBaseRequest"];
    
    if ([self.userCacheDirectory length] > 0)
    {
        cachesDirectory = [cachesDirectory stringByAppendingPathComponent:self.userCacheDirectory];
    }
    
    [self __checkDirectory:cachesDirectory];
    
    return cachesDirectory;
}

- (NSString *)savedFileName
{
    NSMutableString *cacheFileName;
    
    NSString *sensitiveData = self.sensitiveDataForSavedFileName;
    if ([sensitiveData length] <= 0)
    {
        sensitiveData = @"";
    }
    cacheFileName = [NSMutableString stringWithFormat:@"%@_", sensitiveData];
    
    NSString *identity = self.identity ? self.identity : @"";
    [cacheFileName appendString:identity];
    [cacheFileName appendString:@"_"];
    
    NSDictionary *parameters = self.parametersForSavedFileName ? self.parametersForSavedFileName : @{};
    NSString *cacheFileNameSuffix = [NSString stringWithFormat:@"Parameters:%@", parameters];
    cacheFileNameSuffix = [JJNSStringHelper md5String:cacheFileNameSuffix];
    
    if (cacheFileNameSuffix)
    {
        [cacheFileName appendString:cacheFileNameSuffix];
    }
    else
    {
        NSAssert(NO, @"Cannot convert String(Parameters:%@) to MD5", parameters);
    }
    
    return cacheFileName;
}

- (NSString *)filterResponseString:(NSString *)responseString
{
    return responseString;
}

#pragma mark - private

- (void)__checkDirectory:(NSString *)path_
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:path_ isDirectory:&isDir])
    {
        [self __createBaseDirectoryAtPath:path_];
    }
    else
    {
        if (!isDir)
        {
            NSError *error = nil;
            [fileManager removeItemAtPath:path_ error:&error];
            [self __createBaseDirectoryAtPath:path_];
        }
    }
}

- (void)__createBaseDirectoryAtPath:(NSString *)path_
{
    __autoreleasing NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path_
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
}

#pragma mark - getter and setter

- (id)jjCacheModel
{
    if (_jjCacheModel)
    {
        return _jjCacheModel;
    }
    
    NSString *filePath = [self savedFilePath];
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath];
    NSString *s = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    if (data.length > 0)
    {
        data = [JJEncryptUtil decryptUseDES:s key:[JJEncryptUtil getCacheDesKey]];
        @try{
            _jjCacheModel = data.length > 0 ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
        }@catch (NSException * e) {
            _jjCacheModel = nil;
        }
    }
    
    return _jjCacheModel;
}

@end
