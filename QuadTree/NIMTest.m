//
//  NIMTest.m
//  QuadTree
//
//  Created by Jonathan Wight on 3/10/14.
//  Copyright (c) 2014 schwa. All rights reserved.
//

#import "NIMTest.h"

#import "NIMQuadTree.h"
#import "NIMQuadTreeOBJC.h"
#import "NIMTuple.h"
#import "Timing.h"

#define MyLog(...)

@interface NIMTest ()
@end

@implementation NIMTest

- (id)init
    {
    if ((self = [super init]) != NULL)
        {
        _size = (CGSize){ 512, 512 };
        _numberOfItems = 10000;
        _insertionIterations = 100;
        _searchIterations = 100;
        _searchRatio = 0.5;
        _minimumNodeSize = (CGSize){ 2, 2 };
        _numberOfItemsPerNode = 8;
        }
    return self;
    }

- (NSDictionary *)test
    {
    NSMutableDictionary *theResult = [NSMutableDictionary dictionary];

    @autoreleasepool
        {
        CGRect theRange = (CGRect){ { 0, 0 }, { self.size.width * self.searchRatio, self.size.height * self.searchRatio } };

        theResult[@"input"] = @{
            @"size": [NSString stringWithFormat:@"%dx%d", (int)self.size.width, (int)self.size.height],
            @"numberOfItems": @(self.numberOfItems),
            @"searchRatio": @(self.searchRatio),
            @"minimumNodeSize": [NSString stringWithFormat:@"%dx%d", (int)self.minimumNodeSize.width, (int)self.minimumNodeSize.height],
            @"itemsPerNode": @(self.numberOfItemsPerNode),
            };

        NSArray *theClasses = @[ [NIMQuadTree class], [NIMQuadTreeOBJC class] ];

        NSMutableArray *thePoints = [NSMutableArray array];
        for (NSUInteger N = 0; N != self.numberOfItems; ++N)
            {
    //        CGPoint thePoint = (CGPoint){ rand() % 512, rand() % 512 };
            CGPoint thePoint = (CGPoint){ arc4random_uniform((u_int32_t)self.size.width), arc4random_uniform((u_int32_t)self.size.height) };
            [thePoints addObject:[NIMTuple tupleWithFirstObject:[NSValue valueWithPoint:thePoint] secondObject:@(N)]];
            }

        // Linear search... This is the baseline...
        __block NSUInteger theLinearCount = 0;
        CFTimeInterval theLinearSearchTime = Time(self.searchIterations, ^{
            NSMutableArray *theObjects = [NSMutableArray array];
            for (NIMTuple *theTuple in thePoints)
                {
                NSValue *thePointValue = theTuple[0];
                CGPoint thePoint = [thePointValue pointValue];
                if (CGRectContainsPoint(theRange, thePoint))
                    {
                    [theObjects addObject:theTuple[1]];
                    }
                }
            theLinearCount += [theObjects count];
            });
        MyLog(@"Linear search: %f", theLinearSearchTime);

        theResult[@"linear"] = @{ @"search": @(theLinearSearchTime) };

        for (Class theClass in theClasses)
            {
            MyLog(@"**** %@ ****", NSStringFromClass(theClass));

            __block NIMQuadTree *theQuadTree = NULL;

            CFTimeInterval theInsertionTime = Time(self.insertionIterations, ^{
                theQuadTree = [[theClass alloc] initWithFrame:(CGRect){ .size = self.size } minimumNodeSize:self.minimumNodeSize maximumObjectsPerNode:self.numberOfItemsPerNode];
                for (NIMTuple *theTuple in thePoints)
                    {
                    const CGPoint thePoint = [theTuple[0] pointValue];
                    id theObject = theTuple[1];
                    [theQuadTree addObject:theObject atPoint:thePoint];
                    }
                });
            MyLog(@"Insertion: %f", theInsertionTime);

            __block NSUInteger theCount = 0;
            CFTimeInterval theSearchTime = Time(self.searchIterations, ^{
                theCount += [[theQuadTree objectsInRect:theRange] count];
                });
            MyLog(@"Search: %f (%f)", theSearchTime, 1.0 / (theSearchTime / theLinearSearchTime));
            if (theCount != theLinearCount)
                {
                MyLog(@"OHOH: Linear search and quad tree search disagree");
                }

            theResult[NSStringFromClass(theClass)] = @{ @"insert": @(theInsertionTime), @"search": @(theSearchTime) };
            }
        }
    return(theResult);
    }

@end
