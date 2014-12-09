//
//  EverestNotification.h
//  Everest
//
//  Created by Rob Phillips on 1/10/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

extern const struct EverestNotificationMessagePartAttributes {
	__unsafe_unretained NSString *content;
	__unsafe_unretained NSString *type;
	__unsafe_unretained NSString *uuid;
	__unsafe_unretained NSString *imageURLString;
} EverestNotificationMessagePartAttributes;

@interface EvstNotificationMessagePart : NSObject

@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *imageURLString;
@property (nonatomic, assign) NSRange range;

- (BOOL)hasLinkedURL;
- (NSURL *)linkedURL;

@end

extern const struct EverestNotificationAttributes {
	__unsafe_unretained NSString *destinationType;
	__unsafe_unretained NSString *destinationUUID;
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *message1;
	__unsafe_unretained NSString *message2;
	__unsafe_unretained NSString *message3;
	__unsafe_unretained NSString *messageParts;
} EverestNotificationAttributes;

@interface EverestNotification : NSObject

#pragma mark -  Attributes

@property (nonatomic, assign) BOOL wasDisplayed;
@property (nonatomic, strong) NSString *destinationType;
@property (nonatomic, strong) NSString *destinationUUID;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) EvstNotificationMessagePart *message1;
@property (nonatomic, strong) EvstNotificationMessagePart *message2;
@property (nonatomic, strong) EvstNotificationMessagePart *message3;
@property (nonatomic, strong) NSArray *messageParts;
@property (nonatomic, strong, readonly) NSString *fullText;

#pragma mark - Convenience methods

/*!
 * Checks if this notification has been seen by the user on this device before
 */
- (BOOL)isUnread;

/*!
 * Gets the avatar URL for this notification
 */
- (NSURL *)avatarURL;

/*!
 * Gets the URL for the user of this notificaton
 */
- (NSURL *)userURL;

/*!
 * Gets the URL for the destination of this notificaton
 */
- (NSURL *)destinationURL;

@end
