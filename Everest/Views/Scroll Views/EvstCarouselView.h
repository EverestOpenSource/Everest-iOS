//
//  EvstCarouselView.h
//  Everest
//
//  Created by Rob Phillips on 5/13/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <UIKit/UIKit.h>
#import "EverestDiscoverCategory.h"

#pragma mark - EvstDiscoverCategoryView

static CGFloat const kEvstDiscoverCategoryWidth = 280.f;
static CGFloat const kEvstDiscoverCategoryHeight = 113.f;

@interface EvstDiscoverCategoryView : UIView
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *detail;
@property (nonatomic, strong) UIImageView *backgroundImage;
@end

#pragma mark - EvstCarouselScrollView

@interface EvstCarouselScrollView : UIScrollView

@property (nonatomic, strong) NSMutableArray *categoryViews;
@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, assign) NSUInteger numberOfPages;

- (EvstDiscoverCategoryView *)categoryViewForPage:(NSInteger)page;

@end

#pragma mark - EvstCarouselView

static CGFloat const kEvstCarouselViewTopPadding = 0.f;
static CGFloat const kEvstDiscoverCategoryPadding = 3.f;

@class EvstCarouselView;
@protocol EvstCarouselViewDelegate <NSObject>
/*!
 * Delegate method called when a specific category is paged into view
 */
- (void)carouselView:(EvstCarouselView *)carouselView didSelectCategory:(EverestDiscoverCategory *)category;
@end

@interface EvstCarouselView : UIView <UIScrollViewDelegate>

@property (nonatomic, weak) id<EvstCarouselViewDelegate> carouselDelegate;

/*!
 * Optional initializer to override default page width/height, otherwise use `initWithFrame:` by default.
 */
- (instancetype)initWithFrame:(CGRect)frame pageWidth:(CGFloat)pageWidth pageHeight:(CGFloat)pageHeight;

/*!
 * Performs a server request to get all categories and load them into the carousel view
 */
- (void)populateCategoriesWithSuccess:(void (^)())successHandler failure:(void (^)(NSString *errorMsg))failureHandler;

@end
