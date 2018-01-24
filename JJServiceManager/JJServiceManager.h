#import <Foundation/Foundation.h>

#if __has_include(<JJServiceManager/JJServiceManager.h>)

//! Project version number for JJServiceManager.
FOUNDATION_EXPORT double JJServiceManagerVersionNumber;

//! Project version string for JJServiceManager.
FOUNDATION_EXPORT const unsigned char JJServiceManagerVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <JJServiceManager/PublicHeader.h>
#import <JJServiceManager/JJServiceNotification.h>
#import <JJServiceManager/JJBaseRequest.h>
#import <JJServiceManager/JJCustomRequest.h>
#import <JJServiceManager/JJBaseModel.h>
#import <JJServiceManager/JJServiceFactory.h>
#import <JJServiceManager/JJFeatureSet.h>
#import <JJServiceManager/JJServiceBatchRequest.h>
#import <JJServiceManager/JJService.h>
#import <JJServiceManager/JJServiceChainRequest.h>
#import <JJServiceManager/JJBase64.h>
#import <JJServiceManager/JJNSMutableDictionaryHelper.h>
#import <JJServiceManager/JJNSStringHelper.h>
#import <JJServiceManager/JJEncryptUtil.h>

#else

#import "JJServiceNotification.h"
#import "JJBaseRequest.h"
#import "JJCustomRequest.h"
#import "JJBaseModel.h"
#import "JJServiceFactory.h"
#import "JJFeatureSet.h"
#import "JJServiceBatchRequest.h"
#import "JJService.h"
#import "JJServiceChainRequest.h"
#import "JJBase64.h"
#import "JJNSMutableDictionaryHelper.h"
#import "JJNSStringHelper.h"
#import "JJEncryptUtil.h"

#endif
