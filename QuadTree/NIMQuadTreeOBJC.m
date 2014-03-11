//
//  NIMQuadTree.m
//  Vectors
//
//  Created by Jonathan Wight on 3/6/14.
//  Copyright (c) 2014 schwa.io. All rights reserved.
//

#import "NIMQuadTreeOBJC.h"

#import "QuartzExtensions.h"
#import "NIMTuple.h"
#import "NIMWalker.h"

@interface NIMQuadTreeNode : NSObject
@property (readonly, nonatomic, assign) NIMQuadTreeOBJC *quadTree;
@property (readonly, nonatomic) CGRect frame;
@property (readwrite, nonatomic) NIMQuadTreeNode *topLeft;
@property (readwrite, nonatomic) NIMQuadTreeNode *topRight;
@property (readwrite, nonatomic) NIMQuadTreeNode *bottomLeft;
@property (readwrite, nonatomic) NIMQuadTreeNode *bottomRight;
@property (readwrite, nonatomic) NSMutableSet *objects;
@property (readonly, nonatomic) NIMQuadTreeNode *rootNode;
- (id)initWithQuadTree:(NIMQuadTreeOBJC *)inQuadTree frame:(CGRect)inFrame;
//- (void)addObject:(id)inObject atRect:(CGRect)inRect;
- (void)addObject:(id)inObject atPoint:(CGPoint)inPoint;
- (NSArray *)objectsInRect:(CGRect)inRect;
@end

#pragma mark -

@interface NIMQuadTreeOBJC ()
@property (readonly, nonatomic) NIMQuadTreeNode *rootNode;
@end

#pragma mark -

@implementation NIMQuadTreeOBJC

- (id)initWithFrame:(CGRect)inFrame minimumNodeSize:(CGSize)inMinimumNodeSize maximumObjectsPerNode:(NSUInteger)inMaximumObjectsPerNode
    {
    if ((self = [super init]) != NULL)
        {
        _frame = inFrame;
        _minimumNodeSize = inMinimumNodeSize;
        _maximumObjectsPerNode = inMaximumObjectsPerNode;
        _rootNode = [[NIMQuadTreeNode alloc] initWithQuadTree:self frame:self.frame];
        }
    return self;
    }

//- (void)addObject:(id)inObject atRect:(CGRect)inRect
//    {
//    [self.rootNode addObject:inObject atRect:inRect];
//    }

- (void)addObject:(id)inObject atPoint:(CGPoint)inPoint
    {
    [self.rootNode addObject:inObject atPoint:inPoint];
    }

- (NSArray *)objectsInRect:(CGRect)inRect;
    {
    return([self.rootNode objectsInRect:inRect]);
    }

- (void)renderInContext:(CGContextRef)inContext;
    {
    NIMWalker *theWalker = [[NIMWalker alloc] init];
    theWalker.childrenKey = @"childNodes";

    [theWalker walk:self.rootNode visit:^(id parent, NIMQuadTreeNode *node, NSUInteger depth, BOOL *stop) {
        [[NSColor colorWithDeviceHue:0.0 saturation:((double)node.objects.count / 10.0) brightness:1.0 alpha:1.0] set];
        CGContextFillRect(inContext, node.frame);

        [[NSColor blackColor] set];
        CGContextStrokeRect(inContext, node.frame);
        }];
    }

- (void)dump
    {
    NIMWalker *theWalker = [[NIMWalker alloc] init];
    theWalker.childrenKey = @"childNodes";

    [theWalker walk:self.rootNode visit:^(id parent, NIMQuadTreeNode *node, NSUInteger depth, BOOL *stop) {
        NSString *theSpacing = [@"" stringByPaddingToLength:depth withString:@"\t" startingAtIndex:0];
        NSString *theString = [NSString stringWithFormat:@"%@%@", theSpacing, [node description]];
        printf("%s\n", [theString UTF8String]);
        }];
    }

@end

#pragma mark -

@implementation NIMQuadTreeNode

- (id)initWithQuadTree:(NIMQuadTreeOBJC *)inQuadTree frame:(CGRect)inFrame;
    {
    if ((self = [super init]) != NULL)
        {
        _quadTree = inQuadTree;
        _frame = inFrame;
        _objects = [NSMutableSet set];
        }
    return self;
    }

- (NSString *)description
    {
    return([NSString stringWithFormat:@"%@ %@ %lu", [super description], NSStringFromRect(self.frame), (unsigned long)self.objects.count]);
    }

//- (void)addObject:(id)inObject atRect:(CGRect)inRect
//    {
//    }

- (NSArray *)childNodes
    {
    NSMutableArray *theNodes = [NSMutableArray array];
    if (_topLeft != NULL)
        {
        [theNodes addObject:_topLeft];
        }
    if (_topRight != NULL)
        {
        [theNodes addObject:_topRight];
        }
    if (_bottomLeft != NULL)
        {
        [theNodes addObject:_bottomLeft];
        }
    if (_bottomRight != NULL)
        {
        [theNodes addObject:_bottomRight];
        }
    return(theNodes);
    }

- (void)addObject:(id)inObject atPoint:(CGPoint)inPoint
    {
    if (_objects.count >= (NSUInteger)_quadTree.maximumObjectsPerNode)
        {
        if (_frame.size.width > _quadTree.minimumNodeSize.width && _frame.size.height > _quadTree.minimumNodeSize.height)
            {
            [self _expand];
            }
        }

    if (_objects == NULL)
        {
        [[self _subnodeForPoint:inPoint] addObject:inObject atPoint:inPoint];
        }
    else
        {
        [_objects addObject:[NIMTuple tupleWithFirstObject:[NSValue valueWithPoint:inPoint] secondObject:inObject]];
        }
    }

- (NSArray *)objectsInRect:(CGRect)inRect
    {
    NSMutableArray *theObjects = [NSMutableArray array];
    [self _addObjectsInRect:inRect toMutableArray:theObjects];
    return(theObjects);
    }

- (void)_addObjectsInRect:(CGRect)inRect toMutableArray:(NSMutableArray *)inObjects
    {
    for (NIMTuple *theTuple in _objects)
        {
        CGPoint thePoint = [theTuple[0] pointValue];
        if (CGRectContainsPoint(inRect, thePoint))
            {
            [inObjects addObject:theTuple[1]];
            }
        }

    if (_topLeft && CGRectIntersectsRect(inRect, _topLeft.frame))
        {
        [_topLeft _addObjectsInRect:inRect toMutableArray:inObjects];
        }
    if (_topRight && CGRectIntersectsRect(inRect, _topRight.frame))
        {
        [_topRight _addObjectsInRect:inRect toMutableArray:inObjects];
        }
    if (_bottomLeft && CGRectIntersectsRect(inRect, _bottomLeft.frame))
        {
        [_bottomLeft _addObjectsInRect:inRect toMutableArray:inObjects];
        }
    if (_bottomRight && CGRectIntersectsRect(inRect, _bottomRight.frame))
        {
        [_bottomRight _addObjectsInRect:inRect toMutableArray:inObjects];
        }
    }

- (void)_expand
    {
    for (NIMTuple *theTuple in _objects)
        {
        CGPoint thePoint = [theTuple[0] pointValue];
        id theObject = theTuple[1];
        NIMQuadTreeNode *theNode = [self _subnodeForPoint:thePoint];
        [theNode addObject:theObject atPoint:thePoint];
        }

    _objects = NULL;
    }

- (NIMQuadTreeNode *)_subnodeForPoint:(CGPoint)inPoint
    {
    const CGXQuadrant theQuadrant = CGXQuadrantForPointInRect(inPoint, _frame);
    NIMQuadTreeNode *theSubnode = NULL;

    switch (theQuadrant)
        {
        case kCGXQuadrant_TopLeft:
            theSubnode = _topLeft;
            if (theSubnode == NULL)
                {
                theSubnode = _topLeft = [[NIMQuadTreeNode alloc] initWithQuadTree:_quadTree frame:CGRectQuadrant(_frame, kCGXQuadrant_TopLeft)];
                }
            break;
        case kCGXQuadrant_TopRight:
            theSubnode = _topRight;
            if (theSubnode == NULL)
                {
                theSubnode = _topRight = [[NIMQuadTreeNode alloc] initWithQuadTree:_quadTree frame:CGRectQuadrant(_frame, kCGXQuadrant_TopRight)];
                }
            break;
        case kCGXQuadrant_BottomLeft:
            theSubnode = _bottomLeft;
            if (theSubnode == NULL)
                {
                theSubnode = _bottomLeft = [[NIMQuadTreeNode alloc] initWithQuadTree:_quadTree frame:CGRectQuadrant(_frame, kCGXQuadrant_BottomLeft)];
                }
            break;
        case kCGXQuadrant_BottomRight:
            theSubnode = _bottomRight;
            if (theSubnode == NULL)
                {
                theSubnode = _bottomRight = [[NIMQuadTreeNode alloc] initWithQuadTree:_quadTree frame:CGRectQuadrant(_frame, kCGXQuadrant_BottomRight)];
                }
            break;
        default:
            break;
        }
    return theSubnode;
    }

@end
