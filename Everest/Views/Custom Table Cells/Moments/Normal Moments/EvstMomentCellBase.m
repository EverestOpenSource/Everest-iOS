//
//  EvstMomentCellBase.m
//  Everest
//
//  Created by Rob Phillips on 1/13/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstMomentCellBase.h"
#import "EvstCellCache.h"
#import "EvstMomentCellTagsView.h"
#import "EvstMomentCellLikesCommentsView.h"
#import "EvstMomentCellDeletedOverlayView.h"
#import "EvstMomentCellEditorsPickView.h"

static CGFloat const kEvstEditorsPickContentAreaHeight = 25.f;

@interface EvstMomentCellBase ()
@property (nonatomic, strong) EvstMomentCellEditorsPickView *editorsPickView;
@property (nonatomic, strong) EvstMomentCellTagsView *cellTagsView;
@property (nonatomic, strong) EvstMomentCellLikesCommentsView *cellLikesCommentsView;
@property (nonatomic, strong) EvstMomentCellDeletedOverlayView *deletedCellOverlay;
@property (nonatomic, strong) MASConstraint *userHeaderYConstraint;
@end

@implementation EvstMomentCellBase

#pragma mark - Class Init

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    [self commonSetup];
  }
  return self;
}

#pragma mark - Setup

- (void)commonSetup {
  self.opaque = YES;
  self.backgroundColor = kColorWhite;
  self.selectionStyle = UITableViewCellSelectionStyleNone;
  self.layer.shouldRasterize = YES;
  self.layer.rasterizationScale = [UIScreen mainScreen].scale;
  self.contentView.accessibilityLabel = kLocaleMomentTableCell;
  
  [self setupEditorsPickView];
  [self setupHeaderView];
  [self setupTagsView];
  [self setupContentView];
  [self setupFooterView];
  [self setupDoubleTapToLike];
  [self setupSpotlightGesture];
}

- (void)setupEditorsPickView {
  self.editorsPickView = [[EvstMomentCellEditorsPickView alloc] init];
  [self.contentView addSubview:self.editorsPickView];
  [self.editorsPickView makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.contentView.top);
    make.left.equalTo(self.contentView.left);
    make.right.equalTo(self.contentView.right);
    make.height.equalTo([NSNumber numberWithFloat:kEvstEditorsPickContentAreaHeight]);
  }];
  self.editorsPickView.accessibilityLabel = kLocaleEditorsPick;
  self.editorsPickView.hidden = YES;
}

- (void)setupHeaderView {
  self.cellHeaderView = [[EvstSharedCellUserHeaderView alloc] init];
  [self.contentView addSubview:self.cellHeaderView];
  [self.cellHeaderView makeConstraints:^(MASConstraintMaker *make) {
    // The top constraint is set in the configure method based on whether it's an editor's pick or not
    make.left.equalTo(self.contentView.left);
    make.right.equalTo(self.contentView.right);
    make.height.equalTo([NSNumber numberWithDouble:kEvstSharedCellUserHeaderViewHeight]);
  }];
}

- (void)setupTagsView {
  self.cellTagsView = [[EvstMomentCellTagsView alloc] init];
  [self.contentView addSubview:self.cellTagsView];
  [self.cellTagsView makeConstraints:^(MASConstraintMaker *make) {
    make.bottom.equalTo(self.contentView.bottom).offset(-(kEvstMomentLikesCommentsViewHeight + kEvstMomentContentPadding + 2.f)).priorityHigh();
    make.left.equalTo(self.contentView.left);
    make.right.equalTo(self.contentView.right);
  }];
}

- (void)setupContentView {
  self.cellContentView = [self contentViewInstance];
  [self.contentView addSubview:self.cellContentView];
  [self.cellContentView makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.cellHeaderView.bottom).offset(-kEvstDefaultPadding);
    make.left.equalTo(self.contentView.left);
    make.right.equalTo(self.contentView.right);
  }];
}

- (id)contentViewInstance {
  ZAssert(NO, @"Subclasses should override this method and provide their own implementation.");
  return nil;
}

- (void)setupFooterView {
  self.cellLikesCommentsView = [[EvstMomentCellLikesCommentsView alloc] init];
  [self.contentView addSubview:self.cellLikesCommentsView];
  [self.cellLikesCommentsView makeConstraints:^(MASConstraintMaker *make) {
    make.bottom.equalTo(self.contentView.bottom);
    make.left.equalTo(self.contentView.left);
    make.right.equalTo(self.contentView.right);
    make.height.equalTo([NSNumber numberWithDouble:kEvstMomentLikesCommentsViewHeight]);
  }];
}

- (void)setupBottomSeparator {
  UIImageView *bottomSeparator = [[UIImageView alloc] initWithImage:[EvstCommon tableSeparatorLine]];
  [self.contentView addSubview:bottomSeparator];
  [bottomSeparator makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.contentView.left);
    make.right.equalTo(self.contentView.right);
    make.bottom.equalTo(self.contentView.bottom);
    make.height.equalTo([NSNumber numberWithFloat:0.5f]);
  }];
}

- (void)setupDoubleTapToLike {
  UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
  tapGesture.numberOfTapsRequired = 2;
  tapGesture.cancelsTouchesInView = YES;
  tapGesture.delaysTouchesBegan = YES;
  [self.contentView addGestureRecognizer:tapGesture];
}

- (void)setupSpotlightGesture {
  UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSpotlightGesture:)];
  tapGesture.numberOfTapsRequired = 2;
  tapGesture.numberOfTouchesRequired = 2;
  tapGesture.cancelsTouchesInView = YES;
  tapGesture.delaysTouchesBegan = YES;
  [self.contentView addGestureRecognizer:tapGesture];
}

#pragma mark - Double Tap To Like

- (void)handleDoubleTapGesture:(UITapGestureRecognizer *)sender {
  if (sender.state == UIGestureRecognizerStateRecognized) {
    if (self.cellContentView.moment && self.cellLikesCommentsView.likeButton) {
      NSDictionary *info = @{kEvstDictionaryMomentKey : self.cellContentView.moment,
                             kEvstDictionaryButtonKey : self.cellLikesCommentsView.likeButton,
                             kEvstDictionaryDoubleTapKey : @YES };
      [[NSNotificationCenter defaultCenter] postNotificationName:kEvstLikeButtonWasPressedNotification object:nil userInfo:info];
    }
  }
}

#pragma mark - Spotlighting

- (void)handleSpotlightGesture:(UITapGestureRecognizer *)sender {
  if (sender.state == UIGestureRecognizerStateRecognized && self.cellContentView.moment) {
    [[NSNotificationCenter defaultCenter] postNotificationName:kEvstMomentSpotlightShouldChangeNotification object:self.cellContentView.moment];
  }
}

#pragma mark - Prepare For Reuse

- (void)prepareForReuse {
  [super prepareForReuse];
  
  [self.editorsPickView prepareForReuse];
  self.editorsPickView.hidden = YES;
  [self.cellHeaderView prepareForReuse];
  [self.cellTagsView prepareForReuse];
  [self.cellContentView prepareForReuse];
  [self.cellLikesCommentsView prepareForReuse];
  self.deletedCellOverlay.hidden = YES;
}

#pragma mark - Configurations

- (void)configureWithMoment:(EverestMoment *)moment withOptions:(EvstMomentViewOptions)options {
  // Don't set up an editor's pick area for lifecycle cell types
  if (moment.isLifecycleMoment == NO) {
    // Editor's Pick area (if necessary)
    [self.userHeaderYConstraint uninstall];
    BOOL shouldShowEditorsPick = moment.isEditorsPick && (options & EvstMomentCanShowEditorsPickHeader);
    CGFloat offset = shouldShowEditorsPick ? kEvstEditorsPickContentAreaHeight : 0.f;
    [self.cellHeaderView updateConstraints:^(MASConstraintMaker *make) {
      self.userHeaderYConstraint = make.top.equalTo(self.contentView.top).offset(offset);
    }];
    if (shouldShowEditorsPick) {
      [self.editorsPickView configureWithMoment:moment withOptions:options];
      self.editorsPickView.hidden = NO;
    }
  }
  
  [self.cellHeaderView configureWithMoment:moment withOptions:options];
  [self.cellContentView configureWithMoment:moment withOptions:options];
  
  // Check if there are tags to show
  if (moment.tags.count > 0) {
    [self.cellTagsView configureWithMoment:moment withOptions:options];
    self.cellTagsView.hidden = NO;
  } else {
    self.cellTagsView.hidden = YES;;
  }
  
  [self.cellLikesCommentsView configureWithMoment:moment withOptions:options];
  BOOL forCommentsHeader = options & EvstMomentShownInCommentsHeader;
  if (forCommentsHeader) {
    [self setupBottomSeparator];
  }
  // Since it's not very performant to do this in a configure method,
  // only create the overlay if it hasn't already been created
  if (moment.associatedJourneyWasDeleted && !self.deletedCellOverlay) {
    self.deletedCellOverlay = [[EvstMomentCellDeletedOverlayView alloc] init];
    [self.contentView addSubview:self.deletedCellOverlay];
    [self.deletedCellOverlay makeConstraints:^(MASConstraintMaker *make) {
      make.edges.equalTo(self.contentView);
    }];
  }
  self.deletedCellOverlay.hidden = !moment.associatedJourneyWasDeleted;
}

#pragma mark - Cell Calculations

+ (CGFloat)cellHeightForMoment:(EverestMoment *)moment withOptions:(EvstMomentViewOptions)options fromCacheIfAvailable:(BOOL)fromCache {
  BOOL shouldShowEditorsPick = (moment.isEditorsPick && (options & EvstMomentCanShowEditorsPickHeader));
  CGFloat topPadding = shouldShowEditorsPick ? kEvstEditorsPickContentAreaHeight : 0.f;
  return topPadding + kEvstSharedCellUserHeaderViewHeight + [self heightForContentAreaWithMoment:moment withOptions:options fromCacheIfAvailable:fromCache] + kEvstMomentLikesCommentsViewHeight;
}

+ (CGFloat)heightForContentAreaWithMoment:(EverestMoment *)moment withOptions:(EvstMomentViewOptions)options fromCacheIfAvailable:(BOOL)fromCache {
  CGFloat (^calculateHeight)() = ^CGFloat() {
    CGFloat calculatedHeight = [self calculatedContentHeightForMoment:moment withOptions:options];
    // If we wanted a value from cache but there was none, we should cache the new value.  Otherwise,
    // don't cache calculated values since it's most likely for showing the moment in the comments view
    if (fromCache) {
      [[EvstCellCache sharedCache] cacheCellHeight:calculatedHeight forUUID:moment.uuid withMomentOptions:options];
    }
    return calculatedHeight;
  };
  
  if (fromCache) {
    NSNumber *momentHeight = [[EvstCellCache sharedCache] cachedCellHeightForUUID:moment.uuid withMomentOptions:options];
    if (momentHeight) {
      return [momentHeight floatValue];
    } else {
      return calculateHeight();
    }
  } else {
    return calculateHeight();
  }
}

+ (CGFloat)calculatedContentHeightForMoment:(EverestMoment *)moment withOptions:(EvstMomentViewOptions)options {
  ZAssert(NO, @"Subclasses should override this method and provide their own implementation.");
  return 0.f;
}

#pragma mark - Shared Methods

+ (CGFloat)heightOfTextForMoment:(EverestMoment *)moment withJourneyName:(BOOL)withJourneyName {
  if (!moment.name.length && !withJourneyName) {
    return 0.f;
  }
  
  CGSize constraintSize = CGSizeMake([self cellContentWidth], CGFLOAT_MAX);
  NSString *text = withJourneyName ? [self momentContentWithJourneyNameForMoment:moment] : moment.name;
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  paragraphStyle.lineHeightMultiple = kEvstMomentPlainTextLineHeightMultiple;
  paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
  NSDictionary *attributes = @{NSFontAttributeName : kFontMomentContent, NSParagraphStyleAttributeName : paragraphStyle};
  NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:text attributes:attributes];
  CGSize size = [EvstAttributedLabel sizeThatFitsAttributedString:attrString withConstraints:constraintSize limitedToNumberOfLines:0];
  
  return ceil(size.height + kEvstMomentContentBottomMargin);
}

+ (CGFloat)heightOfTagsForMoment:(EverestMoment *)moment shownExpanded:(BOOL)showExpanded {
  if (moment.tags.count == 0) {
    return 0.f;
  } else if (moment.tags.count == 1 || showExpanded == NO) {
    return kEvstMomentTagAreaDefaultHeight;
  } else if (showExpanded) {
    CGSize constraintSize = CGSizeMake([EvstMomentCellTagsView contentWidth], CGFLOAT_MAX);
    NSString *text = [EvstMomentCellTagsView stringByJoiningTags:moment.tags.array];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineHeightMultiple:kEvstMomentTagLineHeightMultiple];
    NSDictionary *attributes = @{NSFontAttributeName : kFontMomentTag, NSParagraphStyleAttributeName : paragraphStyle};
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    CGSize size = [EvstAttributedLabel sizeThatFitsAttributedString:attrString withConstraints:constraintSize limitedToNumberOfLines:0];
    return MAX(kEvstMomentTagAreaDefaultHeight, ceil(size.height + kEvstDefaultPadding)); // Set a minimum height
  }
  return 0.f;
}

+ (CGFloat)cellContentWidth {
  return kEvstMainScreenWidth - kEvstMomentContentPadding * 2.f;
}

+ (NSString *)momentContentWithJourneyNameForMoment:(EverestMoment *)moment {
  return [self momentContent:moment.name withJourneyName:[self inJourneyNameForMoment:moment]];
}

+ (NSString *)inJourneyNameForMoment:(EverestMoment *)moment {
  return [NSString stringWithFormat:@"%@ %@", kLocaleIn, moment.journey.name];
}

+ (NSString *)momentContent:(NSString *)momentContent withJourneyName:(NSString *)inJourneyName {
  return (momentContent.length) ? [NSString stringWithFormat:@"%@ %@", momentContent, inJourneyName] : inJourneyName;
}

@end
