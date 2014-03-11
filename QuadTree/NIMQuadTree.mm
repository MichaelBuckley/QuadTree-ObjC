//
//  NIMQuadTree.m
//  Vectors
//
//  Created by Jonathan Wight on 3/6/14.
//  Copyright (c) 2014 schwa.io. All rights reserved.
//

#import "NIMQuadTree.h"

#include <tuple>
#include <vector>
#include <list>
#include <memory>

#import "QuartzExtensions.h"
#include "COBJCObjectContainer.h"

typedef std::tuple <CGPoint, COBJCObjectContainer> MyTuple;
typedef std::list <MyTuple> ObjectContainer;

class CQuadTreeNode {
    public:
        CQuadTreeNode(NIMQuadTree *tree, const CGRect &frame);
        ~CQuadTreeNode();

        void AddObject(id object, const CGPoint &point);
        NSArray *ObjectsInRect(const CGRect &rect) const;

        void Walk(NSUInteger depth, void (^visitBlock)(NSUInteger depth, const CQuadTreeNode &node)) const;

        void AddObjectsInRect(NSMutableArray *array, const CGRect &rect) const;
        CQuadTreeNode *SubnodeForPoint(const CGPoint &point);

        NIMQuadTree *_tree;
        CGRect _frame;
        ObjectContainer *_objects;
        std::vector <std::shared_ptr <CQuadTreeNode> > _subnodes; // One node for each of the four quadrants.
    };

#pragma mark -

@interface NIMQuadTree ()
@property (readonly, nonatomic, assign) CQuadTreeNode *rootNode;
@end

#pragma mark -

@implementation NIMQuadTree

- (id)initWithFrame:(CGRect)inFrame minimumNodeSize:(CGSize)inMinimumNodeSize maximumObjectsPerNode:(NSUInteger)inMaximumObjectsPerNode
    {
    if ((self = [super init]) != NULL)
        {
        _frame = inFrame;
        _minimumNodeSize = inMinimumNodeSize;
        _maximumObjectsPerNode = inMaximumObjectsPerNode;
        _rootNode = new CQuadTreeNode(self, _frame);
        }
    return self;
    }

- (void)dealloc
    {
    if (_rootNode != NULL)
        {
        delete _rootNode;
        _rootNode = NULL;
        }
    }

- (void)addObject:(id)inObject atPoint:(CGPoint)inPoint
    {
    self.rootNode->AddObject(inObject, inPoint);
    }

- (void)removeObject:(id)inObject atPoint:(CGPoint)inPoint
    {
    // TODO
//    self.rootNode->RemoveObject(inObject, inPoint);
    }

- (NSArray *)objectsInRect:(CGRect)inRect
    {
    return self.rootNode->ObjectsInRect(inRect);
    }

- (void)renderInContext:(CGContextRef)context
    {
    self.rootNode->Walk(0, ^(NSUInteger depth, const CQuadTreeNode &inNode) {
        if (inNode._objects != NULL)
            {
            [[NSColor colorWithDeviceHue:0.0 saturation:((double)inNode._objects->size() / self.maximumObjectsPerNode) brightness:1.0 alpha:1.0] set];
            CGContextFillRect(context, inNode._frame);
            }

        [[NSColor blackColor] set];
        CGContextStrokeRect(context, inNode._frame);
        });
    }

- (void)dump
    {
    self.rootNode->Walk(0, ^(NSUInteger depth, const CQuadTreeNode &inNode) {
        NSString *theSpacing = [@"" stringByPaddingToLength:depth withString:@"\t" startingAtIndex:0];
        NSString *theString = [NSString stringWithFormat:@"%@%@", theSpacing, NSStringFromRect(inNode._frame)];
        printf("%s\n", [theString UTF8String]);
        });

    __block NSUInteger numberOfNodes = 0;
    __block NSUInteger numberOfObjects = 0;
    __block ObjectContainer::size_type maxObjects = 0;
    __block NSUInteger maxDepth = 0;
    __block NSUInteger totalDepth = 0;
    __block NSUInteger numberOfLeafNodes = 0;

    self.rootNode->Walk(0, ^(NSUInteger depth, const CQuadTreeNode &inNode) {

        numberOfNodes += 1;
        numberOfObjects += inNode._objects ? inNode._objects->size() : 0;
        maxDepth = MAX(maxDepth, depth);
        if (inNode._objects)
            {
            maxObjects = MAX(maxObjects, inNode._objects->size());
            numberOfLeafNodes += 1;
            totalDepth += depth;
            }
        });

    NSLog(@"%ld %ld %g %ld %ld %g", (long)numberOfNodes, (long)numberOfObjects, (double)numberOfObjects / (double)numberOfLeafNodes, (long)maxObjects, (long)maxDepth, (double)totalDepth / (double)numberOfLeafNodes);
    }

@end

#pragma mark -

CQuadTreeNode::CQuadTreeNode(NIMQuadTree *tree, const CGRect &frame)
    :   _tree(tree),
        _frame(frame),
        _objects(new ObjectContainer()),
        _subnodes(4)
    {
    }

CQuadTreeNode::~CQuadTreeNode()
    {
    if (_objects != NULL)
        {
        delete _objects;
        _objects = NULL;
        }
    }

void CQuadTreeNode::AddObject(id object, const CGPoint &point)
    {
    if (_objects != NULL
        && _objects->size() >= (ObjectContainer::size_type)_tree.maximumObjectsPerNode
        && _frame.size.width > _tree.minimumNodeSize.width
        && _frame.size.height > _tree.minimumNodeSize.height)
        {
        for (auto it = _objects->begin(); it != _objects->end(); ++it)
            {
            const CGPoint &thePoint = std::get<0> (*it);
            CQuadTreeNode *theNode = SubnodeForPoint(thePoint);
            NSCParameterAssert(theNode != NULL);
            id theObject = std::get<1> (*it).object();

            theNode->AddObject(theObject, thePoint);
            }
        delete _objects;
        _objects = NULL;
        }

    if (_objects == NULL)
        {
        CQuadTreeNode *theNode = SubnodeForPoint(point);
        NSCParameterAssert(theNode != NULL);
        theNode->AddObject(object, point);
        }
    else
        {
        _objects->push_back(std::make_tuple(point, object));
        }
    }

CQuadTreeNode *CQuadTreeNode::SubnodeForPoint(const CGPoint &point)
    {
    const CGXQuadrant theQuadrant = CGXQuadrantForPointInRect(point, _frame);
    NSCParameterAssert(theQuadrant != kCGXQuadrant_Unknown);
    CQuadTreeNode *theSubnode = _subnodes[(uint32_t)theQuadrant].get();
    if (theSubnode == NULL)
        {
        theSubnode = new CQuadTreeNode(_tree, CGRectQuadrant(_frame, theQuadrant));
        _subnodes[(uint32_t)theQuadrant].reset(theSubnode);
        }
    NSCParameterAssert(theSubnode != NULL);
    return theSubnode;
    }

NSArray *CQuadTreeNode::ObjectsInRect(const CGRect &rect) const
    {
    NSMutableArray *theArray = [NSMutableArray array];
    AddObjectsInRect(theArray, rect);
    return theArray;
    }

void CQuadTreeNode::AddObjectsInRect(NSMutableArray *objects, const CGRect &rect) const
    {
    if (_objects != NULL)
        {
        for (auto it = _objects->begin(); it != _objects->end(); ++it)
            {
            const CGPoint &thePoint = std::get<0> (*it);

            if (CGRectContainsPoint(rect, thePoint))
                {
                id theObject = std::get<1> (*it).object();
                [objects addObject:theObject];
                }
            }
        }

    for (auto it = _subnodes.begin(); it != _subnodes.end(); ++it)
        {
        if (*it && CGRectIntersectsRect(rect, (*it)->_frame))
            {
            (*it)->AddObjectsInRect(objects, rect);
            }
        }
    }

void CQuadTreeNode::Walk(NSUInteger depth, void (^visitBlock)(NSUInteger depth, const CQuadTreeNode &node)) const
    {
    visitBlock(depth, *this);
    for (auto it = _subnodes.begin(); it != _subnodes.end(); ++it)
        {
        if (*it)
            {
            (*it)->Walk(depth + 1, visitBlock);
            }
        }
    }
