//
//  EvstErrorMappings.m
//  Everest
//
//  Created by Rob Phillips on 4/14/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstErrorMappings.h"
#import "EvstUserErrorMapping.h"

@implementation EvstErrorMappings

+ (NSArray *)responseDescriptors {
  NSMutableArray *responseDescriptors = [NSMutableArray arrayWithArray:[EvstUserErrorMapping responseDescriptors]];
  return responseDescriptors;
}

@end
