//
//  JJCustomRequest.m
//  
//
//  Created by JJ on 5/18/16.
//  Copyright © 2016 JJ. All rights reserved.
//

#import "JJCustomRequest.h"

@implementation JJCustomRequest

#pragma mark - life cycle

- (instancetype)initWithOperationType:(NSString *)operationType
                           parameters:(NSDictionary *)parameters
                           modelClass:(Class)modelClass
                       isSaveToMemory:(BOOL)isSaveToMemory
                         isSaveToDisk:(BOOL)isSaveToDisk
{
    self = [super initWithOperationType:operationType parameters:parameters modelClass:modelClass isSaveToMemory:isSaveToMemory isSaveToDisk:isSaveToDisk];
    
    return self;
}

@end
