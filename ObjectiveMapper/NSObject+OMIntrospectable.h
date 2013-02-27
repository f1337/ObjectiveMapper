//
//  NSObject+OMIntrospectable.h
//  ObjectiveMapper
//
//  Created by Michael R. Fleet on 12/21/12.
//  Copyright (c) 2012 Michael Fleet. All rights reserved.
//



#import <Foundation/Foundation.h>



@interface NSObject (OMIntrospectable)



+ (Class)classForKey:(NSString *)key;
+ (NSString *)classNameForKey:(NSString *)key;



@end
