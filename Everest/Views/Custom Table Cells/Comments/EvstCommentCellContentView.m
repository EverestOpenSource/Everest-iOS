//
//  EvstCommentCellContentView.m
//  Everest
//
//  Created by Chris Cornelis on 01/24/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstCommentCellContentView.h"
#import "EvstCommentCellUserHeaderView.h"
#import "UIView+EvstAdditions.h"
#import "NSDate+EvstAdditions.h"
#import "EvstCellCache.h"
#import "EvstAttributedLabel.h"

static CGFloat const kEvstCommentContentRightMargin = 45.f;
static CGFloat const kEvstCommentContentTopOffset = 8.f;

@interface EvstCommentCellContentView ()
@property (nonatomic, strong) EverestComment *comment;
@property (nonatomic, strong) EvstCommentCellUserHeaderView *cellHeaderView;
@property (nonatomic, strong) TTTAttributedLabel *commentTextLabel;
@property (nonatomic, assign) dispatch_once_t onceToken;
@property (nonatomic, strong) MASConstraint *userHeaderYConstraint;
@end

@implementation EvstCommentCellContentView

#pragma mark - Class Init

- (id)init {
  return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self commonSetup];
  }
  return self;
}

#pragma mark - Common Setup

- (void)commonSetup {
  // Ensure this is only called once per instance, otherwise duplicate content
  // will be displayed in the cell
  dispatch_once(&_onceToken, ^{
    self.opaque = YES;
    self.backgroundColor = kColorWhite;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
      
    [self setupView];
  });
}
                
#pragma mark - Setup
                
- (void)setupView {
  UIView *superview = self;
  
  self.cellHeaderView = [[EvstCommentCellUserHeaderView alloc] init];
  [superview addSubview:self.cellHeaderView];
  [self.cellHeaderView makeConstraints:^(MASConstraintMaker *make) {
    // We set the top constraint during configuration
    make.left.equalTo(superview.left);
    make.right.equalTo(superview.right);
    make.height.equalTo([NSNumber numberWithDouble:kEvstSharedCellUserHeaderViewHeight]);
  }];

  self.commentTextLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
  self.commentTextLabel.delegate = self;
  self.commentTextLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
  self.commentTextLabel.activeLinkAttributes = nil; // Don't change link appearance when tapped
  self.commentTextLabel.linkAttributes = @{(id)kCTForegroundColorAttributeName : kColorTeal,
                                           (id)kCTUnderlineStyleAttributeName : [NSNumber numberWithInt:kCTUnderlineStyleNone] };
  self.commentTextLabel.inactiveLinkAttributes = @{(id)kCTForegroundColorAttributeName : [UIColor grayColor]};
  self.commentTextLabel.font = kFontHelveticaNeue13;
  self.commentTextLabel.textColor = kColorGray;
  self.commentTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
  self.commentTextLabel.lineHeightMultiple = kEvstCommentsLineHeightMultiple;
  self.commentTextLabel.numberOfLines = 0;
  [superview addSubview:self.commentTextLabel];
  
  [self.commentTextLabel makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.cellHeaderView.bottom).offset(-kEvstCommentContentTopOffset);
    make.left.equalTo(superview.left).offset(kEvstCommentCellLeftMargin);
    make.right.equalTo(superview.right).offset(-kEvstCommentContentRightMargin);
  }];
}

#pragma mark - Configurations

- (void)prepareForReuse {
  self.comment = nil;
  self.commentTextLabel.text = self.commentTextLabel.accessibilityLabel = nil;
  [self.cellHeaderView prepareForReuse];
}

- (void)configureWithComment:(EverestComment *)comment {
  ZAssert(comment, @"Comment must not be nil when we try to populate a cell with it");
  self.comment = comment;
  
  [self.userHeaderYConstraint uninstall];
  UIView *superview = self;
  [self.cellHeaderView updateConstraints:^(MASConstraintMaker *make) {
    self.userHeaderYConstraint = make.top.equalTo(superview.top);
  }];
  
  [self.cellHeaderView configureWithComment:self.comment];
  [self.commentTextLabel setText:self.comment.content];
  self.commentTextLabel.accessibilityLabel = self.comment.content;
}

#pragma mark - Cell Calculations

+ (CGFloat)cellHeightForComment:(EverestComment *)comment {
  return kEvstSharedCellUserHeaderViewHeight + [self heightForContentAreaWithComment:comment] + kEvstDefaultPadding;
}

+ (CGFloat)heightForContentAreaWithComment:(EverestComment *)comment {
  NSNumber *commentHeight = [[EvstCellCache sharedCache] cachedCellHeightForUUID:comment.uuid];
  if (commentHeight) {
    return [commentHeight doubleValue];
  } else {
    CGFloat calculatedHeight = [self heightForContentText:comment.content];
    [[EvstCellCache sharedCache] cacheCellHeight:calculatedHeight forUUID:comment.uuid];
    return calculatedHeight;
  }
}

#pragma mark - Width & Height Helpers

+ (CGFloat)heightForContentText:(NSString *)text {
  CGSize constraintSize = CGSizeMake([self cellContentWidth], CGFLOAT_MAX);
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
  paragraphStyle.lineHeightMultiple = kEvstCommentsLineHeightMultiple;
  NSDictionary *attributes = @{NSFontAttributeName : kFontHelveticaNeue13, NSParagraphStyleAttributeName : paragraphStyle};
  NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:text attributes:attributes];
  CGSize size = [EvstAttributedLabel sizeThatFitsAttributedString:attrString withConstraints:constraintSize limitedToNumberOfLines:0];

  return ceil(size.height);
}

+ (CGFloat)cellContentWidth {
  return kEvstMainScreenWidth - kEvstCommentCellLeftMargin - kEvstCommentContentRightMargin - kEvstDefaultPadding;
}

#pragma mark TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
  [[NSNotificationCenter defaultCenter] postNotificationName:kEvstDidPressHTTPURLNotification object:url.absoluteString];
}

@end
