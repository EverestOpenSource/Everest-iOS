//
//  UITouch+EvstTestAdditions.h
//  Everest
//
//  Created by Rob Phillips on 2/11/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <UIKit/UIKit.h>

@interface UITouch ()

// Needed for the moveItemAtRow method
@property(assign) UITouchPhase phase;

@end

@interface UITouch (EvstTestAdditions)

@end
