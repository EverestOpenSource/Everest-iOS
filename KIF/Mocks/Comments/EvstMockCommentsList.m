//
//  EvstMockCommentsList.m
//  Everest
//
//  Created by Chris Cornelis on 01/28/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMockCommentsList.h"
#import "EvstMockMomentBase.h"

@interface EvstMockCommentsList ()
@property (nonatomic, assign) NSUInteger offset;
@property (nonatomic, assign) NSUInteger limit;
@property (strong, nonatomic) NSString *baseURLStringWithoutCreatedBefore;
@end

@implementation EvstMockCommentsList

#pragma mark - Initialisation

- (id<EvstMockItem>)initWithOptions:(NSUInteger)options {
  self = [super initWithOptions:options];
  if (!self) {
    return nil;
  }
  
  [self setHttpMethod:@"GET"];
  return self;
}

- (void)mockWithMomentNamed:(NSString *)momentName offset:(NSUInteger)offset limit:(NSUInteger)limit {
  self.offset = offset;
  self.limit =  limit;
  
  NSString *momentUUID = [EvstMockMomentBase uuidForMomentWithName:momentName];
  self.baseURLStringWithoutCreatedBefore = [NSString stringWithFormat:@"%@/%@", [EvstEnvironment baseURLStringWithAPIPath], [NSString stringWithFormat:kEndPointCreateListMomentCommentsFormat, momentUUID]];
  
  [self setRequestURLString:[NSString stringWithFormat:@"%@?%@=%@&%@=%lu&%@=%lu", self.baseURLStringWithoutCreatedBefore, kJsonCreatedBefore, RKStringFromDate([NSDate date]), kJsonLimit, (unsigned long)limit, kJsonOffset, (unsigned long)offset]];
}

#pragma mark - EvstMockBaseItem protocol

- (BOOL)isMockForRequest:(NSURLRequest *)request {
  if (![self.httpMethod isEqualToString:request.HTTPMethod]) {
    return NO;
  }
  // The actual "created before" parameter value can be slightly different from the expected one, so do a prefix match.
  BOOL matchesPrefix = [[request URLDecodedString] hasPrefix:[NSString stringWithFormat:@"%@?%@=", self.baseURLStringWithoutCreatedBefore, kJsonCreatedBefore]];
  BOOL hasCorrectLimit = [[request URLDecodedString] rangeOfString:[NSString stringWithFormat:@"%@=%lu", kJsonLimit, (unsigned long)self.limit]].location != NSNotFound;
  BOOL hasCorrectOffset = [[request URLDecodedString] rangeOfString:[NSString stringWithFormat:@"%@=%lu", kJsonOffset, (unsigned long)self.offset]].location != NSNotFound;
  return matchesPrefix && hasCorrectLimit && hasCorrectOffset;
}

#pragma mark - Response

- (OHHTTPStubsResponse *)response {
  
  NSDictionary *responseDictionary = @{
                                       kJsonComments: [self commentsForCurrentOffsetAndLimit],
                                       kJsonLinked: @{
                                           kJsonUsers : @[
                                               @{
                                                 kJsonId : kEvstTestUserOtherUUID,
                                                 kJsonFirstName : kEvstTestUserOtherFirstName,
                                                 kJsonLastName : kEvstTestUserOtherLastName,
                                                 kJsonImages : @{
                                                     kJsonAvatar : kEvstTestImageFlowerHead
                                                     }
                                                 },
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

- (NSArray *)commentsForCurrentOffsetAndLimit {
  if (self.offset == EvstMockOffsetForAllComments) {
    return @[ @{ kJsonId : kEvstTestCommentRow1UUID,
                 kJsonContent : kEvstTestCommentRow1Text,
                 kJsonUpdatedAt : kEvstTestCommentRow1CreatedAt,
                 kJsonCreatedAt : kEvstTestCommentRow1CreatedAt,
                 kJsonLinks : @{
                     kJsonUser : kEvstTestUserOtherUUID
                     }
                 }];
  }
  
  return @[ @{ kJsonId : kEvstTestCommentRow2UUID,
               kJsonContent : kEvstTestCommentRow2Text,
               kJsonUpdatedAt : kEvstTestCommentRow2CreatedAt,
               kJsonCreatedAt : kEvstTestCommentRow2CreatedAt,
               kJsonLinks : @{
                   kJsonUser : kEvstTestUserOtherUUID
                   }
               },
             @{
               kJsonId : kEvstTestCommentRow3UUID,
               kJsonContent : kEvstTestCommentRow3Text,
               kJsonUpdatedAt : kEvstTestCommentRow3CreatedAt,
               kJsonCreatedAt : kEvstTestCommentRow3CreatedAt,
               kJsonLinks : @{
                   kJsonUser : kEvstTestUserUUID
                   }
               },
             @{ kJsonId : kEvstTestCommentRow4UUID,
                kJsonContent : kEvstTestCommentRow4Text,
                kJsonUpdatedAt : kEvstTestCommentRow4CreatedAt,
                kJsonCreatedAt : kEvstTestCommentRow4CreatedAt,
                kJsonLinks : @{
                    kJsonUser : kEvstTestUserOtherUUID
                    }
                },
             @{
               kJsonId : kEvstTestCommentRow5UUID,
               kJsonContent : kEvstTestCommentRow5Text,
               kJsonUpdatedAt : kEvstTestCommentRow5CreatedAt,
               kJsonCreatedAt : kEvstTestCommentRow5CreatedAt,
               kJsonLinks : @{
                   kJsonUser : kEvstTestUserUUID
                   }
               },
             ];
}

@end
