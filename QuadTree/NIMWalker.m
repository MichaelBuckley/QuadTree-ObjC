//
//  NIMWalker.m
//  Vectors
//
//  Created by Jonathan Wight on 3/9/14.
//  Copyright (c) 2014 schwa.io. All rights reserved.
//

#import "NIMWalker.h"

@implementation NIMWalker

- (void)walk:(id)object visit:(VisitBlock)visitBlock
    {
    if (self.childrenKey)
        {
        Walk(NULL, object, 0, self.childrenKey, visitBlock);
        }
    else if (self.childCountBlock && self.childAtIndexBlock)
        {
        Walk2(NULL, object, 0, self.childCountBlock, self.childAtIndexBlock, visitBlock);
        }
    else
        {
        NSAssert(NO, @"NIMWalker not set up correctly.");
        }
    }

void Walk(id parent, id object, NSUInteger depth, NSString *childKey, VisitBlock visitBlock)
    {
    BOOL theStopFlag = NO;
    visitBlock(parent, object, depth, &theStopFlag);
    if (theStopFlag == YES)
        {
        return;
        }

    NSArray *theChildren = [object valueForKey:childKey];
    for (id theChild in theChildren)
        {
        Walk(object, theChild, depth + 1, childKey, visitBlock);
        }
    }

void Walk2(id parent, id object, NSUInteger depth, NSUInteger (^countBlock)(id object), id (^childBlock)(id object, NSUInteger idx), VisitBlock visitBlock)
    {
    BOOL theStopFlag = NO;
    visitBlock(parent, object, depth, &theStopFlag);
    if (theStopFlag == YES)
        {
        return;
        }

    const NSUInteger theChildCount = countBlock(object);
    for (NSUInteger N = 0; N != theChildCount; ++N)
        {
        id theChild = childBlock(object, N);
        if (theChild)
            {
            Walk2(object, theChild, depth + 1, countBlock, childBlock, visitBlock);
            }
        }
    }

void Walk3(id parent, id object, NSUInteger depth, NSArray * (^childrenBlock)(id object), VisitBlock visitBlock)
    {
    BOOL theStopFlag = NO;
    visitBlock(parent, object, depth, &theStopFlag);
    if (theStopFlag == YES)
        {
        return;
        }

    NSArray *theChildren = childrenBlock(object);
    for (id theChild in theChildren)
        {
        Walk(object, theChild, depth + 1, childrenBlock, visitBlock);
        }
    }


@end
