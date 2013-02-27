//
//  OMMapperTest.m
//  ObjectiveMapper
//
//  Created by Michael R. Fleet on 12/20/12.
//  Copyright (c) 2012 Michael Fleet. All rights reserved.
//



#import <SenTestingKit/SenTestingKit.h>
#import "ObjectiveMapper.h"
#import "OMDummy.h"



@interface OMMapperTest : SenTestCase

@property NSDictionary  *map;
@property OMDummy       *object;
@property NSDictionary  *source;

@end



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
