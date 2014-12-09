//
//  EvstLifecycleContentView.m
//  Everest
//
//  Created by Chris Cornelis on 03/07/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstLifecycleContentView.h"
#import "NSString+EvstAdditions.h"

@interface EvstLifecycleContentView ()
@property (nonatomic, strong) TTTAttributedLabel *lifecycleTextLabel;
@property (nonatomic, strong) EvstAttributedLabel *journeyNameLabel;
@property (nonatomic, strong) TTTAttributedLabel *findOnTheWebLabel;
@end

@implementation EvstLifecycleContentView

#pragma mark - EvstMomentCellContentViewProtocol

- (void)setupView {
  self.lifecycleTextLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(kEvstMomentContentPadding, 10.f, kEvstMainScreenWidth - 2 * kEvstMomentContentPadding, 16.f)];
  self.lifecycleTextLabel.font = kFontHelveticaNeueLight12;
  self.lifecycleTextLabel.textAlignment = NSTextAlignmentCenter;
  self.lifecycleTextLabel.textColor = kColorBlack;
  [self addSubview:self.lifecycleTextLabel];

  self.journeyNameLabel = [[EvstAttributedLabel alloc] initWithFrame:CGRectZero];
  self.journeyNameLabel.font = kFontHelveticaNeueBold12;
  self.journeyNameLabel.textAlignment = NSTextAlignmentCenter;
  self.journeyNameLabel.textColor = kColorBlack;
  self.journeyNameLabel.numberOfLines = 0;
  self.journeyNameLabel.delegate = self;
  self.journeyNameLabel.activeLinkAttributes = nil; // Don't change link appearance when tapped
  self.journeyNameLabel.inactiveLinkAttributes = nil;
  NSMutableParagraphStyle *attributeStyle = [[NSMutableParagraphStyle alloc] init];
  attributeStyle.alignment = NSTextAlignmentCenter;
  NSDictionary *journeyNameAttributes = @{(id)kCTForegroundColorAttributeName : kColorBlack,
                                          (id)kCTUnderlineStyleAttributeName : [NSNumber numberWithInt:kCTUnderlineStyleNone],
                                          (NSString *)kCTFontAttributeName: (id)kFontHelveticaNeueBold12,
                                          (NSString *)kCTParagraphStyleAttributeName:attributeStyle};
  self.journeyNameLabel.linkAttributes = self.journeyNameLabel.inactiveLinkAttributes = journeyNameAttributes;
  [self addSubview:self.journeyNameLabel];
  [self.journeyNameLabel makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(@25);
    make.left.equalTo(self.lifecycleTextLabel);
    make.right.equalTo(self.lifecycleTextLabel);
  }];
  
  self.findOnTheWebLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
  self.findOnTheWebLabel.textColor = kColorGray;
  self.findOnTheWebLabel.font = kFontHelveticaNeueLight11;
  self.findOnTheWebLabel.textAlignment = NSTextAlignmentCenter;
  self.findOnTheWebLabel.activeLinkAttributes = nil; // Don't change link appearance when tapped
  self.findOnTheWebLabel.linkAttributes = @{NSForegroundColorAttributeName : kColorTeal, NSUnderlineStyleAttributeName : @NO};
  self.findOnTheWebLabel.inactiveLinkAttributes = @{(id)kCTForegroundColorAttributeName : [UIColor grayColor]};
  self.findOnTheWebLabel.delegate = self;
  self.findOnTheWebLabel.accessibilityLabel = kLocaleFindItOnTheWebAt;
  [self addSubview:self.findOnTheWebLabel];
  [self.findOnTheWebLabel makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.journeyNameLabel.bottom).offset(5.f);
    make.left.equalTo(self.lifecycleTextLabel);
    make.right.equalTo(self.lifecycleTextLabel);
    make.height.equalTo(@12);
  }];
}

- (void)configureWithMoment:(EverestMoment *)moment withOptions:(EvstMomentViewOptions)options {
  self.moment = moment; // Needed for double-tap to like
  
  // Lifecycle text
  NSString *lifecycleString = [NSString stringWithFormat:kLocaleDidSomethingTheirJourney, [self lifecycleEventFromName:moment.name]];
  [self.lifecycleTextLabel setText:lifecycleString];
  self.lifecycleTextLabel.accessibilityLabel = lifecycleString;
  
  // Journey name
  self.journeyNameLabel.journey = moment.journey;
  [self.journeyNameLabel setText:moment.journey.name];
  NSURL *journeyURL = [EvstCommon destinationURLWithType:kEvstURLJourneyPathComponent uuid:moment.journey.uuid];
  [self.journeyNameLabel addLinkToURL:journeyURL withRange:NSMakeRange(0, moment.journey.name.length)];
  
  if (moment.journey.isPrivate || !moment.webURL) {
    self.findOnTheWebLabel.hidden = YES;
  } else {
    // Web link
    NSString *linkWithoutHTTP = [moment.webURL stringByRemovingHTTPOrHTTPSPrefixes];
    [self.findOnTheWebLabel setText:[NSString stringWithFormat:@"%@ %@", kLocaleFindItOnTheWebAt, linkWithoutHTTP]];
    [self.findOnTheWebLabel addLinkToURL:[NSURL URLWithString:moment.webURL] withRange:NSMakeRange(kLocaleFindItOnTheWebAt.length + 1, linkWithoutHTTP.length)];
  }
}

- (NSString *)lifecycleEventFromName:(NSString *)momentName {
  if ([momentName isEqualToString:kEvstStartedJourneyMomentType]) {
    return kLocaleLifecycleStarted;
  } else if ([momentName isEqualToString:kEvstAccomplishedJourneyMomentType]) {
    return kLocaleLifecycleAccomplished;
  } else if ([momentName isEqualToString:kEvstReopenedJourneyMomentType]) {
    return kLocaleLifecycleReopened;
  }
  return nil;
}

- (void)prepareForReuse {
  self.lifecycleTextLabel.text = nil;
  self.journeyNameLabel.text = nil;
  self.findOnTheWebLabel.text = nil;
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(EvstAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
  if ([url.scheme hasPrefix:[EvstEnvironment evstURLScheme]]) {
    [[NSNotificationCenter defaultCenter] postNotificationName:kEvstDidPressJourneyURLNotification object:label.journey];
  } else {
    [[NSNotificationCenter defaultCenter] postNotificationName:kEvstDidPressHTTPURLNotification object:url.absoluteString];
  }
}

@end
