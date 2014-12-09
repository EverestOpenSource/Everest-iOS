//
//  EvstMomentCellTagsView.m
//  Everest
//
//  Created by Rob Phillips on 6/17/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMomentCellTagsView.h"

@interface EvstMomentCellTagsView ()
@property (nonatomic, strong) UIImageView *tagsIcon;
@property (nonatomic, strong) TTTAttributedLabel *tagsLabel;
@end

@implementation EvstMomentCellTagsView

#pragma mark - EvstMomentCellContentViewProtocol

- (void)setupView {
  self.tagsIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Tiny Tag"]];
  self.tagsIcon.contentMode = UIViewContentModeScaleAspectFit;
  self.tagsIcon.frame = CGRectMake(kEvstMomentCellTagsViewIconLeftPadding, 5.f, kEvstMomentCellTagsViewIconWidth, 12.f);
  [self addSubview:self.tagsIcon];
  
  UIView *superview = self;
  self.tagsLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
  self.tagsLabel.delegate = self;
  self.tagsLabel.activeLinkAttributes = nil; // Don't change link appearance when tapped
  self.tagsLabel.linkAttributes = @{(id)kCTForegroundColorAttributeName : kColorGray,
                                    (id)kCTUnderlineStyleAttributeName : [NSNumber numberWithInt:kCTUnderlineStyleNone] };
  self.tagsLabel.inactiveLinkAttributes = @{(id)kCTForegroundColorAttributeName : kColorGray};
  self.tagsLabel.lineBreakMode = NSLineBreakByWordWrapping;
  self.tagsLabel.numberOfLines = 0;
  self.tagsLabel.lineHeightMultiple = kEvstMomentTagLineHeightMultiple;
  self.tagsLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
  self.tagsLabel.font = kFontMomentTag;
  self.tagsLabel.textColor = kColorGray;
  [self addSubview:self.tagsLabel];
  [self.tagsLabel makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo([NSNumber numberWithDouble:[EvstMomentCellTagsView leftContentMargin]]);
    make.width.equalTo([NSNumber numberWithDouble:[EvstMomentCellTagsView contentWidth]]);
    make.top.equalTo(superview.top);
    make.bottom.equalTo(superview.bottom);
  }];
}

- (void)configureWithMoment:(EverestMoment *)moment withOptions:(EvstMomentViewOptions)options {
  if (moment.tags.count == 0) {
    return;
  }
  self.moment = moment;
  
  NSUInteger count = moment.tags.count;
  if (options & EvstMomentExpandToShowAllTags) {
    // Show all tags
    NSArray *tagsArray = moment.tags.array;
    NSString *allTags = [EvstMomentCellTagsView stringByJoiningTags:tagsArray];
    [self.tagsLabel setText:allTags];
    for (NSString *tag in tagsArray) {
      NSURL *tagSearchURL = [EvstCommon destinationURLWithType:kEvstURLTagPathComponent string:tag];
      NSRange tagRange = [allTags rangeOfString:tag];
      [self.tagsLabel addLinkToURL:tagSearchURL withRange:NSMakeRange(tagRange.location, tagRange.length)];
    }
  } else {
    BOOL showMoreCount = count > 1;
    NSString *tag = moment.tags.firstObject;
    if (showMoreCount) {
      // Show the first tag + count of remaining (e.g. #hikefurther +3 more)
      NSString *countString = [NSString stringWithFormat:kLocaleTagsMoreCount, count - 1];
      NSString *labelText = [NSString stringWithFormat:@"%@%@%@", tag, kEvstMomentTagSpacing, countString];
      NSURL *expandTagURL = [EvstCommon destinationURLWithType:kEvstURLExpandTagsPathComponent uuid:moment.uuid];
      NSRange countRange = [labelText rangeOfString:countString];
      [self.tagsLabel setText:labelText afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(id)kFontMomentTagMore range:countRange];
        return mutableAttributedString;
      }];
      [self.tagsLabel addLinkToURL:expandTagURL withRange:NSMakeRange(countRange.location, countRange.length)];
    } else {
      // Show the only tag
      [self.tagsLabel setText:tag];
    }
    NSURL *tagSearchURL = [EvstCommon destinationURLWithType:kEvstURLTagPathComponent string:tag];
    [self.tagsLabel addLinkToURL:tagSearchURL withRange:NSMakeRange(0, tag.length)];
  }
}

- (void)prepareForReuse {
  self.tagsLabel.text = self.tagsLabel.accessibilityLabel = nil;
  self.moment = nil;
}

#pragma mark TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
  if ([url.absoluteString rangeOfString:kEvstURLExpandTagsPathComponent].location != NSNotFound) {
    [[NSNotificationCenter defaultCenter] postNotificationName:kEvstDidPressExpandTagsURLNotification object:self.moment];
  } else {
    NSString *tag = [url.absoluteString componentsSeparatedByString:@"/"].lastObject;
    [[NSNotificationCenter defaultCenter] postNotificationName:kEvstDidPressTagSearchURLNotification object:tag];
  }
}

#pragma mark Full Tags String

+ (NSString *)stringByJoiningTags:(NSArray *)tags {
  return [tags componentsJoinedByString:kEvstMomentTagSpacing];
}

#pragma mark - Calculations

+ (CGFloat)leftContentMargin {
  return kEvstMomentCellTagsViewIconLeftPadding + kEvstMomentCellTagsViewIconWidth + kEvstDefaultPadding;
}

+ (CGFloat)contentWidth {
  return kEvstMainScreenWidth - [self leftContentMargin] - kEvstDefaultPadding;
}

@end
