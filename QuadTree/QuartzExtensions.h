//
//  QuartzExtensions.h
//  Vectors
//
//  Created by Jonathan Wight on 3/9/14.
//  Copyright (c) 2014 schwa.io. All rights reserved.
//

#import <Quartz/Quartz.h>

static inline CGRect CGXRectWithCenterAndSize(CGPoint inCenter, CGSize inSize)
    {
    CGRect theRect = {
        .origin = {
            .x = inCenter.x - inSize.width * 0.5,
            .y = inCenter.y - inSize.height * 0.5,
            },
        .size = inSize,
        };
    return(theRect);
    }

typedef NS_ENUM(NSInteger, CGXQuadrant) {
    kCGXQuadrant_Unknown = -1,
    kCGXQuadrant_TopLeft = 0,
    kCGXQuadrant_TopRight,
    kCGXQuadrant_BottomLeft,
    kCGXQuadrant_BottomRight,
    };


static inline bool CGXRectIsFinite(CGRect inRect)
    {
    return CGRectIsNull(inRect) == false && CGRectIsInfinite(inRect) == false;
    }

static inline CGRect CGRectQuadrant(CGRect inRect, CGXQuadrant inQuadrant)
    {
    NSCParameterAssert(CGXRectIsFinite(inRect));

    const CGSize theSize = { inRect.size.width * 0.5, inRect.size.height * 0.5 };
    switch (inQuadrant)
        {
        case kCGXQuadrant_TopLeft:
            return((CGRect){
                .origin = { CGRectGetMinX(inRect), CGRectGetMidY(inRect) },
                .size = theSize
                });
        case kCGXQuadrant_TopRight:
            return((CGRect){
                .origin = { CGRectGetMidX(inRect), CGRectGetMidY(inRect) },
                .size = theSize
                });
        case kCGXQuadrant_BottomLeft:
            return((CGRect){
                .origin = { CGRectGetMinX(inRect), CGRectGetMinY(inRect) },
                .size = theSize
                });
        case kCGXQuadrant_BottomRight:
            return((CGRect){
                .origin = { CGRectGetMidX(inRect), CGRectGetMinY(inRect) },
                .size = theSize
                });
        default:
            return(CGRectNull);
        }
    }

static inline CGXQuadrant CGXQuadrantForPointAroundOrigin(CGPoint inPoint, CGPoint inOrigin)
    {
    if (inPoint.y >= inOrigin.y)
        {
        if (inPoint.x >= inOrigin.x)
            {
            return(kCGXQuadrant_TopRight);
            }
        else
            {
            return(kCGXQuadrant_TopLeft);
            }
        }
    else
        {
        if (inPoint.x >= inOrigin.x)
            {
            return(kCGXQuadrant_BottomRight);
            }
        else
            {
            return(kCGXQuadrant_BottomLeft);
            }
        }
    }

static inline CGXQuadrant CGXQuadrantForPointInRect(CGPoint inPoint, CGRect inRect)
    {
    NSCParameterAssert(CGXRectIsFinite(inRect));

    return CGXQuadrantForPointAroundOrigin(inPoint, (CGPoint){CGRectGetMidX(inRect), CGRectGetMidY(inRect)});
    }
