//
//  NSObject+MFIntrospectable.m
//  Empire
//
//  Created by Michael R. Fleet on 12/21/12.
//  Copyright (c) 2012 Michael R. Fleet. All rights reserved.
//



#import "NSObject+MFIntrospectable.h"
#import <objc/runtime.h>



#pragma mark - C


const char * property_getTypeString( objc_property_t property )
{
	const char * attrs = property_getAttributes( property );
	if ( attrs == NULL )
		return ( NULL );
    
	static char buffer[256];
	const char * e = strchr( attrs, ',' );
	if ( e == NULL )
		return ( NULL );
    
	int len = (int)(e - attrs);
	memcpy( buffer, attrs, len );
	buffer[len] = '\0';
    
	return ( buffer );
}



#pragma mark - MFIntrospectable



@implementation NSObject (MFIntrospectable)



+ (Class)classForKey:(NSString *)key
{
    return (NSClassFromString([self classNameForKey:key]));
}



+ (NSString *)classNameForKey:(NSString *)key
{
	objc_property_t property = class_getProperty(self, [key UTF8String]);
    
	if ( property == NULL )
    {
		return (NULL);
    }
    
    const char *type = property_getTypeString(property);
//    const char *attributes = property_getAttributes(property);
//    printf("attributes=%s\n", attributes);

    NSString *stringType = [NSString stringWithCString:type encoding:NSUTF8StringEncoding];
    NSArray *typeParts = [stringType componentsSeparatedByString:@"\""];
    
	return ([typeParts objectAtIndex:1]);
}



@end
