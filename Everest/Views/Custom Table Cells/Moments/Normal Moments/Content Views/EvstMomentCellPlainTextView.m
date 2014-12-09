//
//  EvstMomentCellPlainTextView.m
//  Everest
//
//  Created by Rob Phillips on 1/15/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMomentCellPlainTextView.h"
#import "EverestJourney.h"
#import "EvstMomentCellBase.h"

@implementation EvstMomentCellPlainTextView

#pragma mark - EvstMomentCellContentViewProtocol

- (void)setupView {
  self.momentContentLabel = [[EvstAttributedLabel alloc] initWithFrame:CGRectZero];
  self.momentContentLabel.delegate = self;
  self.momentContentLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
  self.momentContentLabel.activeLinkAttributes = nil; // Don't change link appearance when tapped
  self.momentContentLabel.font = kFontMomentContent;
  self.momentContentLabel.textColor = kColorBlack;
  self.momentContentLabel.linkAttributes = @{(id)kCTForegroundColorAttributeName : kColorTeal,
                                             (id)kCTUnderlineStyleAttributeName : [NSNumber numberWithInt:kCTUnderlineStyleNone] };
  self.momentContentLabel.inactiveLinkAttributes = @{(id)kCTForegroundColorAttributeName : [UIColor grayColor]};
  self.momentContentLabel.lineBreakMode = NSLineBreakByWordWrapping;
  self.momentContentLabel.numberOfLines = 0;
  self.momentContentLabel.lineHeightMultiple = kEvstMomentPlainTextLineHeightMultiple;
  [self constrainMomentContentLabel];
}

- (void)configureWithMoment:(EverestMoment *)moment withOptions:(EvstMomentViewOptions)options {
  ZAssert(moment, @"Moment must not be nil when we try to populate a cell with it");
  self.moment = moment;
  
  BOOL shouldAddJourneyName = options & EvstMomentShownWithJourneyName;
  if (shouldAddJourneyName == NO) {
    [self.momentContentLabel setText:self.moment.name];
    self.momentContentLabel.accessibilityLabel = self.moment.name;
    return;
  }
  
  // Else, we should add the journey name to the end
  
  // Moment content
  NSString *momentContent = self.moment.name;
  BOOL momentHasContent = momentContent.length != 0;
  NSRange momentContentRange = NSMakeRange(0, momentContent.length);
  
  NSUInteger whitespaceLength = 1;
  
  // "in" substring
  NSString *inJourneyName = [EvstMomentCellBase inJourneyNameForMoment:self.moment];
  NSRange inRangeInSubstring = [inJourneyName rangeOfString:kLocaleIn];
  NSUInteger inLocationModifier = momentHasContent ? whitespaceLength : 0; // explicit for clarity
  NSRange inRange = NSMakeRange(momentContentRange.location + momentContentRange.length + inLocationModifier, inRangeInSubstring.length);
  
  // "Journey Name" substring
  NSRange journeyNameRangeInSubstring = [inJourneyName rangeOfString:self.moment.journey.name];
  NSRange journeyNameRange = NSMakeRange(inRange.location + inRange.length + whitespaceLength, journeyNameRangeInSubstring.length);
  
  NSString *momentWithJourneyName;
  if (momentHasContent) {
    momentWithJourneyName = [NSString stringWithFormat:@"%@ %@", momentContent, inJourneyName];
  } else {
    momentWithJourneyName = inJourneyName;
  }
  
  [self.momentContentLabel setText:momentWithJourneyName afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
    [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)kColorGray.CGColor range:inRange];
    return mutableAttributedString;
  }];

  // Journey link
  NSURL *journeyURL = [EvstCommon destinationURLWithType:kEvstURLJourneyPathComponent uuid:self.moment.journey.uuid];
  [self.momentContentLabel addLinkToURL:journeyURL withRange:journeyNameRange];
  self.momentContentLabel.journey = self.moment.journey;
  
  self.momentContentLabel.accessibilityLabel = momentWithJourneyName;
}

#pragma mark - Prepare For Reuse

- (void)prepareForReuse {
  self.moment = nil;
  self.momentContentLabel.text = self.momentContentLabel.accessibilityLabel = nil;
  self.momentContentLabel.journey = nil;
}

#pragma mark TTTAttributedLabelDelegate

- (void)attributedLabel:(EvstAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
  if ([url.scheme hasPrefix:[EvstEnvironment evstURLScheme]]) {
    [[NSNotificationCenter defaultCenter] postNotificationName:kEvstDidPressJourneyURLNotification object:label.journey];
  } else {
    [[NSNotificationCenter defaultCenter] postNotificationName:kEvstDidPressHTTPURLNotification object:url.absoluteString];
  }
}

#pragma mark - Convenience Methods

- (void)constrainMomentContentLabel {
  UIView *superview = self;
  [superview addSubview:self.momentContentLabel];
  [self.momentContentLabel makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(superview.top);
    make.left.equalTo(superview.left).offset(kEvstMomentContentPadding);
    make.right.equalTo(superview.right).offset(-kEvstMomentContentPadding);
    make.bottom.equalTo(superview.bottom);
  }];
}

@end
