//
//  main.m
//  QuadTree
//
//  Created by Jonathan Wight on 3/10/14.
//  Copyright (c) 2014 schwa. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <math.h>

#import "NIMTest.h"

int main(int argc, const char * argv[])
    {
    @autoreleasepool
        {
        NSMutableArray *theResults = [NSMutableArray array];

        for (int N = 0; N != 5; ++N)
            {
            double theSearchRatios[] = { 0.0, 0.01, 0.1, 0.25, 0.5, 0.75, 1.0 };

            for (int R = 0; R != 7; ++R)
                {
                NIMTest *theTest = [[NIMTest alloc] init];

                theTest.size = (CGSize){ 512, 512 };
                theTest.numberOfItems = (NSUInteger)pow(10, N);
                NSLog(@"%d *****", (int)theTest.numberOfItems);
                theTest.insertionIterations = 1000;
                theTest.searchIterations = 1000;
                theTest.searchRatio = sqrt(theSearchRatios[R]);
                NSLog(@"%f *", theTest.searchRatio);
                theTest.minimumNodeSize = (CGSize){ 2, 2 };
                theTest.numberOfItemsPerNode = 8;

                NSDictionary *theResult = [theTest test];
                [theResults addObject:theResult];
                }

            }

        NSLog(@"%@", theResults);

        NSData *theData = [NSJSONSerialization dataWithJSONObject:theResults options:0 error:NULL];
        [theData writeToFile:@"data.json" atomically:YES];
        }
    return 0;
    }
