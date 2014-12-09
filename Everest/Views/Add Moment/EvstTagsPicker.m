//
//  EvstTagsPicker.m
//  Everest
//
//  Created by Rob Phillips on 5/29/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

// Based on https://github.com/tristanhimmelman/THContactPicker

#import "EvstTagsPicker.h"

static NSInteger const kEvstTotalAllowableTagsCount = 5;
static NSInteger const kEvstTagsMaximumCharacterCount = 20;
static CGFloat const kEvstTagViewHorizontalPadding = 5.f;
static CGFloat const kEvstTagViewVerticalPadding = 5.f;
static CGFloat const kEvstTagsPickerHeight = 35.f;
static CGFloat const kEvstTagsFieldMinimumWidth = 30.f;

@interface EvstTagsPicker ()
@property (nonatomic, strong) UIView *modalBackgroundView;
@property (nonatomic, strong) UIView *tagsContainer;
@property (nonatomic, weak) UIView *animatingFromView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *tagsCount;
@property (nonatomic, strong) UITextField *tagsField;
@property (nonatomic, assign) BOOL shouldSelectTagsField;
@property (nonatomic, strong) NSMutableOrderedSet *tags;
@property (nonatomic, strong) NSMutableOrderedSet *tagViews;
@property (nonatomic, strong) EvstTagView *selectedTagView;

@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property (nonatomic, strong) MASConstraint *bottomConstraint;
@property (nonatomic, assign) CGFloat leftPadding;
@property (nonatomic, assign) CGFloat lineHeight;
@property (nonatomic, assign) CGFloat tagHeight;

@property (nonatomic, copy) void(^dismissHandler)(NSOrderedSet *tags);
@end

@implementation EvstTagsPicker

#pragma mark - Lifecycle

- (instancetype)initWithTagsOrderedSet:(NSOrderedSet *)tags dismissHandler:(void (^)(NSOrderedSet *tags))dismissHandler {
  self = [super initWithFrame:CGRectMake(0.f, 0.f, kEvstMainScreenWidth, kEvstMainScreenHeight)];
  if (self) {
    [self registerNotifications];
    self.clipsToBounds = YES;
    
    self.dismissHandler = dismissHandler;
    self.tags = tags ? [[NSMutableOrderedSet alloc] initWithOrderedSet:tags] : [[NSMutableOrderedSet alloc] init];
    self.tagViews = [[NSMutableOrderedSet alloc] init];
    [self setupView];
    [self layoutViewForTagChange:NO];
  }
  return self;
}

- (void)dealloc {
  [self unregisterNotifications];
}

#pragma mark - Setup

- (void)setupView {
  self.modalBackgroundView = [[UIView alloc] initWithFrame:self.frame];
  self.modalBackgroundView.accessibilityLabel = kLocaleBackgroundView;
  
  // Tap or swipe down to dismiss
  UITapGestureRecognizer *tapModalBGGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOrSwipeToDismiss:)];
  [self.modalBackgroundView addGestureRecognizer:tapModalBGGestureRecognizer];
  UISwipeGestureRecognizer *swipeModalBGGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOrSwipeToDismiss:)];
  swipeModalBGGesture.direction = UISwipeGestureRecognizerDirectionDown;
  [self.modalBackgroundView addGestureRecognizer:swipeModalBGGesture];
  
  [self addSubview:self.modalBackgroundView];
  self.modalBackgroundView.alpha = 0.f;
  self.modalBackgroundView.backgroundColor = [UIColor blackColor];
  
  UIView *superview = self;
  self.tagsContainer = [[UIView alloc] init];
  self.tagsContainer.backgroundColor = kColorWhite;
  [self addSubview:self.tagsContainer];
  [self.tagsContainer makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(superview.left);
    make.right.equalTo(superview.right);
    make.height.equalTo(@0);
    self.bottomConstraint = make.bottom.equalTo(superview.bottom);
  }];
  
  self.scrollView = [[UIScrollView alloc] init];
  self.scrollView.alpha = 0.f;
  self.scrollView.delegate = self;
  [self.tagsContainer addSubview:self.scrollView];
  [self.scrollView makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.tagsContainer);
  }];
  
  self.tagsField = [[EvstTagsTextField alloc] init];
  self.tagsField.hidden = YES;
  self.tagsField.delegate = self;
  self.tagsField.autocorrectionType = UITextAutocorrectionTypeNo;
  
  self.tagsCount = [[UILabel alloc] initWithFrame:CGRectMake(8.f, 6.f, 10.f, 21.f)];
  self.tagsCount.accessibilityLabel = kLocaleTagsRemaining;
  self.tagsCount.font = kFontHelveticaNeueBold12;
  [self.scrollView addSubview:self.tagsCount];
}

#pragma mark - Layout

- (void)layoutViewForTagChange:(BOOL)changingTag {
  CGRect frameOfLastTag = CGRectNull;
  NSInteger lineCount = 1;
  CGFloat tagVerticalOffset = round(kEvstTagViewVerticalPadding + kEvstTagViewVerticalPadding / 2.f);
  
  // Loop through the tags and position/add them to the view
  for (EvstTagView *tagView in self.tagViews) {
    CGRect tagFrame = tagView.frame;
    
    if (CGRectIsNull(frameOfLastTag)) {
      // First tag
      tagFrame.origin.x = self.leftPadding;
      tagFrame.origin.y = tagVerticalOffset;
    } else {
      // Check if the next tag will fit on the current line
      CGFloat width = tagFrame.size.width + 2 * kEvstTagViewHorizontalPadding;
      BOOL roomForTag = self.frame.size.width - frameOfLastTag.origin.x - frameOfLastTag.size.width - width >= 0;
      if (roomForTag) {
        // Add it to the same Line
        tagFrame.origin.x = frameOfLastTag.origin.x + frameOfLastTag.size.width + kEvstTagViewHorizontalPadding;
        tagFrame.origin.y = frameOfLastTag.origin.y;
      } else {
        // Add it to the next line
        lineCount++;
        tagFrame.origin.x = kEvstTagViewHorizontalPadding;
        tagFrame.origin.y = frameOfLastTag.origin.y + frameOfLastTag.size.height + tagVerticalOffset;
      }
    }
    frameOfLastTag = tagFrame;
    tagView.frame = tagFrame;
    
    // Add tag if it hasn't already been added (e.g. we are either repositioning or adding tags)
    if (!tagView.superview) {
      [self.scrollView addSubview:tagView];
    }
  }
  
  // Now add the text field
  CGRect textFieldFrame;
  CGFloat textFieldHeight = round(self.tagHeight + kEvstTagViewVerticalPadding);
  if (CGRectIsNull(frameOfLastTag)) {
    // No tags yet
    textFieldFrame = CGRectMake(self.leftPadding, kEvstTagViewVerticalPadding + 1.f, self.frame.size.width - self.leftPadding - kEvstTagViewHorizontalPadding, textFieldHeight);
  } else {
    // Add the text field after the tags
    CGFloat minWidth = kEvstTagsFieldMinimumWidth + 2 * kEvstTagViewHorizontalPadding;
    textFieldHeight = round(self.tagHeight + kEvstTagViewVerticalPadding);
    textFieldFrame = CGRectMake(0, 0, MAX(kEvstTagsFieldMinimumWidth, self.tagsField.frame.size.width), textFieldHeight);
    
    // Check if we can add the text field on the same line as the last tag view
    BOOL roomForTextField = self.frame.size.width - kEvstTagViewHorizontalPadding - frameOfLastTag.origin.x - frameOfLastTag.size.width - minWidth >= 0;
    if (roomForTextField) {
      // Place it on the same line
      textFieldFrame.origin.x = frameOfLastTag.origin.x + frameOfLastTag.size.width + kEvstTagViewHorizontalPadding;
      textFieldFrame.size.width = self.frame.size.width - textFieldFrame.origin.x;
      textFieldFrame.origin.y = round(frameOfLastTag.origin.y - kEvstTagViewVerticalPadding / 2.f);
    } else {
      // Place it on the next line
      lineCount ++;
      
      textFieldFrame.origin.x = kEvstTagViewHorizontalPadding;
      textFieldFrame.size.width = self.frame.size.width - 2 * kEvstTagViewHorizontalPadding;
      textFieldFrame.origin.y = frameOfLastTag.origin.y + frameOfLastTag.size.height + tagVerticalOffset;
    }
  }
  
  // Position the text field
  self.tagsField.frame = textFieldFrame;
  
  // Check if we need a placeholder or not
  self.tagsField.placeholder = self.tagViews.count ? @"" : kLocaleTagsPlaceholder;
  
  // Update tags count
  NSInteger remainingTags =  MAX(0, kEvstTotalAllowableTagsCount - self.tagViews.count);
  self.tagsCount.text = self.tagsCount.accessibilityValue = [NSString stringWithFormat:@"%lu", remainingTags];
  self.tagsCount.textColor = remainingTags <= 2 ? kColorRed : kColorBlack;
  
  // Add the text field if it hasn't already been added
  if (!self.tagsField.superview) {
    [self.scrollView addSubview:self.tagsField];
  }
  
  // Adjust frame of the container view if necessary
  if (changingTag) {
    // Set the scroll view content size which can be bigger than the container frame size
    CGFloat newHeight = self.tagsField.frame.origin.y + self.tagsField.frame.size.height + tagVerticalOffset;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, newHeight);
    
    // Calculate the container frame size
    CGFloat maxFrameHeight = round(4 * self.tagHeight);
    newHeight = (newHeight > maxFrameHeight) ? maxFrameHeight : MAX(kEvstTagsPickerHeight, newHeight);
    if (self.tagsContainer.frame.size.height != newHeight) {
      [self layoutIfNeeded];
      
      [UIView animateWithDuration:0.2f animations:^{
        self.heightConstraint.constant = newHeight;
        [self layoutIfNeeded];
      }];
    }
  }
}

- (CGFloat)leftPadding {
  return kEvstTagViewHorizontalPadding + CGRectGetMaxX(self.tagsCount.frame);
}

- (CGFloat)lineHeight {
  return self.tagsField.font.lineHeight;
}

- (CGFloat)tagHeight {
  return [EvstTagView tagHeight];
}

#pragma mark - Notifications

- (void)registerShowNotifications {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)unregisterShowNotifications {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)registerNotifications {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregisterNotifications {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
  if (![notification.name isEqualToString:UIKeyboardWillShowNotification]) {
    return;
  }

  double duration = [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    // Cache the height constraint before we enter the animation block
    // Otherwise iOS 8 has a hard time handling enumerating the constraints array in the block
    self.heightConstraint = self.heightConstraint;
    
    [self animateTagsViewIntoView];
  });
}

- (void)keyboardWillHide:(NSNotification *)notification {
  if (![notification.name isEqualToString:UIKeyboardWillHideNotification]) {
    return;
  }
  [self unregisterShowNotifications];
}

#pragma mark - Animations

- (NSLayoutConstraint *)heightConstraint {
  if (_heightConstraint) {
    return _heightConstraint;
  }
  
  NSLayoutConstraint *heightConstraint;
  for (NSLayoutConstraint *constraint in self.tagsContainer.constraints) {
    if (constraint.firstAttribute == NSLayoutAttributeHeight) {
      heightConstraint = constraint;
      break;
    }
  }
  _heightConstraint = heightConstraint;
  return _heightConstraint;
}

- (void)animateFromView:(UIView *)view withKeyboardShowing:(BOOL)keyboardIsShowing {
  [self registerShowNotifications];
  
  self.isShowing = YES;
  self.isDismissing = NO;
  
  self.animatingFromView = view;
  [view.superview insertSubview:self belowSubview:view];
  
  // If the keyboard isn't showing yet, the keyboard notification will take care of animations
  if (keyboardIsShowing) {
    [self animateTagsViewIntoView];
  }
  [self selectTagsField];
}

- (void)animateTagsViewIntoView {
  [self layoutIfNeeded];
  
  [CATransaction begin];
  [CATransaction setCompletionBlock:^{
    [self addAllTagsToView];
    
    [UIView animateWithDuration:0.3 animations:^{
      self.scrollView.alpha = 1.f;
    } completion:^(BOOL finished) {
      self.tagsField.hidden = NO;
    }];
  }];
  
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:0.3];
  [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
  [UIView setAnimationBeginsFromCurrentState:YES];
  self.heightConstraint.constant = kEvstTagsPickerHeight;
  self.bottomConstraint.offset = self.animatingFromView.frame.origin.y - self.tagsContainer.frame.origin.y;
  [self layoutIfNeeded];
  
  self.modalBackgroundView.alpha = 0.2f;
  [UIView commitAnimations];
  [CATransaction commit];
}

- (void)dismiss {
  self.isDismissing = YES;
  
  // Check if we need to add a tag before dismissing
  [self addTagFromTextFieldIfPossible];
  
  [self layoutIfNeeded];
  [UIView animateWithDuration:0.15 animations:^{
    self.modalBackgroundView.alpha = 0.f;
    self.heightConstraint.constant = 0.f;
    self.bottomConstraint.offset = 0.f;
    [self layoutIfNeeded];
  } completion:^(BOOL finished) {
    [self removeFromSuperview];
    self.scrollView.alpha = 0.f;
    self.isShowing = NO;
    if (self.dismissHandler) {
      self.dismissHandler(self.tags);
    }
    
    // Unselect the selected tag
    if (self.selectedTagView) {
      [self.selectedTagView unSelect];
    }
  }];
}

#pragma mark - Adding / Removing Tags

- (void)addAllTagsToView {
  NSOrderedSet *existingTags = [self.tags copy];
  for (NSString *tagName in existingTags) {
    [self addTagNamed:tagName];
  }
  [self layoutViewForTagChangeAndScrollToBottom];
}

- (void)addTagNamed:(NSString *)tagName {
  // Ensure tags are always lowercase for consistency and uniqueness
  NSString *downcasedTag = [tagName lowercaseString];
  // Limit all added (and pasted) tags to the max character count
  downcasedTag = (downcasedTag.length <= kEvstTagsMaximumCharacterCount) ? downcasedTag : [downcasedTag substringToIndex:kEvstTagsMaximumCharacterCount];
  
  if ([self tagViewForTagNamed:downcasedTag]) {
    return;
  }
  
  self.tagsField.text = @"";
  EvstTagView *tagView = [[EvstTagView alloc] initWithTagName:downcasedTag];
  tagView.delegate = self;
  
  // Update datasource
  [self.tags addObject:downcasedTag];
  [self.tagViews addObject:tagView];
}

- (void)layoutViewForTagChangeAndScrollToBottom {
  // Refresh the layout
  [self layoutViewForTagChange:YES];
  
  // Scroll to bottom
  self.shouldSelectTagsField = YES;
  [self scrollToBottomWithAnimation:YES];
  // Note: After scroll animation [self selectTagsField] will be called
}

- (void)removeTagView:(EvstTagView *)tagView {
  [tagView removeFromSuperview];

  // Remove tag from datasource
  [self.tags removeObject:tagView.name];
  [self.tagViews removeObject:tagView];
  
  // Refresh the layout
  [self layoutViewForTagChange:YES];
  
  [self selectTagsField];
  self.tagsField.text = @"";
  
  [self scrollToBottomWithAnimation:NO];
}

- (EvstTagView *)tagViewForTagNamed:(NSString *)tagName {
  return [self.tagViews filteredOrderedSetUsingPredicate:[NSPredicate predicateWithFormat:@"name = %@", tagName]].firstObject;
}

- (void)handledPastedTagsWithString:(NSString *)string {
  // First, how many available tags do we have left to add
  NSInteger availableTags = MAX(0, kEvstTotalAllowableTagsCount - self.tagViews.count);
  NSInteger tagsAdded = 0;
  
  // Break up the string based on spaces and newlines
  NSArray *firstPass = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  // Now join that array by commas so we can then break it up again by commas
  NSString *commaSeparatedTags = [firstPass componentsJoinedByString:@","];
  
  // Now break the string up by commas
  NSArray *secondPass = [commaSeparatedTags componentsSeparatedByString:@","];
  
  // Iterate over the tags and sanitize them
  NSMutableArray *finalPass = [[NSMutableArray alloc] init];
  NSCharacterSet *nonAlphaNumericCharacters = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
  for (NSString *potentialTag in secondPass) {
    // Only add as many tags as we have available
    if (availableTags <= tagsAdded) {
      break;
    }
    
    // Remove all non-alphanumeric characters
    NSString *sanitizedPotentialTag = [[potentialTag componentsSeparatedByCharactersInSet:nonAlphaNumericCharacters] componentsJoinedByString:@""];
    if (sanitizedPotentialTag.length) {
      [finalPass addObject:sanitizedPotentialTag];
      tagsAdded += 1;
    }
  }
  
  for (NSString *newTag in finalPass) {
    [self addTagNamed:newTag];
    [self layoutViewForTagChangeAndScrollToBottom];
  }
}

#pragma mark - Helper Methods

- (void)selectTagsField {
  self.tagsField.hidden = NO;
  [self.tagsField becomeFirstResponder];
}

- (void)scrollToBottomWithAnimation:(BOOL)animated {
  CGSize size = self.scrollView.contentSize;
  CGRect frame = CGRectMake(0, size.height - self.scrollView.frame.size.height, size.width, self.scrollView.frame.size.height);
  [self.scrollView scrollRectToVisible:frame animated:animated];
}

- (void)addTagFromTextFieldIfPossible {
  if ([self hasReachedTagLimit]) {
    return; // This is just here as a sanity check
  }
  
  // Only allow alphanumeric characters
  NSCharacterSet *nonAlphaNumericCharacters = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
  NSString *tagName = [[self.tagsField.text componentsSeparatedByCharactersInSet:nonAlphaNumericCharacters] componentsJoinedByString:@""];
  tagName = [tagName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  if (tagName.length) {
    [self addTagNamed:tagName];
    [self layoutViewForTagChangeAndScrollToBottom];
  } else {
    self.tagsField.text = @"";
  }
}

- (NSString *)sanitizeTagText:(NSString *)text {
  NSCharacterSet *nonAlphaNumericCharacters = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
  NSString *tagName = [[text componentsSeparatedByCharactersInSet:nonAlphaNumericCharacters] componentsJoinedByString:@""];
  return [tagName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (BOOL)hasReachedTagLimit {
  return self.tagViews.count >= kEvstTotalAllowableTagsCount;
}

#pragma mark - IBActions

- (IBAction)didTapOrSwipeToDismiss:(id)sender {
  [self dismiss];
}

#pragma mark - EvstTagsTextFieldDelegate 

- (void)textFieldDidHitBackspaceWithEmptyText:(EvstTagsTextField *)textField {
  self.tagsField.hidden = NO;
  
  if (self.tags.count) {
    // Capture "delete" key press when cell is empty
    self.selectedTagView = [self.tagViews lastObject];
    [self.selectedTagView select];
  }
}

- (void)textFieldDidChange:(EvstTagsTextField *)textField {
  if ([self hasReachedTagLimit]) {
    textField.text = @"";
    return;
  }
  
  CGPoint offset = self.scrollView.contentOffset;
  offset.y = self.scrollView.contentSize.height - self.scrollView.frame.size.height;
  if (offset.y > self.scrollView.contentOffset.y){
    [self scrollToBottomWithAnimation:YES];
  }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  // Set a maximum number of tags that can be added
  BOOL wasDeleteKey = range.location == 0 && string.length == 0;
  if ([self hasReachedTagLimit] && wasDeleteKey == NO) {
    return NO;
  }
  
  BOOL containsTriggerString = [string rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]].location != NSNotFound || [string rangeOfString:@","].location != NSNotFound;
  
  // Check for tags being pasted (if the replacement string is more than one character)
  // Maximum tag and character counts are enforced in the pasting helper method
  if (string.length > 1 && containsTriggerString) {
    [self handledPastedTagsWithString:string];
    return NO;
  } else if (string.length > 1) {
    // Since no trigger character was found, let's check if we need to trim the pasted text to the max allowable tag length
    textField.text = (string.length <= kEvstTagsMaximumCharacterCount) ? string : [string substringToIndex:kEvstTagsMaximumCharacterCount];
    return NO;
  }

  // Set a maximum tag character count for typed out tags
  if (textField.text.length >= kEvstTagsMaximumCharacterCount && string.length && containsTriggerString == NO) {
    return NO;
  }
  
  // Spaces and commas trigger a new tag creation
  if (containsTriggerString) {
    [self addTagFromTextFieldIfPossible];
    return NO;
  } else {
    return YES;
  }
}

#pragma mark - EvstTagViewDelegate

- (void)tagWasSelected:(EvstTagView *)tagView {
  // Unselect the previously selected tag view
  if (self.selectedTagView) {
    [self.selectedTagView unSelect];
  }
  self.selectedTagView = tagView;
  
  [self.tagsField resignFirstResponder];
  self.tagsField.text = @"";
  self.tagsField.hidden = YES;
}

- (void)tagWasUnSelected:(EvstTagView *)tagView {
  [self selectTagsField];
  self.tagsField.text = @"";
}

- (void)tagShouldBeRemoved:(EvstTagView *)tagView {
  [self removeTagView:tagView];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
  if (self.shouldSelectTagsField) {
    self.shouldSelectTagsField = NO;
    [self selectTagsField];
  }
}

@end
