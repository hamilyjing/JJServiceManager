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

- (instancetype)initWithIdentity:(NSString *)identity
                      parameters:(NSDictionary *)parameters
                      modelClass:(Class)modelClass
                  isSaveToMemory:(BOOL)isSaveToMemory
                    isSaveToDisk:(BOOL)isSaveToDisk;
{
    self = [super init];
    if (self)
    {
        self.identity = identity;
        self.parametersForSavedFileName = parameters;
        self.modelClass = modelClass;
        self.isSaveToMemory = isSaveToMemory;
        self.isSaveToDisk = isSaveToDisk;
    }
    
    return self;
}

@end
