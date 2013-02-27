//
//  OMMapper.h
//  ObjectiveMapper
//
//  Created by Michael R. Fleet on 2/27/13.
//  Copyright (c) 2013 Michael R. Fleet. All rights reserved.
//



#import "NSObject+OMIntrospectable.h"



@interface OMMapper : NSObject



+ (id)mapValuesFromDictionary:(NSDictionary *)source withMap:(NSDictionary *)map;
+ (id)mapValuesFromDictionary:(NSDictionary *)source withMap:(NSDictionary *)map forClass:(Class)aClass;



@end
