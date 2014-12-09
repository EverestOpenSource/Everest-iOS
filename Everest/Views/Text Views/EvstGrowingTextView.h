//
//  EvstGrowingTextView.h
//  Everest
//
//  Created by Rob Phillips on 5/16/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <UIKit/UIKit.h>

@class EvstGrowingTextView;
@protocol EvstGrowingTextViewDelegate <UITextViewDelegate>
- (void)growingTextView:(EvstGrowingTextView *)textView didGrowByHeight:(CGFloat)height;
@end

@interface EvstGrowingTextView : UITextView

@property (nonatomic, weak) id<EvstGrowingTextViewDelegate> delegate;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, assign) CGFloat maximumHeight;
@property (nonatomic, assign) CGFloat minimumHeight;

@end
