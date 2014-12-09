//
//  EverestNotification.m
//  Everest
//
//  Created by Rob Phillips on 1/10/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EverestNotification.h"

const struct EverestNotificationMessagePartAttributes EverestNotificationMessagePartAttributes = {
	.content = @"content",
	.type = @"type",
	.uuid = @"uuid",
  .imageURLString = @"imageURLString"
};

@implementation EvstNotificationMessagePart

- (BOOL)hasLinkedURL {
  return self.type != nil;
}

- (NSURL *)linkedURL {
  return [EvstCommon destinationURLWithType:self.type uuid:self.uuid];
}

@end

const struct EverestNotificationAttributes EverestNotificationAttributes = {
	.destinationType = @"destinationType",
	.destinationUUID = @"destinationUUID",
	.createdAt = @"createdAt",
  .messageParts = @"messageParts"
};

@implementation EverestNotification

#pragma mark - Attributes

- (NSString *)fullText {
  EvstNotificationMessagePart *messagePart1 = [self.messageParts objectAtIndex:0];
  NSMutableString *text = [NSMutableString stringWithString:messagePart1.content];

  if (self.messageParts.count > 1) {
    EvstNotificationMessagePart *messagePart2 = [self.messageParts objectAtIndex:1];
    [text appendString:@" "];
    [text appendString:messagePart2.content];
  }
  
  if (self.messageParts.count > 2) {
    EvstNotificationMessagePart *messagePart3 = [self.messageParts objectAtIndex:2];
    [text appendString:@" "];
    [text appendString:messagePart3.content];
  }
  
  return text;
}

#pragma mark - Custom Getters

// Checks if this notification has been seen by the user on this device before
- (BOOL)isUnread {
  if (self.wasDisplayed) {
    return NO;
  }
  
  NSDate *lastReadNotificationDate = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:[EvstCommon keyForCurrentUserWithKey:kEvstLastReadNotificationDate]];
  return [lastReadNotificationDate compare:self.createdAt] == NSOrderedAscending;
}

#pragma mark - Convenience methods

- (NSURL *)avatarURL {
  // As proposed by Josh, notifications always specify user info in the first message part.
  return [NSURL URLWithString:[self.messageParts.firstObject imageURLString]];
}

- (NSURL *)userURL {
  // As proposed by Josh, notifications always specify user info in the first message part.
  return [self.messageParts.firstObject linkedURL];
}

- (NSURL *)destinationURL {
  return [EvstCommon destinationURLWithType:self.destinationType uuid:self.destinationUUID];
}

@end
