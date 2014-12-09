//
//  EvstNotificationMapping.h
//  Everest
//
//  Created by Rob Phillips on 12/5/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

#import <RestKit/RestKit.h>

@interface EvstNotificationMapping : NSObject

+ (NSArray *)responseDescriptors;
+ (RKRequestDescriptor *)requestDescriptor;

@end
