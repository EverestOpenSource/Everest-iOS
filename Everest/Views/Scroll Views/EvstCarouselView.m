//
//  EvstCarouselView.m
//  Everest
//
//  Created by Rob Phillips on 5/13/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstCarouselView.h"
#import "EvstSearchExploreHomeEndPoint.h"
#import "EverestDiscoverCategory.h"

#pragma mark - EvstDiscoverCategoryView

@interface EvstDiscoverCategoryView ()
@property (nonatomic, strong) EverestDiscoverCategory *category;
@end

@implementation EvstDiscoverCategoryView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    UIView *superview = self;
    
    self.backgroundImage = [[UIImageView alloc] init];
    [self addSubview:self.backgroundImage];
    self.backgroundImage.backgroundColor = kColorGray;
    [self.backgroundImage makeConstraints:^(MASConstraintMaker *make) {
      make.edges.equalTo(superview);
    }];
    
    self.name = [[UILabel alloc] init];
    self.name.font = kFontHelveticaNeueThin24;
    self.name.textColor = kColorWhite;
    [self addSubview:self.name];
    [self.name makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(superview.left).offset(8.f);
      make.centerY.equalTo(superview.centerY).offset(-8.f);
    }];
    
    self.detail = [[UILabel alloc] init];
    self.detail.font = kFontHelveticaNeueLight9;
    self.detail.textColor = kColorWhite;
    [self addSubview:self.detail];
    [self.detail makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.name.left);
      make.top.equalTo(self.name.bottom).offset(1.f);
    }];
  }
  return self;
}

#pragma mark - Accessors

- (void)setCategory:(EverestDiscoverCategory *)category {
  if (_category == category) {
    return;
  }
  _category = category;
  
  dispatch_async(dispatch_get_main_queue(), ^{
    self.name.text = category.name;
    self.detail.text = category.detail;
    [self.backgroundImage sd_setImageWithURL:[NSURL URLWithString:category.imageURL] placeholderImage:nil options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
      if (error && [error code] != NSURLErrorCancelled) {
        DLog(@"Error setting Discover category image: %@", error.localizedDescription);
      }
    }];
  });
}

@end

#pragma mark - EvstCarouselScrollView

@interface EvstCarouselScrollView ()
@property (nonatomic, assign) CGFloat pageWidth;
@end

@implementation EvstCarouselScrollView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.accessibilityIdentifier = kLocaleDiscoverCarousel;
    self.pagingEnabled = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.directionalLockEnabled = YES;
    self.bounces = YES;
    self.scrollsToTop = NO;
    self.clipsToBounds = NO;
  }
  return self;
}

#pragma mark - Accessors

- (CGFloat)pageWidth {
  return self.frame.size.width;
}

- (NSUInteger)currentPage {
  // Page can never be < 0
  return 1 + (NSUInteger)(floor((self.contentOffset.x - self.pageWidth / 2.f) / self.pageWidth) + 1);
}

- (void)setNumberOfPages:(NSUInteger)numberOfPages {
  if (numberOfPages == _numberOfPages) {
    return;
  }
  _numberOfPages = numberOfPages;
  self.contentSize = CGSizeMake(self.frame.size.width * numberOfPages, self.frame.size.height);
}

- (void)addCategoryViewsForCategories:(NSArray *)categories {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    CGFloat x = 0.f;
    self.categoryViews = [NSMutableArray arrayWithCapacity:categories.count];
    for (EverestDiscoverCategory *category in categories) {
      EvstDiscoverCategoryView *categoryView = [[EvstDiscoverCategoryView alloc] initWithFrame:CGRectMake(x, 0.f, kEvstDiscoverCategoryWidth, kEvstDiscoverCategoryHeight)];
      categoryView.category = category;
      [self.categoryViews addObject:categoryView];
      x += kEvstDiscoverCategoryWidth + kEvstDiscoverCategoryPadding;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
      for (EvstDiscoverCategoryView *categoryView in self.categoryViews) {
        [self addSubview:categoryView];
      }
      [self setNumberOfPages:self.categoryViews.count];
      EverestDiscoverCategory *defaultCategory = [categories filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"defaultCategory = YES"]].firstObject;
      NSInteger defaultPage = defaultCategory ? [categories indexOfObject:defaultCategory] + 1 : 1;
      [self scrollToPage:defaultPage animated:NO];
    });
  });
}

#pragma mark - Convenience Methods

- (void)scrollToPage:(NSInteger)page animated:(BOOL)animated {
  [self setContentOffset:CGPointMake(self.pageWidth * MAX(0, page - 1), 0.f) animated:animated];
}

- (EvstDiscoverCategoryView *)categoryViewForPage:(NSInteger)page {
  return [self.categoryViews objectAtIndex:MAX(0, page - 1)];
}

@end

#pragma mark - EvstCarouselView

@interface EvstCarouselView ()
@property (nonatomic, strong) EvstCarouselScrollView *carouselScrollView;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) EverestDiscoverCategory *currentCategory;
@property (nonatomic, strong) EverestDiscoverCategory *defaultCategory;

@property (nonatomic, assign) CGFloat pageWidth;
@property (nonatomic, assign) CGFloat pageHeight;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@end

@implementation EvstCarouselView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
  return [self initWithFrame:frame pageWidth:kEvstDiscoverCategoryWidth pageHeight:kEvstDiscoverCategoryHeight];
}

- (instancetype)initWithFrame:(CGRect)frame pageWidth:(CGFloat)pageWidth pageHeight:(CGFloat)pageHeight {
  self = [super initWithFrame:frame];
  if (self) {
    self.accessibilityLabel = kLocaleDiscoverCategory;
    
    self.clipsToBounds = YES; // Clip the scrollview's bounds
    
    self.pageWidth = pageWidth;
    self.pageHeight = pageHeight;
    
    self.carouselScrollView = [[EvstCarouselScrollView alloc] initWithFrame:CGRectMake((self.frame.size.width - self.pageWidth) / 2.f, kEvstCarouselViewTopPadding, pageWidth + kEvstDiscoverCategoryPadding, pageHeight)];
    self.carouselScrollView.delegate = self;
    self.carouselScrollView.alpha = 0.f;
    [self addSubview:self.carouselScrollView];
    
    UIImageView *categoryArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Category Arrow"]];
    [self addSubview:categoryArrow];
    [categoryArrow makeConstraints:^(MASConstraintMaker *make) {
      make.centerX.equalTo(self.centerX);
      make.bottom.equalTo(self.bottom);
    }];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.center = self.center;
    [self addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
  }
  return self;
}

#pragma mark - Loading Data

- (void)populateCategoriesWithSuccess:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler {
  [EvstSearchExploreHomeEndPoint getDiscoverCategoriesWithSuccess:^(NSArray *categories) {
    if (categories.count <= 0) {
      if (failureHandler) {
        failureHandler(@"Server Error: No categories were returned in the result.");
      }
    } else {
      [self.activityIndicator stopAnimating];
      [UIView animateWithDuration:0.4f animations:^{
        self.carouselScrollView.alpha = 1.f;
      }];
      
      self.categories = categories;
      self.defaultCategory = [self.categories filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"defaultCategory = YES"]].firstObject;
      self.currentCategory = self.defaultCategory ?: self.categories.firstObject;
      [self.carouselScrollView addCategoryViewsForCategories:self.categories];
      if (self.carouselDelegate && [self.carouselDelegate respondsToSelector:@selector(carouselView:didSelectCategory:)]) {
        self.accessibilityValue = self.currentCategory.name;
        [self.carouselDelegate carouselView:self didSelectCategory:self.currentCategory];
      }
      
      if (successHandler) {
        successHandler();
      }
    }
  } failure:^(NSString *errorMsg) {
    if (failureHandler) {
      failureHandler(errorMsg);
    }
  }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  // If the view is swiped very fast, the scroll view's decelerating delegate method won't get called
  // so ensure we catch this state here
  if (!decelerate) {
    [self updateForSwipingEnd];
  }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  [self updateForSwipingEnd];
}

- (void)updateForSwipingEnd {
  if (self.carouselDelegate && [self.carouselDelegate respondsToSelector:@selector(carouselView:didSelectCategory:)]) {
    EvstDiscoverCategoryView *currentView = [self.carouselScrollView categoryViewForPage:self.carouselScrollView.currentPage];
    EverestDiscoverCategory *newCategory = currentView.category;
    if (newCategory != self.currentCategory) {
      self.currentCategory = newCategory;
      self.accessibilityValue = self.currentCategory.name;
      [self.carouselDelegate carouselView:self didSelectCategory:newCategory];
    }
  }
}

#pragma mark - Hit Test

// In order for the scrollview to show overlapping categories, it must have a width smaller than the container width with clipsToBounds disabled.
// However, this means that swiping on the visible extremeties of the scrollview will actually be swiping the container view.
// So this method allows us to transfer any touch event inside of the container to be within the scrollview instead
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
  return [self pointInside:point withEvent:event] ? self.carouselScrollView : nil;
}

@end
