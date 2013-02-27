//
//  OMIntrospectableTest.m
//  ObjectiveMapper
//
//  Created by Michael R. Fleet on 12/21/12.
//  Copyright (c) 2012 Michael Fleet. All rights reserved.
//



#import "OMIntrospectableTest.h"
#import "OMDummy.h"
#import "NSObject+OMIntrospectable.h"



@implementation OMIntrospectableTest



- (void)testShouldIntrospectNSTypes
{
    NSDictionary *types = @{
        @"anArray":         [NSArray class],
        @"aDate":           [NSDate class],
        @"aDecimalNumber":  [NSDecimalNumber class],
        @"aNumber":         [NSNumber class],
        @"anOrderedSet":    [NSOrderedSet class],
        @"aString":         [NSString class],
        @"aURL":            [NSURL class]
    };

    for (NSString *key in types)
    {
        Class expectedClass = [types objectForKey:key];
        Class actualClass = [OMDummy classForKey:key];
        if ( ! [actualClass isSubclassOfClass:expectedClass] )
        {
            STFail(@"Expected: %@, got: %@", expectedClass, actualClass);
        }
    }
}



@end
