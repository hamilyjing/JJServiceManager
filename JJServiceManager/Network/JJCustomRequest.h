//
//  JJCustomRequest.h
//
//
//  Created by JJ on 5/18/16.
//  Copyright © 2016 JJ. All rights reserved.
//

#import "JJBaseRequest.h"

@interface JJCustomRequest : JJBaseRequest

- (instancetype)initWithIdentity:(NSString *)identity
                      parameters:(NSDictionary *)parameters
                      modelClass:(Class)modelClass
                  isSaveToMemory:(BOOL)isSaveToMemory
                    isSaveToDisk:(BOOL)isSaveToDisk;

@end
