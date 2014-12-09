//
//  EvstDatePickerView.h
//  Everest
//
//  Created by Rob Phillips on 2/3/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <UIKit/UIKit.h>

@class EvstDatePickerView;
@protocol EvstDatePickerViewDelegate <NSObject>
- (void)datePickerShouldBeDismissed:(EvstDatePickerView *)datePicker;
- (void)datePicker:(EvstDatePickerView *)datePicker didSelectDate:(NSDate *)selectedDate;
@end

@interface EvstDatePickerView : UIView

@property (nonatomic, weak) id<EvstDatePickerViewDelegate> delegate;

- (void)showDatePickerInView:(UIView *)view completion:(void (^)())completionHandler;
- (void)hideDatePickerWithCompletion:(void (^)())completionHandler;

@end
