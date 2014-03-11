//
//  NIMTuple.m
//  Vectors
//
//  Created by Jonathan Wight on 3/9/14.
//  Copyright (c) 2014 schwa.io. All rights reserved.
//

#import "NIMTuple.h"

@implementation NIMTuple

+ (instancetype)tupleWithFirstObject:(id)inFirstObject secondObject:(id)inSecondObject
    {
    return([[self alloc] initWithFirstObject:inFirstObject secondObject:inSecondObject]);
    }


- (instancetype)initWithFirstObject:(id)inFirstObject secondObject:(id)inSecondObject
    {
    if ((self = [super init]) != NULL)
        {
        _firstObject = [inFirstObject copy];
        _secondObject = [inSecondObject copy];
        }
    return self;
    }

- (id)objectAtIndexedSubscript:(NSUInteger)idx;
    {
    if (idx == 0)
        {
        return _firstObject;
        }
    else if (idx == 1)
        {
        return _secondObject;
        }
    else
        {
//        [NSException exceptionWithName:<#(NSString *)#> reason:<#(NSString *)#> userInfo:<#(NSDictionary *)#>]
        return(NULL);
        }
    }


@end
