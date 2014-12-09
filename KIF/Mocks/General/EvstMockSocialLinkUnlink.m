//
//  EvstMockSocialLinkUnlink.m
//  Everest
//
//  Created by Rob Phillips on 3/14/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockSocialLinkUnlink.h"

@implementation EvstMockSocialLinkUnlink

#pragma mark - Initialisation

- (id<EvstMockItem>)initWithOptions:(NSUInteger)options {
  self = [super initWithOptions:options];
  if (!self) {
    return nil;
  }
  
  [self setRequestURLString:[NSString stringWithFormat:@"%@/%@", [EvstEnvironment baseURLStringWithAPIPath], options == kEvstMockLinkFacebookOption ? kEndPointLinkUnlinkFacebook : kEndPointLinkUnlinkTwitter]];
  BOOL linking = (options == kEvstMockLinkFacebookOption || options == kEvstMockLinkTwitterOption);
  [self setHttpMethod: linking ? @"POST" : @"DELETE"];
  return self;
}

@end
