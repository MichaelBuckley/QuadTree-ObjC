//
//  NIMTuple.h
//  Vectors
//
//  Created by Jonathan Wight on 3/9/14.
//  Copyright (c) 2014 schwa.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NIMTuple : NSObject

@property (readonly, nonatomic, copy) id firstObject;
@property (readonly, nonatomic, copy) id secondObject;

+ (instancetype)tupleWithFirstObject:(id)inFirstObject secondObject:(id)inSecondObject;
- (instancetype)initWithFirstObject:(id)inFirstObject secondObject:(id)inSecondObject;

//- (NSArray *)objectsAtIndexes:(NSIndexSet *)indexes;
- (id)objectAtIndexedSubscript:(NSUInteger)idx;


@end
