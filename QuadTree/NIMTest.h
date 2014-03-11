//
//  NIMTest.h
//  QuadTree
//
//  Created by Jonathan Wight on 3/10/14.
//  Copyright (c) 2014 schwa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NIMTest : NSObject

@property (readwrite, nonatomic) CGSize size;
@property (readwrite, nonatomic) NSUInteger numberOfItems;
@property (readwrite, nonatomic) NSUInteger insertionIterations;
@property (readwrite, nonatomic) NSUInteger searchIterations;
@property (readwrite, nonatomic) CGFloat searchRatio;
@property (readwrite, nonatomic) CGSize minimumNodeSize;
@property (readwrite, nonatomic) NSUInteger numberOfItemsPerNode;

- (NSDictionary *)test;

@end
