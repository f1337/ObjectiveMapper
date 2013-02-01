//
//  MFIntrospectableTest.m
//  Empire
//
//  Created by Michael R. Fleet on 12/21/12.
//  Copyright (c) 2012 Michael Fleet. All rights reserved.
//



#import "MFIntrospectableTest.h"
#import "MFDummy.h"
#import "NSObject+MFIntrospectable.h"



@implementation MFIntrospectableTest



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
        Class actualClass = [MFDummy classForKey:key];
        if ( ! [actualClass isSubclassOfClass:expectedClass] )
        {
            STFail(@"Expected: %@, got: %@", expectedClass, actualClass);
        }
    }
}



@end
