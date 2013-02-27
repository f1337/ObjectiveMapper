//
//  OMMapperTest.m
//  ObjectiveMapper
//
//  Created by Michael R. Fleet on 12/20/12.
//  Copyright (c) 2012 Michael Fleet. All rights reserved.
//



#import "OMMapperTest.h"
#import "OMDummy.h"
#import "NSObject+OMIntrospectable.h"



#pragma mark - OMMapper



@interface OMMapper : NSObject



+ (id)mapValuesFromDictionary:(NSDictionary *)source withMap:(NSDictionary *)map;
+ (id)mapValuesFromDictionary:(NSDictionary *)source withMap:(NSDictionary *)map forClass:(Class)aClass;



@end



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



#pragma mark - OMMapperTest



@implementation OMMapperTest



- (void)setUp
{
    [super setUp];

    [self setSource:@{
        @"array" : @[ @"one", @"two", @"three" ],
        @"decimal" : @"15.26",
        @"number" : @"12.43",
        @"set" : [NSOrderedSet orderedSetWithObjects:@"any", @"ole", @"order", nil],
        @"thenothing": [NSNull null],
        @"timestamp" : @1356542773,
        @"url" : @"http://www.example.com"
    }];

    [self setMap:@{
        @"array" : @"anOrderedSet",
        @"decimal" : @"aDecimalNumber",
        @"number" : @"aNumber",
        @"set" : @"anArray",
        @"thenothing": @"aNilObject",
        @"timestamp" : @"aTimestamp",
        @"url" : @"aURL"
    }];

    [self setObject:[OMMapper mapValuesFromDictionary:_source withMap:_map forClass:[OMDummy class]]];
}



- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}



- (id)JSONObjectWithData:(NSData *)data
{
    NSError *e = nil;
    id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&e];
    return object;
}



- (void)testShouldMapKeyPaths
{
    NSString *JSONString = @"{ \"person\": { \"name\": \"Billy\" }, \"signup\": { \"date\": \"12/12/2012\" }, \"test\": \"tickles\" }";
    NSData *data = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *sourceDict = [self JSONObjectWithData:data];

    NSDictionary *mapDict = @{
        @"person.name"  : @"name",
        @"signup.date"  : @"date",
        @"test"         : @"dummy"
    };

    NSDictionary *resultDict = [OMMapper mapValuesFromDictionary:sourceDict withMap:mapDict];
    STAssertTrue([[resultDict valueForKey:@"name"] isEqualToString:[sourceDict valueForKeyPath:@"person.name"]], nil);
    STAssertTrue([[resultDict valueForKey:@"date"] isEqualToString:[sourceDict valueForKeyPath:@"signup.date"]], nil);
    STAssertTrue([[resultDict valueForKey:@"dummy"] isEqualToString:[sourceDict valueForKeyPath:@"test"]], nil);
}



- (void)testShouldMapNSDateFromNSNumber
{
    STAssertTrue([[_object aTimestamp] isKindOfClass:[NSDate class]], nil);
    STAssertTrue([[_object aTimestamp] isEqualToDate:[NSDate dateWithTimeIntervalSince1970:[[_source valueForKeyPath:@"timestamp"] doubleValue]]], nil);
}



- (void)testShouldMapNSDateFromNSString
{
    STFail(@"hella");
}



- (void)testShouldMapNSDecimalNumberFromNSString
{
    STAssertTrue([[_object aDecimalNumber] isKindOfClass:[NSDecimalNumber class]], nil);
    STAssertTrue([[[_object aDecimalNumber] stringValue] isEqualToString:[_source valueForKeyPath:@"decimal"]], nil);
}



- (void)testShouldMapNSNumberFromNSString
{
    STAssertTrue([[_object aNumber] isKindOfClass:[NSNumber class]], nil);
    STAssertTrue([[[_object aNumber] stringValue] isEqualToString:[_source valueForKeyPath:@"number"]], nil);
}



- (void)testShouldMapNSNumberWithBoolFromJSONFalse
{
    NSString *JSONString = @"{ \"bool\": false }";
    NSData *data = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *source = [self JSONObjectWithData:data];
    
    NSDictionary *map = @{ @"bool" : @"aNumber" };
    
    [self setObject:[OMMapper mapValuesFromDictionary:source withMap:map forClass:[OMDummy class]]];
    
    STAssertTrue([[_object aNumber] isKindOfClass:[NSNumber class]], nil);
    STAssertTrue((! [[_object aNumber] boolValue] ), nil);
}



- (void)testShouldMapNSNumberWithBoolFromJSONTrue
{
    NSString *JSONString = @"{ \"bool\": true }";
    NSData *data = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *source = [self JSONObjectWithData:data];
    
    NSDictionary *map = @{ @"bool" : @"aNumber" };

    [self setObject:[OMMapper mapValuesFromDictionary:source withMap:map forClass:[OMDummy class]]];
    
    STAssertTrue([[_object aNumber] isKindOfClass:[NSNumber class]], nil);
    STAssertTrue([[_object aNumber] boolValue], nil);
}



- (void)testShouldMapNSNumberWithBoolFromNSString
{
    NSArray *trues = @[@"True", @"Yes"];
    NSArray *falses = @[@"False", @"No"];
    NSDictionary *map = @{ @"bool" : @"aNumber" };
    
    for ( NSString *trueValue in trues )
    {
        NSMutableArray *values = [NSMutableArray array];
        [values addObject:trueValue];
        [values addObject:[trueValue lowercaseString]];
        [values addObject:[trueValue uppercaseString]];
        [values addObject:[[trueValue substringToIndex:1] lowercaseString]];
        [values addObject:[[trueValue substringToIndex:1] uppercaseString]];
        
        
        for ( NSString *value in values )
        {
            NSDictionary *source = @{ @"bool" : value };
            
            [self setObject:[OMMapper mapValuesFromDictionary:source withMap:map forClass:[OMDummy class]]];
            
            STAssertTrue([[_object aNumber] isKindOfClass:[NSNumber class]], nil);
            STAssertTrue([[_object aNumber] boolValue], @"'%@' should be true.", value);
        }
    }
    
    for ( NSString *falseValue in falses )
    {
        NSMutableArray *values = [NSMutableArray array];
        [values addObject:falseValue];
        [values addObject:[falseValue lowercaseString]];
        [values addObject:[falseValue uppercaseString]];
        [values addObject:[[falseValue substringToIndex:1] lowercaseString]];
        [values addObject:[[falseValue substringToIndex:1] uppercaseString]];
        
        
        for ( NSString *value in values )
        {
            NSDictionary *source = @{ @"bool" : value };
            
            [self setObject:[OMMapper mapValuesFromDictionary:source withMap:map forClass:[OMDummy class]]];
            
            STAssertTrue([[_object aNumber] isKindOfClass:[NSNumber class]], nil);
            STAssertTrue(( ! [[_object aNumber] boolValue] ), @"'%@' should be false.", value);
        }
    }
}



- (void)testShouldMapNSURLFromNSString
{
    STAssertTrue([[_object aURL] isKindOfClass:[NSURL class]], nil);
    STAssertTrue([[[_object aURL] absoluteString] isEqualToString:[_source valueForKeyPath:@"url"]], nil);
}



- (void)testShouldMapNSArrayFromNSOrderedSet
{
    NSArray *expectedArray = [[_source valueForKeyPath:@"set"] array];
    STAssertTrue([[_object anArray] isKindOfClass:[NSArray class]], nil);
    STAssertTrue([[_object anArray] isEqualToArray:expectedArray], nil);
}



- (void)testShouldMapNSOrderedSetFromNSArray
{
    NSOrderedSet *expectedSet = [NSOrderedSet orderedSetWithArray:[_source valueForKeyPath:@"array"]];
    STAssertTrue([[_object anOrderedSet] isKindOfClass:[NSOrderedSet class]], nil);
    STAssertTrue([[_object anOrderedSet] isEqualToOrderedSet:expectedSet], nil);
}



- (void)testShouldMapNSStringFromStringValue
{
    STFail(@"hella");
}



- (void)testShouldMapNilFromNSNull
{
    // sanity check to ensure test is setup properly
    STAssertTrue([[_source valueForKeyPath:@"thenothing"] isEqual:[NSNull null]], nil);
    // actual test assertion
    STAssertNil([_object aNilObject], nil);
}



@end
