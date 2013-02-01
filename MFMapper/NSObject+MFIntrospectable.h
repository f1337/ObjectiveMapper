//
//  NSObject+MFIntrospectable.h
//  Empire
//
//  Created by Michael R. Fleet on 12/21/12.
//  Copyright (c) 2012 Michael Fleet. All rights reserved.
//



#import <Foundation/Foundation.h>



@interface NSObject (MFIntrospectable)



+ (Class)classForKey:(NSString *)key;
+ (NSString *)classNameForKey:(NSString *)key;



@end
