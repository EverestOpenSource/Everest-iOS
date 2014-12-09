//
//  EvstPageViewController.m
//  Everest
//
//  Created by Rob Phillips on 1/22/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstPageViewController.h"
#import "EvstUserViewController.h"
#import "EvstJourneysListViewController.h"
#import "EvstJourneyViewController.h"

typedef NS_ENUM(NSUInteger, EvstPageViewPage) {
  kEvstPageViewLeftPage,
  kEvstPageViewRightPage,
  kEvstPageViewCount
};

static CGFloat const kEvstTabbedAreaHeight = 34.f;

@interface EvstPageViewController ()
@property (nonatomic, strong) UIToolbar *tabbedView;
@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, strong) UIScrollView *swipeView;
@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, strong) UITableViewController *leftTableViewController;
@property (nonatomic, strong) UITableViewController *rightTableViewController;
@property (nonatomic, strong) NSAttributedString *leftTableTitleActive;
@property (nonatomic, strong) NSAttributedString *leftTableTitleInactive;
@property (nonatomic, strong) NSAttributedString *rightTableTitleActive;
@property (nonatomic, strong) NSAttributedString *rightTableTitleInactive;
@property (nonatomic, assign) BOOL shouldShowLeftPageFirst;
@property (nonatomic, assign) BOOL showingFromMenuView;
@property (nonatomic, assign) dispatch_once_t onceTokenDidShowFirstPage;
@end

@implementation EvstPageViewController

#pragma mark - Paged Controller Instantiation

+ (EvstPageViewController *)pagedControllerForUser:(EverestUser *)user showingUserProfile:(BOOL)showingUserProfile fromMenuView:(BOOL)fromMenuView {
  EvstUserViewController *userVC = [[EvstCommon storyboard] instantiateViewControllerWithIdentifier:@"EvstUserViewController"];
  userVC.user = user;
  EvstJourneysListViewController *journeysVC = [[EvstCommon storyboard] instantiateViewControllerWithIdentifier:@"EvstJourneysListViewController"];
  journeysVC.user = user;
  EvstPageViewController *pageVC = [[EvstCommon storyboard] instantiateViewControllerWithIdentifier:@"EvstPageViewController"];
  [pageVC setupWithLeftTableViewController:userVC rightTableViewController:journeysVC showingLeftFirst:showingUserProfile fromMenuView:fromMenuView leftTitle:kLocaleProfile rightTitle:kLocaleJourneys];
  return pageVC;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self setupView];
}

- (void)viewWillAppear:(BOOL)animate {
  [super viewWillAppear:animate];
  
  // Only do this once so it doesn't reset to the left page during navigation pops
  dispatch_once(&_onceTokenDidShowFirstPage, ^{
    self.currentPage = (self.shouldShowLeftPageFirst) ? kEvstPageViewLeftPage : kEvstPageViewRightPage;
    [self gotoCurrentPageWithAnimation:NO];
  });
  
  if (self.showingFromMenuView) {
    [self setupEverestSlidingMenu];
  }
  
  self.navigationController.delegate = self;
  
  // This is a secondary notification for appearing after being hidden by modals
  [self notifyListenersForCurrentPage];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  // This needs to happen in viewDidAppear due to a timing issue
  [self setupScrollsToTop];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  // Important: Remove ourself as the navigation controller delegate
  self.navigationController.delegate = nil;
}

#pragma mark - Custom Setters

- (void)setNavigationItemTitle:(NSString *)navigationItemTitle {
  if ([navigationItemTitle isEqualToString:_navigationItemTitle]) {
    return;
  }
  _navigationItemTitle = navigationItemTitle;
  self.navigationItem.title = self.navigationItem.accessibilityLabel = _navigationItemTitle;
}

#pragma mark - Setup

- (void)setupView {
  [self setupSwipeView];
  [self setupTabbedArea];
}

- (void)setupSwipeView {
  self.swipeView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
  self.swipeView.pagingEnabled = YES;
  self.swipeView.showsHorizontalScrollIndicator = NO;
  self.swipeView.showsVerticalScrollIndicator = NO;
  self.swipeView.directionalLockEnabled = YES;
  self.swipeView.bounces = NO;
  self.swipeView.scrollsToTop = NO;
  self.swipeView.delegate = self;
  self.swipeView.contentSize = CGSizeMake(self.swipeView.frame.size.width * kEvstPageViewCount, 1.f);
  [self.view addSubview:self.swipeView];
}

- (void)setupTabbedArea {
  self.tabbedView = [[UIToolbar alloc] initWithFrame:CGRectMake(0.f, kEvstNavigationBarHeight, kEvstMainScreenWidth, kEvstTabbedAreaHeight)];
  [self.tabbedView setBackgroundImage:nil forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
  [self.tabbedView setShadowImage:nil forToolbarPosition:UIBarPositionAny];
  self.tabbedView.barTintColor = kColorWhite;
  self.leftTabButton = [[UIButton alloc] initWithFrame:CGRectMake(0.f, 0.f, self.tabbedView.frame.size.width / 2.f, kEvstTabbedAreaHeight)];
  [self.leftTabButton addTarget:self action:@selector(leftTabButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
  [self.leftTabButton setAttributedTitle:self.leftTableTitleInactive forState:UIControlStateNormal];
  [self.leftTabButton setAttributedTitle:self.leftTableTitleActive forState:UIControlStateSelected];
  self.leftTabButton.accessibilityLabel = self.leftTableTitleActive.string;
  self.rightTabButton = [[UIButton alloc] initWithFrame:CGRectMake(self.tabbedView.frame.size.width / 2.f, 0.f, self.tabbedView.frame.size.width / 2.f, kEvstTabbedAreaHeight)];
  [self.rightTabButton setAttributedTitle:self.rightTableTitleInactive forState:UIControlStateNormal];
  [self.rightTabButton setAttributedTitle:self.rightTableTitleActive forState:UIControlStateSelected];
  self.rightTabButton.accessibilityLabel = self.rightTableTitleActive.string;
  [self.rightTabButton addTarget:self action:@selector(rightTabButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
  UIImageView *bottomLine = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, kEvstTabbedAreaHeight, kEvstMainScreenWidth, 0.5f)];
  UIImageView *centerLine = [[UIImageView alloc] initWithFrame:CGRectMake(kEvstMainScreenWidth / 2.f, 0.f, 0.5f, kEvstTabbedAreaHeight)];
  bottomLine.image = centerLine.image = [[UIImage imageNamed:@"Tabbed Area Line"] resizableImageWithCapInsets:UIEdgeInsetsZero];
  [self.tabbedView addSubview:bottomLine];
  [self.tabbedView addSubview:centerLine];
  [self.tabbedView addSubview:self.leftTabButton];
  [self.tabbedView addSubview:self.rightTabButton];
  [self.view addSubview:self.tabbedView];
}

- (void)setupWithLeftTableViewController:(UITableViewController *)leftTableViewController rightTableViewController:(UITableViewController *)rightTableViewController showingLeftFirst:(BOOL)showingLeftFirst fromMenuView:(BOOL)fromMenuView leftTitle:(NSString *)leftTitle rightTitle:(NSString *)rightTitle {
  self.showingFromMenuView = fromMenuView;
  self.viewControllers = @[leftTableViewController, rightTableViewController];
  self.leftTableViewController = leftTableViewController;
  
  NSDictionary *inactiveAttributes = @{NSFontAttributeName : kFontHelveticaNeueBold13,
                                       NSForegroundColorAttributeName : kColorGray};
  NSDictionary *activeAttributes = @{NSFontAttributeName : kFontHelveticaNeueBold13,
                                     NSForegroundColorAttributeName : kColorTeal};
  self.leftTableTitleInactive = [[NSAttributedString alloc] initWithString:leftTitle attributes:inactiveAttributes];
  self.leftTableTitleActive = [[NSAttributedString alloc] initWithString:leftTitle attributes:activeAttributes];
  self.rightTableTitleInactive = [[NSAttributedString alloc] initWithString:rightTitle attributes:inactiveAttributes];
  self.rightTableTitleActive = [[NSAttributedString alloc] initWithString:rightTitle attributes:activeAttributes];
  
  self.rightTableViewController = rightTableViewController;
  // TODO (EVENTUALLY) HACK: Don't use a constant value for nav offset here (topLayoutGuide not working)
  UIEdgeInsets scrollInsets;
  if (IS_OS_7_OR_EARLIER) {
    // iOS 7 and before
    scrollInsets = UIEdgeInsetsMake(kEvstNavigationBarHeight + kEvstTabbedAreaHeight, 0, 0, 0);
  } else {
    // iOS 8 and above
    scrollInsets = UIEdgeInsetsMake(kEvstTabbedAreaHeight, 0, kEvstNavigationBarHeight, 0);
  }
  self.leftTableViewController.tableView.scrollIndicatorInsets = self.rightTableViewController.tableView.scrollIndicatorInsets = scrollInsets;
  self.leftTableViewController.tableView.contentInset = self.rightTableViewController.tableView.contentInset = scrollInsets;
  self.shouldShowLeftPageFirst = showingLeftFirst;
}

- (void)loadSwipeViewWithPage:(EvstPageViewPage)page {
  UITableViewController *tableVC = [self.viewControllers objectAtIndex:page];
  
  if (!tableVC.view.superview) {
    CGRect frame = self.swipeView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0.f;
    tableVC.view.frame = frame;
    
    [self addChildViewController:tableVC];
    [self.swipeView addSubview:tableVC.view];
    [tableVC didMoveToParentViewController:self];
  }
}

- (void)setupScrollsToTop {
  // Make sure we can scroll to top on all views
  self.rightTableViewController.tableView.scrollsToTop = (self.currentPage != kEvstPageViewLeftPage);
  self.leftTableViewController.tableView.scrollsToTop = (self.currentPage == kEvstPageViewLeftPage);
}

#pragma mark - Paging

- (void)gotoCurrentPageWithAnimation:(BOOL)animated {
  [self updateWithNewPage];
  
  CGRect bounds = self.swipeView.bounds;
  bounds.origin.x = bounds.size.width * self.currentPage;
  bounds.origin.y = 0;
  [self.swipeView scrollRectToVisible:bounds animated:animated];
}

- (void)updateWithNewPage {
  [self loadSwipeViewWithPage:kEvstPageViewLeftPage];
  [self loadSwipeViewWithPage:kEvstPageViewRightPage];
  
  [self setupScrollsToTop];
  
  [self.rightTabButton setSelected:(self.currentPage != kEvstPageViewLeftPage)];
  [self.leftTabButton setSelected:(self.currentPage == kEvstPageViewLeftPage)];
  
  [self notifyListenersForCurrentPage];
}

- (void)notifyListenersForCurrentPage {
  [[NSNotificationCenter defaultCenter] postNotificationName:(self.currentPage == kEvstPageViewLeftPage) ? kEvstPageControllerChangedToUserViewNotification : kEvstPageControllerChangedToJourneysListNotification object:nil];
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
  CGFloat pageWidth = self.swipeView.frame.size.width;
  NSUInteger page = (NSUInteger)(floor((self.swipeView.contentOffset.x - pageWidth / 2.f) / pageWidth) + 1);
  self.currentPage = page;
  [self updateWithNewPage];
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
  [self setupBackButton];
}

#pragma mark - IBActions

- (IBAction)leftTabButtonPressed:(id)sender {
  self.currentPage = kEvstPageViewLeftPage;
  [self gotoCurrentPageWithAnimation:YES];
}

- (IBAction)rightTabButtonPressed:(id)sender {
  self.currentPage = kEvstPageViewRightPage;
  [self gotoCurrentPageWithAnimation:YES];
}

@end
