//
//  EvstTagView.m
//  Everest
//
//  Created by Rob Phillips on 6/4/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstTagView.h"

static CGFloat const kEvstTagViewHorizontalPadding = 8.f;
static CGFloat const kEvstTagViewVerticalPadding = 2.f;
static CGFloat const kEvstTagViewMaxWidth = 250.f;

@interface EvstTagView ()
@property (nonatomic, strong) NSString *displayedName;
@end

@implementation EvstTagView

#pragma mark - Lifecycle

- (id)initWithTagName:(NSString *)name {
  self = [super init];
  if (self){
    [self setupViewWithName:name];
  }
  return self;
}

- (void)dealloc {
  self.delegate = nil;
}

#pragma mark - Setup

- (void)setupViewWithName:(NSString *)name {
  self.accessibilityLabel = kLocaleTag;
  self.isSelected = NO;
  self.backgroundColor = kColorMomentTagUnselected;
  
  UIView *superview = self;
  
  // Create Label
  self.label = [[UILabel alloc] init];
  self.label.backgroundColor = [UIColor clearColor];
  self.label.textColor = kColorWhite;
  self.label.font = kFontAddMomentTags;
  [self addSubview:self.label];
  [self.label makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(superview.left).offset(kEvstTagViewHorizontalPadding);
    make.right.equalTo(superview.right).offset(-kEvstTagViewHorizontalPadding);
    make.top.equalTo(superview.top).offset(-kEvstTagViewVerticalPadding);
    make.bottom.equalTo(superview.bottom).offset(kEvstTagViewVerticalPadding);
  }];
  
  self.textView = [[UITextView alloc] init];
  self.textView.delegate = self;
  self.textView.hidden = YES;
  [self addSubview:self.textView];
  
  // Create a tap gesture recognizer
  UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture)];
  tapGesture.numberOfTapsRequired = 1;
  tapGesture.numberOfTouchesRequired = 1;
  [self addGestureRecognizer:tapGesture];
  
  self.name = name;
  [self unSelect];
}

#pragma mark - Custom Setter

// Sets a maximum allowable width for each tag to prevent obnoxiously verbose tags
- (void)setFrame:(CGRect)frame {
  CGRect newFrame = frame;
  newFrame.size.width = MIN(kEvstTagViewMaxWidth, frame.size.width);
  [super setFrame:newFrame];
}

- (void)setName:(NSString *)name {
  _name = name;
  self.accessibilityValue = name;
  
  // Attach hashtags to all tag names for display purposes only
  NSString *tagWithHashSymbol = [NSString stringWithFormat:@"#%@", name];
  self.label.text = self.displayedName = tagWithHashSymbol;
  [self adjustSize];
}

#pragma mark - Calculations

+ (CGFloat)tagHeight {
  return round(kFontAddMomentTags.lineHeight + 2 * kEvstTagViewVerticalPadding);
}

#pragma mark - Actions

- (void)adjustSize {
  CGFloat calculatedWidth = [self.displayedName sizeWithAttributes:@{ NSFontAttributeName : kFontAddMomentTags }].width;
  CGFloat paddedWidth = MIN(kEvstTagViewMaxWidth, calculatedWidth) + 2 * kEvstTagViewHorizontalPadding + 2.f;
  self.bounds = CGRectMake(0, 0, paddedWidth, [EvstTagView tagHeight]);
  
  // Round the corners (this needs to be done at time of adjustment)
  self.layer.masksToBounds = YES;
  self.layer.cornerRadius = self.frame.size.height / 2.f;
}

- (void)select {
  if ([self.delegate respondsToSelector:@selector(tagWasSelected:)]){
    [self.delegate tagWasSelected:self];
  }
  self.backgroundColor = kColorMomentTagSelected;
  self.isSelected = YES;
  
  // Captures the user pressing the delete key
  [self.textView becomeFirstResponder];
}

- (void)unSelect {
  if ([self.delegate respondsToSelector:@selector(tagWasUnSelected:)]){
    [self.delegate tagWasUnSelected:self];
  }
  self.backgroundColor = kColorMomentTagUnselected;
  [self setNeedsDisplay];
  
  self.isSelected = NO;
  [self.textView resignFirstResponder];
}

- (void)handleTapGesture {
  if (self.isSelected){
    [self unSelect];
  } else {
    [self select];
  }
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
  self.textView.hidden = NO;
  
  if ([text isEqualToString:@"\n"]){ // Return key was pressed
    return NO;
  }
  
  // Capture "delete" key press when cell is empty
  if ([textView.text isEqualToString:@""] && [text isEqualToString:@""]){
    if ([self.delegate respondsToSelector:@selector(tagShouldBeRemoved:)]){
      [self.delegate tagShouldBeRemoved:self];
    }
    return NO;
  } else {
    [self unSelect];
    if ([self.delegate respondsToSelector:@selector(tagWasUnSelected:)]){
      [self.delegate tagWasUnSelected:self];
    }
  }
  
  return YES;
}

@end
