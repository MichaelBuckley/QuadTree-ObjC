//
//  NIMQuadTree.h
//  Vectors
//
//  Created by Jonathan Wight on 3/6/14.
//  Copyright (c) 2014 schwa.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NIMQuadTree : NSObject

@property (readonly, nonatomic) CGRect frame;
@property (readonly, nonatomic) CGSize minimumNodeSize;
@property (readonly, nonatomic) NSUInteger maximumObjectsPerNode;

- (id)initWithFrame:(CGRect)inFrame minimumNodeSize:(CGSize)inMinimumNodeSize maximumObjectsPerNode:(NSUInteger)inMaximumObjectsPerNode;

- (void)addObject:(id)inObject atPoint:(CGPoint)inPoint;

- (NSArray *)objectsInRect:(CGRect)inRect;

- (void)renderInContext:(CGContextRef)inContext;
- (void)dump;

@end
