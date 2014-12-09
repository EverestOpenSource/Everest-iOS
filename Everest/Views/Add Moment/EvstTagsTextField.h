//
//  EvstTagsTextField.h
//  Everest
//
//  Created by Rob Phillips on 6/2/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <UIKit/UIKit.h>

@class EvstTagsTextField;
@protocol EvstTagsTextFieldDelegate <UITextFieldDelegate>
@optional
- (void)textFieldDidChange:(EvstTagsTextField *)textField;
- (void)textFieldDidHitBackspaceWithEmptyText:(EvstTagsTextField *)textField;
@end

@interface EvstTagsTextField : UITextField
@property (nonatomic, weak) id<EvstTagsTextFieldDelegate> delegate;
@end
