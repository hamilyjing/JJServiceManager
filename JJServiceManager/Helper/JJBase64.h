//
//  Base64.h
//  PANewToapAPP
//
//  Created by BillyWang on 15/3/17.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JJBase64 : NSObject

+ (NSString *)encode:(NSData *)data;
+ (NSData *)decode:(NSString *)data;

@end
