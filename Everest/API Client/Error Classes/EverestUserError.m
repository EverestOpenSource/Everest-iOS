//
//  EverestUserError.m
//  Everest
//
//  Created by Rob Phillips on 4/14/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EverestUserError.h"
#import "EvstUserErrorMapping.h"

@implementation EverestUserError

- (NSString *)description {
  return [self errorStringFromHumanReadableDictionary:[EvstUserErrorMapping errorDescriptionsDictionary]];
}

@end
