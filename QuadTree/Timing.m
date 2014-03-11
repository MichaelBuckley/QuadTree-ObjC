//
//  Timing.c
//  Vectors
//
//  Created by Jonathan Wight on 3/9/14.
//  Copyright (c) 2014 schwa.io. All rights reserved.
//

#import <Foundation/Foundation.h>

CFTimeInterval Time(NSUInteger iterations, void (^block)(void))
    {
    @autoreleasepool
        {
        const CFAbsoluteTime theStart = CFAbsoluteTimeGetCurrent();

        for (NSUInteger N = 0; N != iterations; ++N)
            {
            block();
            }

        const CFAbsoluteTime theEnd = CFAbsoluteTimeGetCurrent();
        return((theEnd - theStart) / (CFAbsoluteTime)iterations);
        };
    }
