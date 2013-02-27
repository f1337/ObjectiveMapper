//
//  OMMapper.m
//  ObjectiveMapper
//
//  Created by Michael R. Fleet on 2/27/13.
//  Copyright (c) 2013 Michael R. Fleet. All rights reserved.
//



#import "OMMapper.h"



@implementation OMMapper



+ (id)mapValuesFromDictionary:(NSDictionary *)source withMap:(NSDictionary *)map
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    // iterate through mapping config
    for (NSString *keyPath in map)
    {
        id value = [source valueForKeyPath:keyPath];
        [result setValue:value forKeyPath:[map valueForKey:keyPath]];
    }
    
    return result;
}



+ (id)mapValuesFromDictionary:(NSDictionary *)source withMap:(NSDictionary *)map forClass:(Class)aClass
{
    id result = [[aClass alloc] init];
    
    // iterate through mapping config
    for (NSString *keyPath in map)
    {
        id value = [source valueForKeyPath:keyPath];
        Class sourceType = [value class];
        
        NSString *propertyName = [map valueForKey:keyPath];
        Class destinationType = [aClass classForKey:propertyName];
        
        // NSNull to nil conversion
        if ( [value isEqual:[NSNull null]] )
        {
            value = nil;
        }
        // NSArray to * conversions
        else if ( [sourceType isSubclassOfClass:[NSArray class]] )
        {
            if ( [destinationType isSubclassOfClass:[NSOrderedSet class]] )
            {
                value = [NSOrderedSet orderedSetWithArray:value];
            }
        }
        // NSOrderedSet to * conversions
        else if ( [sourceType isSubclassOfClass:[NSOrderedSet class]] )
        {
            if ( [destinationType isSubclassOfClass:[NSArray class]] )
            {
                value = [value array];
            }
        }
        // NSString to * conversions
        else if ( [sourceType isSubclassOfClass:[NSString class]] )
        {
            if ( [destinationType isSubclassOfClass:[NSDecimalNumber class]] )
            {
                value = [NSDecimalNumber decimalNumberWithString:value];
            }
            else if ( [destinationType isSubclassOfClass:[NSNumber class]] )
            {
                NSString *uppercaseValue = [value uppercaseString];
                NSSet *trueValues = [NSSet setWithObjects:@"YES", @"Y", @"TRUE", @"T", nil];
                NSSet *booleanValues = [trueValues setByAddingObjectsFromSet:[NSSet setWithObjects:@"NO", @"N", @"FALSE", @"F", nil]];
                
                if ( [booleanValues containsObject:uppercaseValue] )
                {
                    value = [NSNumber numberWithBool:[trueValues containsObject:uppercaseValue]];
                }
                else
                {
                    value = [NSNumber numberWithDouble:[value doubleValue]];
                }
            }
            else if ( [destinationType isSubclassOfClass:[NSURL class]] )
            {
                value = [NSURL URLWithString:value];
            }
        }
        // NSNumber to * conversions
        else if ( [sourceType isSubclassOfClass:[NSNumber class]] )
        {
            if ( [destinationType isSubclassOfClass:[NSDate class]] )
            {
                value = [NSDate dateWithTimeIntervalSince1970:[value doubleValue]];
            }
        }
        
        
        
        
        [result setValue:value forKeyPath:propertyName];
    }
    
    return result;
}



@end
