//
//  EvstCommentCell.m
//  Everest
//
//  Created by Rob Phillips on 1/13/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstCommentCell.h"
#import "EvstCommentCellContentView.h"
#import "UIView+EvstAdditions.h"

@interface EvstCommentCell ()
@property (nonatomic, strong) EvstCommentCellContentView *cellContentView;
@property (nonatomic, strong) EverestComment *comment;
@end

@implementation EvstCommentCell

#pragma mark - Class Init

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    [self commonSetup];
  }
  return self;
}

- (void)awakeFromNib {
  [self commonSetup];
}

- (void)commonSetup {
  // Cell defaults
  self.opaque = YES;
  self.backgroundColor = kColorWhite;
  self.selectionStyle = UITableViewCellSelectionStyleNone;
  self.layer.shouldRasterize = YES;
  self.layer.rasterizationScale = [UIScreen mainScreen].scale;
  
  // Add the content view where we do custom drawing
  self.cellContentView = [[EvstCommentCellContentView alloc] init];
  [self.contentView addSubview:self.cellContentView];
  UIView *superview = self.contentView;
  [self.cellContentView makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(superview);
  }];
}

#pragma mark - Configurations

- (void)prepareForReuse {
  [super prepareForReuse];
  
  [self.cellContentView prepareForReuse];
}

- (void)configureWithComment:(EverestComment *)comment {
  self.comment = comment;
  
  [self.cellContentView configureWithComment:self.comment];
  self.accessibilityLabel = [NSString stringWithFormat:@"%@ %@", kLocaleComment, self.comment.content];
}

+ (CGFloat)cellHeightForComment:(EverestComment *)comment {
  return [EvstCommentCellContentView cellHeightForComment:comment];
}

@end
