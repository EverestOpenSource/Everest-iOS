//
//  EvstLoadAllCommentsCell.m
//  Everest
//
//  Created by Rob Phillips on 4/9/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstLoadAllCommentsCell.h"
#import "UIView+EvstAdditions.h"

@interface EvstLoadAllCommentsCell ()
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@end

@implementation EvstLoadAllCommentsCell

#pragma mark - Lifecycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    // Cell defaults
    self.opaque = YES;
    self.backgroundColor = kColorWhite;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    [self setupView];
  }
  return self;
}

#pragma mark - Setup

- (void)setupView {
  self.loadAllCommentsButton = [[UIButton alloc] init];
  self.loadAllCommentsButton.enabled = NO;
  [self.loadAllCommentsButton addTarget:self action:@selector(loadAllCommentsTapped:) forControlEvents:UIControlEventTouchUpInside];
  [self.loadAllCommentsButton setTitle:kLocaleLoadPreviousComments forState:UIControlStateNormal];
  [self.loadAllCommentsButton setTitleColor:kColorGray forState:UIControlStateNormal];
  UIFont *titleFont = kFontHelveticaNeueBold12;
  self.loadAllCommentsButton.titleLabel.font = titleFont;
  self.loadAllCommentsButton.accessibilityLabel = kLocaleLoadPreviousComments;
  self.loadAllCommentsButton.backgroundColor = kColorWhite;
  [self.loadAllCommentsButton roundCornersWithRadius:3.f borderWidth:0.5f borderColor:kColorOffWhite];
  
  CGSize textSize = CGSizeMake(kEvstMainScreenWidth - 2 * kEvstDefaultPadding, kEvstDefaultButtonHeight);
  CGRect textRect = [kLocaleLoadPreviousComments boundingRectWithSize:textSize
                                                              options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                           attributes:@{ NSFontAttributeName : titleFont }
                                                              context:nil];
  UIView *superview = self;
  [superview addSubview:self.loadAllCommentsButton];
  [self.loadAllCommentsButton makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.equalTo(superview);
    make.top.equalTo(superview).offset(16.f);
    make.height.equalTo([NSNumber numberWithDouble:kEvstDefaultButtonHeight]);
    make.width.equalTo([NSNumber numberWithDouble:textRect.size.width + 12.f]);
  }];
}

- (IBAction)loadAllCommentsTapped:(id)sender {
  self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
  self.activityIndicator.center = self.loadAllCommentsButton.center;
  [self addSubview:self.activityIndicator];
  [self.loadAllCommentsButton removeFromSuperview];
  [self.activityIndicator startAnimating];
  [[NSNotificationCenter defaultCenter] postNotificationName:kEvstLoadAllCommentsNotification object:self.moment];
}

@end
