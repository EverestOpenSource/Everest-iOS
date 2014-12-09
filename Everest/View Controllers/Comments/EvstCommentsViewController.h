//
//  EvstCommentsViewController.h
//  Everest
//
//  Created by Rob Phillips on 1/13/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <UIKit/UIKit.h>
#import "EverestMoment.h"
#import "EvstMomentFormViewController.h"
#import "EvstGrowingTextView.h"

extern NSUInteger const kEvstCommentContentMaxLength;

@interface EvstCommentsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, UITextViewDelegate, EvstGrowingTextViewDelegate>

@property (nonatomic, strong) EverestMoment *moment;
@property (nonatomic, assign) BOOL didShowViewUsingCommentButton;

@end
