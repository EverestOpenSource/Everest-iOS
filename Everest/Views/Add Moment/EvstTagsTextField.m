//
//  EvstTagsTextField.m
//  Everest
//
//  Created by Rob Phillips on 6/2/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstTagsTextField.h"

@implementation EvstTagsTextField

- (id)init {
  self = [super init];
  if (self) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    self.accessibilityLabel = kLocaleTagsTextField;
    self.font = kFontAddMomentTags;
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  self.delegate = nil;
}

- (void)deleteBackward {
  BOOL isTextFieldEmpty = (self.text.length == 0);
  if (isTextFieldEmpty) {
    if ([self.delegate respondsToSelector:@selector(textFieldDidHitBackspaceWithEmptyText:)]) {
      [self.delegate textFieldDidHitBackspaceWithEmptyText:self];
    }
  }
  [super deleteBackward];
}

- (void)textFieldTextDidChange:(NSNotification *)notification {
  if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldDidChange:)]) {
    [self.delegate textFieldDidChange:self];
  }
}

@end
