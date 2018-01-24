//
//  JJBaseModel.m
//  JJServiceManager
//
//  Created by 宫健(金融壹账通客户端研发团队) on 24/01/2018.
//  Copyright © 2018 宫健(金融壹账通客户端研发团队). All rights reserved.
//

#import "JJBaseModel.h"

#import <YYModel/YYModel.h>

@implementation JJBaseModel

#pragma mark - life cycle

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [self yy_modelEncodeWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    return [self yy_modelInitWithCoder:aDecoder];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self yy_modelCopy];
}

@end
