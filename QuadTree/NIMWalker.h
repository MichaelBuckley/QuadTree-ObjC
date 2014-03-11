//
//  NIMWalker.h
//  Vectors
//
//  Created by Jonathan Wight on 3/9/14.
//  Copyright (c) 2014 schwa.io. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^VisitBlock)(id parent, id object, NSUInteger depth, BOOL *stop);

@interface NIMWalker : NSObject

@property (readwrite, nonatomic, copy) NSString *childrenKey;

@property (readwrite, nonatomic, copy) NSArray * (^childrenBlock)(id object);

@property (readwrite, nonatomic, copy) NSUInteger (^childCountBlock)(id object);
@property (readwrite, nonatomic, copy) id (^childAtIndexBlock)(id object, NSUInteger idx);

- (void)walk:(id)object visit:(VisitBlock)visitBlock;

@end

