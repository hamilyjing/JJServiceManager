//
//  JJNSStringHelper.h
//
//
//  Created by JJ on 2/25/16.
//  Copyright © 2016 . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JJNSStringHelper : NSObject

+ (NSDictionary *)dictionaryWithJSON:(NSString *)string;

+ (NSString *)md5String:(NSString *)string;

@end
