//
//  EvstTagView.h
//  Everest
//
//  Created by Rob Phillips on 6/4/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <UIKit/UIKit.h>

@class EvstTagView;
@protocol EvstTagViewDelegate <NSObject>
- (void)tagWasSelected:(EvstTagView *)tagView;
- (void)tagWasUnSelected:(EvstTagView *)tagView;
- (void)tagShouldBeRemoved:(EvstTagView *)tagView;
@end

@interface EvstTagView : UIView <UITextViewDelegate>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UITextView *textView; // used to capture keyboard touches when view is selected
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, weak) id<EvstTagViewDelegate> delegate;

+ (CGFloat)tagHeight;

- (id)initWithTagName:(NSString *)name;
- (void)select;
- (void)unSelect;

@end
