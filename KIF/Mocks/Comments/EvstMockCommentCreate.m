//
//  EvstMockCommentCreate.m
//  Everest
//
//  Created by Chris Cornelis on 01/28/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockCommentCreate.h"
#import "EvstMockMomentBase.h"

@implementation EvstMockCommentCreate

#pragma mark - Initialization

- (id<EvstMockItem>)initWithOptions:(NSUInteger)options {
  self = [super initWithOptions:options];
  if (!self) {
    return nil;
  }
  
  [self setRequestURLString:[NSString stringWithFormat:@"%@/%@", [EvstEnvironment baseURLStringWithAPIPath], kEndPointCreateListMomentCommentsFormat]];
  [self setHttpMethod:@"POST"];
  return self;
}

- (void)setMomentName:(NSString *)momentName {
  _momentName = momentName;
  
  NSString *momentUUID = [EvstMockMomentBase uuidForMomentWithName:momentName];
  [self setRequestURLString:[NSString stringWithFormat:@"%@/%@", [EvstEnvironment baseURLStringWithAPIPath], [NSString stringWithFormat:kEndPointCreateListMomentCommentsFormat, momentUUID]]];
}

#pragma mark - Response

- (OHHTTPStubsResponse *)response {
  NSDictionary *responseDictionary = @{
                                       kJsonComments: @[ @{
                                           kJsonId : kEvstTestCreateCommentUUID,
                                           kJsonContent : self.commentText,
                                           kJsonUpdatedAt : kEvstTestCreateCommentCreatedAt,
                                           kJsonCreatedAt : kEvstTestCreateCommentCreatedAt,
                                           kJsonLinks : @{
                                               kJsonUser : kEvstTestUserUUID
                                               }
                                           } ],
                                       kJsonLinked: @{
                                           kJsonUsers : @[
                                               @{
                                                 kJsonId : kEvstTestUserUUID,
                                                 kJsonFirstName : kEvstTestUserFirstName,
                                                 kJsonLastName : kEvstTestUserLastName,
                                                 kJsonImages : @{
                                                     kJsonAvatar : kEvstTestImagePathRobInCar
                                                     }
                                                 }
                                               ]
                                           }
                                       };
  
  return [self responseForDictionary:responseDictionary statusCode:200];
}

@end
