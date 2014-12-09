//
//  EvstCommentsViewController.m
//  Everest
//
//  Created by Rob Phillips on 1/13/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstCommentsViewController.h"
#import "EvstWebViewController.h"
#import "EvstTagSearchViewController.h"
#import "EvstCommentsEndPoint.h"
#import "EvstCommentCell.h"
#import "EvstLoadAllCommentsCell.h"
#import "UITextView+EvstAdditions.h"
#import "EvstPageViewController.h"
#import "EvstJourneyViewController.h"
#import "EvstMomentsEndPoint.h"
#import "UIView+EvstAdditions.h"
#import "EvstFacebook.h"
#import "EvstTwitter.h"
#import "EvstLikersViewController.h"

// Moment cells
#import "EvstMomentCellBase.h"
#import "EvstMomentPlainTextCell.h"
#import "EvstMomentPhotoTextCell.h"
#import "EvstLifecycleMomentCell.h"

static NSString *const EvstCommentCellIdentifier = @"EvstCommentCell";
static NSString *const EvstLoadAllCommentsCellIdentifier = @"EvstLoadAllCommentsCell";
NSUInteger const kEvstCommentContentMaxLength = 1000;
static NSUInteger const kEvstNumberOfCommentsInitiallyShown = 4; // Per design, we should only load 4 initial comments
static CGFloat const kEvstLoadAllCommentsRowHeight = 43.f;

@interface EvstCommentsViewController ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *tableHeaderView;
@property (nonatomic, strong) EvstMomentCellBase *headerCell;
@property (nonatomic, strong) UIView *addCommentToolbar;
@property (nonatomic, strong) MASConstraint *toolbarBottomConstraint;
@property (nonatomic, strong) EvstGrowingTextView *commentTextView;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIButton *likeButton;

@property (nonatomic, assign) dispatch_once_t onceToken_showingLoadPreviousComments;
@property (nonatomic, assign) BOOL currentlyShowingThisCommentsView;
@property (nonatomic, assign) BOOL showingLoadPreviousCommentsButton;
@property (nonatomic, assign) BOOL didLoadAllComments;
@property (nonatomic, assign) BOOL didLoadInitialComments;
@property (nonatomic, assign) NSUInteger pagingLimit;
@property (nonatomic, assign) NSUInteger pagingOffset;
@property (nonatomic, strong) NSDate *createdBefore;

@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, strong) NSMutableArray *likes;
@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, assign) dispatch_once_t onceTokenInfScroll;
@property (nonatomic, assign) dispatch_once_t onceTokenFirstResponder;

@property (nonatomic, assign) BOOL shouldExpandTags;
@property (nonatomic, assign) BOOL momentWasDeletedAfterViewingIt;
@property (nonatomic, assign) CGFloat originalKeyboardHeight;
@end

@implementation EvstCommentsViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self registerForDidLoadNotifications];
  [self setupView];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.currentlyShowingThisCommentsView = YES;
  [self registerForWillAppearNotifications];
  [self setupMomentHeader];
  [self setupOptions];
  self.likeButton.selected = self.moment.isLikedByCurrentUser;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  dispatch_once(&_onceTokenFirstResponder, ^{
    if (self.didShowViewUsingCommentButton) {
      [self.commentTextView becomeFirstResponder];
    }
  });
  
  if (self.momentWasDeletedAfterViewingIt || self.moment.associatedJourneyWasDeleted) {
    [self.navigationController popViewControllerAnimated:YES];
  } else {
    // Note: This needs to happen in viewDidAppear and after the comment field becomes first responder
    [self setupInfiniteScrolling];
  }
  
  [EvstAnalytics trackView:kEvstAnalyticsDidViewComments objectUUID:self.moment.uuid];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  self.currentlyShowingThisCommentsView = NO;
  [self unregisterWillAppearNotifications];
  
  [NSObject cancelPreviousPerformRequestsWithTarget:self.commentTextView selector:@selector(becomeFirstResponder) object:nil];
  
  [self.commentTextView resignFirstResponder];
}

- (void)dealloc {
  self.tableView.delegate = nil;
  self.tableView.dataSource = nil;
  [self unregisterNotifications];
}

#pragma mark - Setup

- (void)setupView {
  self.currentPage = 1;
  self.comments = [[NSMutableArray alloc] initWithCapacity:0];
  self.likes = [[NSMutableArray alloc] initWithCapacity:0];
  
  self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
  self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; // Hide separator lines in empty state
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.scrollsToTop = YES;
  self.tableView.separatorInset = UIEdgeInsetsMake(0.f, kEvstCommentCellLeftMargin, 0.f, 0.f);
  UIEdgeInsets contentInsets = self.tableView.contentInset;
  contentInsets.bottom += kEvstToolbarHeight;
  self.tableView.contentInset = self.tableView.scrollIndicatorInsets = contentInsets;
  self.tableView.accessibilityLabel = kLocaleCommentsTable;
  [self.tableView registerClass:[EvstCommentCell class] forCellReuseIdentifier:EvstCommentCellIdentifier];
  [self.tableView registerClass:[EvstLoadAllCommentsCell class] forCellReuseIdentifier:EvstLoadAllCommentsCellIdentifier];
  [self.view addSubview:self.tableView];
  
  self.navigationItem.title = kLocaleMoment;
  
  [self.view addSubview:self.addCommentToolbar];
  [self.addCommentToolbar makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.view.left);
    make.right.equalTo(self.view.right);
    self.toolbarBottomConstraint = make.bottom.equalTo(self.view.bottom);
    make.height.equalTo(self.commentTextView.height).offset(10.f);
  }];
}

- (void)setupOptions {
  if (self.moment.hasOptionsToDisplay) {
    UIBarButtonItem *optionsButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed: self.moment.journey.isPrivate ? @"Three Dots" : @"Share Icon Navigation"] style:UIBarButtonItemStylePlain target:self action:@selector(didPressOptionsButton:)];
    optionsButtonItem.accessibilityLabel = kLocaleMomentOptions;
    self.navigationItem.rightBarButtonItem = optionsButtonItem;
  } else {
    self.navigationItem.rightBarButtonItem = nil;
  }
}

- (void)setupMomentHeader {
  CGFloat headerHeight = [self momentHeaderHeight];
  CGRect frame = CGRectMake(0.f, 0.f, kEvstMainScreenWidth, headerHeight);
  self.tableHeaderView = [[UIView alloc] initWithFrame:frame];
  if (self.moment.isLifecycleMoment) {
    self.headerCell = [[EvstLifecycleMomentCell alloc] init];
  } else {
    self.headerCell = self.moment.imageURL ? [[EvstMomentPhotoTextCell alloc] init] : [[EvstMomentPlainTextCell alloc] init];
  }
  [self.tableHeaderView addSubview:self.headerCell.contentView];
  [self.headerCell.contentView makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.tableHeaderView);
  }];
  EvstMomentViewOptions options = self.shouldExpandTags ? EvstMomentShownInCommentsHeader | EvstMomentShownWithJourneyName | EvstMomentExpandToShowAllTags : EvstMomentShownInCommentsHeader | EvstMomentShownWithJourneyName;
  [self.headerCell configureWithMoment:self.moment withOptions:options];
  self.tableView.tableHeaderView = self.tableHeaderView;
}

- (CGFloat)momentHeaderHeight {
  
  if (self.moment.isLifecycleMoment) {
    return [EvstLifecycleMomentCell cellHeightForMoment:self.moment withOptions:EvstMomentShownInCommentsHeader fromCacheIfAvailable:NO];
  }
  
  EvstMomentViewOptions options = self.shouldExpandTags ? EvstMomentShownInCommentsHeader | EvstMomentShownWithJourneyName | EvstMomentExpandToShowAllTags : EvstMomentShownInCommentsHeader | EvstMomentShownWithJourneyName;
  if (self.moment.imageURL) {
    return [EvstMomentPhotoTextCell cellHeightForMoment:self.moment withOptions:options fromCacheIfAvailable:NO];
  } else {
    return [EvstMomentPlainTextCell cellHeightForMoment:self.moment withOptions:options fromCacheIfAvailable:NO];
  }
}

#pragma mark - Custom Getters

- (UIView *)addCommentToolbar {
  if (_addCommentToolbar) {
    return _addCommentToolbar;
  }
  
  _addCommentToolbar = [[UIView alloc] init];
  _addCommentToolbar.backgroundColor = kColorOffWhite;
  
  [_addCommentToolbar addSubview:self.likeButton];
  [_addCommentToolbar addSubview:self.commentTextView];
  [_addCommentToolbar addSubview:self.sendButton];
  
  [self.likeButton makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(_addCommentToolbar.left).offset(kEvstDefaultPadding);
    make.bottom.equalTo(_addCommentToolbar.bottom).offset(-kEvstDefaultPadding);
    make.size.equalTo(@30);
  }];
  
  [self.sendButton makeConstraints:^(MASConstraintMaker *make) {
    make.width.equalTo(@66);
    make.height.equalTo(@30);
    make.right.equalTo(_addCommentToolbar.right).offset(-kEvstDefaultPadding);
    make.bottom.equalTo(self.likeButton.bottom);
  }];
  
  // Growing comment text view
  [self.commentTextView makeConstraints:^(MASConstraintMaker *make) {
    make.height.equalTo(@30);
    make.bottom.equalTo(self.likeButton.bottom);
    make.left.equalTo(self.likeButton.right).offset(kEvstDefaultPadding);
    make.right.equalTo(self.sendButton.left).offset(-kEvstDefaultPadding);
  }];
  self.commentTextView.minimumHeight = 30.f;
  self.commentTextView.maximumHeight = 100.f;
  
  [self updateSendButtonState];

  UISwipeGestureRecognizer *swipeToolbarGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self.commentTextView action:@selector(resignFirstResponder)];
  swipeToolbarGesture.direction = UISwipeGestureRecognizerDirectionDown;
  [_addCommentToolbar addGestureRecognizer:swipeToolbarGesture];
  
  return _addCommentToolbar;
}

- (EvstGrowingTextView *)commentTextView {
  if (_commentTextView) {
    return _commentTextView;
  }
  _commentTextView = [[EvstGrowingTextView alloc] init];
  _commentTextView.delegate = self;
  _commentTextView.scrollsToTop = NO;
  _commentTextView.backgroundColor = kColorWhite;
  [_commentTextView roundCornersWithRadius:3.f borderWidth:0.5f borderColor:kColorStroke];
  _commentTextView.accessibilityLabel = kLocaleNewCommentTextField;
  _commentTextView.font = kFontHelveticaNeue12;
  _commentTextView.textColor = kColorBlack;
  _commentTextView.placeholder = kLocaleAddAComment;
  return _commentTextView;
}

- (UIButton *)likeButton {
  if (_likeButton) {
    return _likeButton;
  }
  _likeButton = [[UIButton alloc] init];
  [_likeButton setImage:[UIImage imageNamed:@"Like Active"] forState:UIControlStateSelected];
  [_likeButton setImage:[UIImage imageNamed:@"Like Inactive"] forState:UIControlStateNormal];
  [_likeButton addTarget:self action:@selector(likeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
  _likeButton.backgroundColor = kColorWhite;
  [_likeButton roundCornersWithRadius:2.f borderWidth:0.5f borderColor:kColorStroke];
  _likeButton.accessibilityLabel = kLocaleLikeFromToolbar;
  return _likeButton;
}

- (UIButton *)sendButton {
  if (_sendButton) {
    return _sendButton;
  }
  _sendButton = [[UIButton alloc] init];
  _sendButton.titleLabel.font = kFontHelveticaNeueBold12;
  [_sendButton addTarget:self action:@selector(sendCommentButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
  [_sendButton roundCornersWithRadius:2.f];
  [_sendButton setTitle:kLocaleSend forState:UIControlStateNormal];
  _sendButton.accessibilityLabel = kLocaleSend;
  return _sendButton;
}

- (BOOL)showingLoadPreviousCommentsButton {
  if (self.didLoadAllComments) {
    return NO;
  }
  
  dispatch_once(&_onceToken_showingLoadPreviousComments, ^{
    _showingLoadPreviousCommentsButton = (self.moment.commentsCount > kEvstNumberOfCommentsInitiallyShown) && (self.moment.commentsCount > self.comments.count);
  });
  return _showingLoadPreviousCommentsButton;
}

#pragma mark - Notifications

- (void)registerForDidLoadNotifications {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cachedMomentWasUpdated:) name:kEvstCachedMomentWasUpdatedNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cachedMomentWasDeleted:) name:kEvstCachedMomentWasDeletedNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cachedPartialUserWasUpdated:) name:kEvstCachedPartialUserWasUpdatedNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadAllCommentsIfNecessary:) name:kEvstLoadAllCommentsNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLikeOrCommentsCountChangeWithNotification:) name:kEvstMomentWasLikedUnlikedNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLikeOrCommentsCountChangeWithNotification:) name:kEvstMomentCommentCountWasChangedNotification object:nil];
}

- (void)loadAllCommentsIfNecessary:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstLoadAllCommentsNotification]) {
    EverestMoment *moment = notification.object;
    if (self.currentlyShowingThisCommentsView && [self.moment.uuid isEqualToString:moment.uuid]) {
      [self loadAllComments];
    }
  }
}

- (void)cachedPartialUserWasUpdated:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstCachedPartialUserWasUpdatedNotification]) {
    [self.tableView reloadRowsIfNecessaryForUpdatedCachedPartialObject:notification.object inSourceArray:self.comments];
  }
}

- (void)cachedMomentWasUpdated:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstCachedMomentWasUpdatedNotification]) {
    EverestMoment *updatedMoment = notification.object;
    if ([self.moment.uuid isEqualToString:updatedMoment.uuid]) {
      self.moment = updatedMoment;
    }
  }
}

- (void)cachedMomentWasDeleted:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstCachedMomentWasDeletedNotification]) {
    EverestMoment *deletedMoment = notification.object;
    if ([deletedMoment.uuid isEqualToString:self.moment.uuid]) {
      self.momentWasDeletedAfterViewingIt = YES;
    }
  }
}

- (void)handleLikeOrCommentsCountChangeWithNotification:(NSNotification *)notification {
  EverestMoment *moment = notification.object;
  if ([self.moment.uuid isEqualToString:moment.uuid]) {
    self.moment = moment;
    [self setupMomentHeader];
    self.likeButton.selected = self.moment.isLikedByCurrentUser;
  }
}

- (void)registerForWillAppearNotifications {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPressCommentButton:) name:kEvstCommentButtonWasTappedNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLikersList:) name:kEvstLikersButtonWasTappedNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showUserProfile:) name:kEvstShouldShowUserProfileNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPressJourneyURL:) name:kEvstDidPressJourneyURLNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPressHTTPURL:) name:kEvstDidPressHTTPURLNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPressTagSearchURL:) name:kEvstDidPressTagSearchURLNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPressExpandTagsURL:) name:kEvstDidPressExpandTagsURLNotification object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewTextDidChange:) name:UITextViewTextDidChangeNotification object:nil];
}

- (void)unregisterWillAppearNotifications {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kEvstCommentButtonWasTappedNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kEvstLikersButtonWasTappedNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kEvstShouldShowUserProfileNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kEvstDidPressJourneyURLNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kEvstDidPressHTTPURLNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kEvstDidPressTagSearchURLNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kEvstDidPressExpandTagsURLNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}

- (void)textViewTextDidChange:(NSNotification *)notification {
  if ([notification.name isEqualToString:UITextViewTextDidChangeNotification]) {
    [self updateSendButtonState];
  }
}

- (void)didPressCommentButton:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstCommentButtonWasTappedNotification]) {
    [self.commentTextView becomeFirstResponder];
  }
}

- (void)didPressHTTPURL:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstDidPressHTTPURLNotification]) {
    ZAssert(notification.object, @"No URL passed in, so we cannot show the webpage.");
    [EvstWebViewController presentWithURLString:notification.object inViewController:self];
  }
}

- (void)didPressJourneyURL:(NSNotification *)notification {
  EvstJourneyViewController *journeyVC = [[EvstCommon storyboard] instantiateViewControllerWithIdentifier:@"EvstJourneyViewController"];
  journeyVC.journey = notification.object;
  [self setupBackButton];
  [self.navigationController pushViewController:journeyVC animated:YES];
}

- (void)didPressTagSearchURL:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstDidPressTagSearchURLNotification]) {
    EvstTagSearchViewController *tagSearchVC = [[EvstTagSearchViewController alloc] init];
    tagSearchVC.tag = notification.object;
    [self setupBackButton];
    [self.navigationController pushViewController:tagSearchVC animated:YES];
  }
}

- (void)didPressExpandTagsURL:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstDidPressExpandTagsURLNotification]) {
    EverestMoment *momentToExpand = notification.object;
    if ([self.moment.uuid isEqualToString:momentToExpand.uuid]) {
      self.shouldExpandTags = YES;
      [self setupMomentHeader];
    }
  }
}

- (void)showLikersList:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstLikersButtonWasTappedNotification]) {
    EvstLikersViewController *likersVC = [[EvstLikersViewController alloc] init];
    likersVC.moment = notification.object;
    [self setupBackButton];
    [self.navigationController pushViewController:likersVC animated:YES];
  }
}

- (void)showUserProfile:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstShouldShowUserProfileNotification]) {
    EvstPageViewController *pageVC = [EvstPageViewController pagedControllerForUser:notification.object showingUserProfile:YES fromMenuView:NO];
    [self setupBackButton];
    [self.navigationController pushViewController:pageVC animated:YES];
  }
}

- (void)animateAdjustingToolbarAndTableViewForKeyboardNotification:(NSNotification *)notification {
  // Don't use a block based animation here as it stopped working with iOS 7. More info: http://stackoverflow.com/questions/18837166/how-to-mimic-keyboard-animation-on-ios-7-to-add-done-button-to-numeric-keyboar/19235995#19235995
  
  [self.view layoutIfNeeded]; // Ensure all pending animations have been completed
  
  [CATransaction begin];
  [UIView beginAnimations:nil context:nil];
  CGFloat duration = [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  [UIView setAnimationDuration:duration];
  [UIView setAnimationCurve:[[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue]];
  [UIView setAnimationBeginsFromCurrentState:YES];
  CGFloat margin = 0.f;
  if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
    margin = self.originalKeyboardHeight = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
  }
  [self adjustTableViewWithBottomMargin:margin];
  [self adjustToolbarWithBottomMargin:margin];  
  [UIView commitAnimations];
  [CATransaction commit];
}

- (void)adjustToolbarWithBottomMargin:(CGFloat)margin {
  self.toolbarBottomConstraint.offset = -margin;
  [self.view layoutIfNeeded];
}

- (void)adjustTableViewWithBottomMargin:(CGFloat)margin {
  // Adjusting the contentInset allows us to not worry about adjusting auto layout constraints
  UIEdgeInsets contentInset = self.tableView.contentInset;
  if (margin == 0.f) {
    // The keyboard is hiding, so we should reset the insets
    contentInset.bottom -= self.originalKeyboardHeight;
  } else {
    // The keyboard is showing, so we should add it's height to the current margin
    contentInset.bottom += margin;
  }
  self.tableView.contentInset = self.tableView.scrollIndicatorInsets = contentInset;
}

- (void)keyboardWillShow:(NSNotification *)notification {
  if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
    [self animateAdjustingToolbarAndTableViewForKeyboardNotification:notification];
  }
}

- (void)keyboardWillHide:(NSNotification *)notification {
  if ([notification.name isEqualToString:UIKeyboardWillHideNotification]) {
    [self animateAdjustingToolbarAndTableViewForKeyboardNotification:notification];
  }
}

- (void)scrollToBottomOfTableView {
  CGFloat yOffset = self.tableView.contentSize.height + self.tableView.contentInset.bottom - self.tableView.frame.size.height;
  if (yOffset > 0) {
    // This needs to be done after a small delay on the run loop so it happens after the table content size has changed
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [self.tableView setContentOffset:CGPointMake(0, yOffset) animated:YES];
    });
  }
}

- (void)updateSendButtonState {
  BOOL isEmpty = (self.commentTextView.text.length == 0);
  self.sendButton.backgroundColor = isEmpty ? kColorDivider : kColorTeal;
  self.sendButton.enabled = !isEmpty;
}

#pragma mark - Loading Data

- (void)loadAllComments {
  [self loadCommentsWithCurrentOffsetAndLimit];
}

- (void)loadLatest4Comments {
  self.pagingOffset = 0;
  self.createdBefore = [NSDate date];
  self.pagingLimit = kEvstNumberOfCommentsInitiallyShown;
  [self loadCommentsWithCurrentOffsetAndLimit];
}

- (void)loadCommentsWithCurrentOffsetAndLimit {
  [EvstCommentsEndPoint getCommentsForMoment:self.moment beforeDate:self.createdBefore offset:self.pagingOffset limit:self.pagingLimit success:^(NSArray *comments) {
    if (self.pagingOffset == 0) {
      self.didLoadInitialComments = YES;
      self.pagingOffset = kEvstNumberOfCommentsInitiallyShown;
      self.pagingLimit = self.moment.commentsCount - kEvstNumberOfCommentsInitiallyShown;
      
      [self.comments addObjectsFromArray:comments];
      [self.tableView reloadData];
      // Since infinite scrolling only loads the most recent comments, we can safely disable it after the first time
      // it's used and then we'll rely on using the "load all comments" table cell when implemented
      self.tableView.showsInfiniteScrolling = NO;
    } else {
      self.didLoadAllComments = YES;
      if (comments.count == 0) {
        // Rare situation, but all comments could be deleted by the time they press this button, so we just need to reload the table to get rid of the load all comments button
        [self.tableView reloadData];
      } else {
        [self.tableView batchInsertCommentsToTopOfMutableArray:self.comments withNewItemsArray:comments];
      }
    }
  } failure:^(NSString *errorMsg) {
    [self.tableView.infiniteScrollingView stopAnimating];
    [EvstCommon showAlertViewWithErrorMessage:errorMsg];
  }];
}

- (void)setupInfiniteScrolling {
  dispatch_once(&_onceTokenInfScroll, ^{
    if (self.moment.commentsCount == 0) {
      self.tableView.infiniteScrollingView.enabled = NO;
      return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self.tableView addInfiniteScrollingWithActionHandler:^{
      // Infinite scrolling is only used to show network status and to load the 4 latest comments, then it's disabled
      [weakSelf loadLatest4Comments];
    }];
    [self.tableView triggerInfiniteScrolling];
  });
}

#pragma mark - Comment creation

- (void)createComment {
  self.sendButton.enabled = NO;
  self.sendButton.alpha = 0.5f;
  
  EverestComment *comment = [[EverestComment alloc] init];
  [self.commentTextView trimText];
  if (self.commentTextView.text.length == 0) {
    [self updateSendButtonState];
    self.sendButton.enabled = YES;
    self.sendButton.alpha = 1.f;
    return;
  }
  
  comment.content = self.commentTextView.text;
  [EvstCommentsEndPoint createNewComment:comment onMoment:self.moment success:^(EverestComment *newComment) {
    self.sendButton.enabled = YES;
    self.sendButton.alpha = 1.f;
    
    self.moment.commentsCount++;
    [[NSNotificationCenter defaultCenter] postNotificationName:kEvstMomentCommentCountWasChangedNotification object:self.moment];
    
    // Per design, we shouldn't hide the keyboard after a new comment is created
    self.commentTextView.text = @"";
    [self updateSendButtonState];
    
    // To account for the slight difference between server time and client time,
    // let's overwrite the server's date here for new comments
    newComment.createdAt = [NSDate date];
    
    // Per design, the only time we should auto scroll to the bottom of the table is when we add the new comment
    [self insertNewCommentAndScrollToBottom:newComment];
  } failure:^(NSString *errorMsg) {
    self.sendButton.enabled = YES;
    self.sendButton.alpha = 1.f;
    [EvstCommon showAlertViewWithErrorMessage:errorMsg];
  }];
}

- (void)insertNewCommentAndScrollToBottom:(EverestComment *)newComment {
  [self.comments addObject:newComment];
  NSUInteger newRow = self.showingLoadPreviousCommentsButton ? self.comments.count : self.comments.count - 1;
  
  [CATransaction begin];
  [CATransaction setCompletionBlock:^{
    // This has to be called on the main thread, otherwise it will return an old content offset for the table view
    dispatch_async(dispatch_get_main_queue(), ^{
      [self scrollToBottomOfTableView];
    });
  }];
  [self.tableView beginUpdates];
  [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:newRow inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
  [self.tableView endUpdates];
  [CATransaction commit];
}

#pragma mark - IBActions

- (IBAction)likeButtonTapped:(UIButton *)sender {
  NSDictionary *info = @{kEvstDictionaryMomentKey : self.moment,
                         kEvstDictionaryButtonKey : sender };
  [[NSNotificationCenter defaultCenter] postNotificationName:kEvstLikeButtonWasPressedNotification object:nil userInfo:info];
}

- (IBAction)didPressOptionsButton:(id)sender {
  [self.commentTextView resignFirstResponder];
  [self showMomentOptionsSheet:nil];
}

- (IBAction)sendCommentButtonTapped:(id)sender {
  [self createComment];
}

- (IBAction)showMomentOptionsSheet:(id)sender {
  UIActionSheet *actionSheet;
  if (self.moment.user.isCurrentUser || [EvstAPIClient currentUser].isYeti) {
    if (self.moment.journey.isPrivate == NO && self.moment.isLifecycleMoment) {
      actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:kLocaleCancel destructiveButtonTitle:nil otherButtonTitles:kLocaleShareToFacebook, kLocaleShareToTwitter, kLocaleCopyLink, nil];
    } else if (self.moment.journey.isPrivate) {
      actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:kLocaleCancel destructiveButtonTitle:kLocaleDeleteMoment otherButtonTitles:kLocaleEditMoment, nil];
    } else {
      actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:kLocaleCancel destructiveButtonTitle:kLocaleDeleteMoment otherButtonTitles:kLocaleEditMoment, kLocaleShareToFacebook, kLocaleShareToTwitter, kLocaleCopyLink, nil];
    }
  } else {
    actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:kLocaleCancel destructiveButtonTitle:nil otherButtonTitles:kLocaleShareToFacebook, kLocaleShareToTwitter, kLocaleCopyLink, nil];
  }
  actionSheet.accessibilityLabel = kLocaleMomentOptions;
  [actionSheet showFromRect:self.addCommentToolbar.frame inView:self.view animated:YES];
}

#pragma mark - UITextViewDelegate & EvstGrowingTextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
  if (textView.text.length > kEvstCommentContentMaxLength && text.length) {
    return NO;
  }
  return YES;
}

- (void)growingTextView:(EvstGrowingTextView *)textView didGrowByHeight:(CGFloat)height {
  UIEdgeInsets contentInsets = self.tableView.contentInset;
  contentInsets.bottom += height;
  self.tableView.contentInset = self.tableView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([self showLoadPreviousCommentsButtonForIndexPath:indexPath]) {
    return NO; // Don't let them delete the load previous comments cell
  }
  
  EverestComment *comment = [self.comments objectAtIndex: self.showingLoadPreviousCommentsButton ? indexPath.row - 1 : indexPath.row];
  if (comment.user.isCurrentUser || [EvstAPIClient currentUser].isYeti) {
    return YES; // Always allow users to delete their own comments
  }
  // Else, check if the user owns this moment, and if they do, allow them to remove any comments from it
  return self.moment.user.isCurrentUser;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([self showLoadPreviousCommentsButtonForIndexPath:indexPath]) {
    return; // Don't let them delete the load previous comments cell
  }
  
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    [EvstCommentsEndPoint deleteComment:[self.comments objectAtIndex: self.showingLoadPreviousCommentsButton ? indexPath.row - 1 : indexPath.row] success:^{
      self.moment.commentsCount--;
      [[NSNotificationCenter defaultCenter] postNotificationName:kEvstMomentCommentCountWasChangedNotification object:self.moment];
      
      [self.comments removeObjectAtIndex: self.showingLoadPreviousCommentsButton ? indexPath.row - 1 : indexPath.row];
      [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } failure:^(NSString *errorMsg) {
      [EvstCommon showAlertViewWithErrorMessage:errorMsg];
    }];
  }
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([self showLoadPreviousCommentsButtonForIndexPath:indexPath]) {
    return kEvstLoadAllCommentsRowHeight;
  }
  
  return [EvstCommentCell cellHeightForComment:[self.comments objectAtIndex: self.showingLoadPreviousCommentsButton ? indexPath.row - 1 : indexPath.row]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (self.showingLoadPreviousCommentsButton == NO && self.comments.count == 0) {
    return 0;
  }
  
  return self.showingLoadPreviousCommentsButton ? self.comments.count + 1 : self.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([self showLoadPreviousCommentsButtonForIndexPath:indexPath]) {
    EvstLoadAllCommentsCell *loadAllCommentsCell = [tableView dequeueReusableCellWithIdentifier:EvstLoadAllCommentsCellIdentifier forIndexPath:indexPath];
    loadAllCommentsCell.moment = self.moment;
    loadAllCommentsCell.separatorInset = UIEdgeInsetsMake(0, 0, 0, loadAllCommentsCell.bounds.size.width);
    loadAllCommentsCell.loadAllCommentsButton.enabled = self.didLoadInitialComments;
    return loadAllCommentsCell;
  }
  
  EvstCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:EvstCommentCellIdentifier forIndexPath:indexPath];
  [cell configureWithComment:[self.comments objectAtIndex: self.showingLoadPreviousCommentsButton ? indexPath.row - 1 : indexPath.row]];
  return cell;
}

#pragma mark - Convenience Methods

// Once the button has been shown once, the value should never change, unless they explicitly have loaded the comments
- (BOOL)showLoadPreviousCommentsButtonForIndexPath:(NSIndexPath *)indexPath {
  return (indexPath.row == 0) && self.showingLoadPreviousCommentsButton;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == actionSheet.cancelButtonIndex) {
    return;
  }
  
  if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kLocaleEditMoment]) {
    EvstMomentFormViewController *momentFormVC = [[EvstMomentFormViewController alloc] init];
    momentFormVC.momentToEdit = self.moment;
    EvstGrayNavigationController *navVC = [[EvstGrayNavigationController alloc] initWithRootViewController:momentFormVC];
    [self presentViewController:navVC animated:YES completion:nil];
    
    [EvstAnalytics trackView:kEvstAnalyticsDidViewEditMoment objectUUID:self.moment.uuid];
  } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kLocaleShareToFacebook]) {
    [EvstFacebook shareMoment:self.moment fromViewController:self completion:nil];
    
    [EvstAnalytics trackShareFromSource:kEvstAnalyticsComments withDestination:kEvstAnalyticsFacebook type:kEvstAnalyticsMoment];
  } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kLocaleShareToTwitter]) {
    [EvstTwitter shareMoment:self.moment fromViewController:self completion:nil];
    
    [EvstAnalytics trackShareFromSource:kEvstAnalyticsComments withDestination:kEvstAnalyticsTwitter type:kEvstAnalyticsMoment];
  } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kLocaleCopyLink]) {
    [UIPasteboard generalPasteboard].string = self.moment.webURL;
    [SVProgressHUD showSuccessWithStatus:kLocaleCopied];
    
    [EvstAnalytics trackShareFromSource:kEvstAnalyticsComments withDestination:kEvstAnalyticsCopyLink type:kEvstAnalyticsMoment];
  } else if (buttonIndex == actionSheet.destructiveButtonIndex) {
    [[[UIAlertView alloc] initWithTitle:kLocaleConfirm message:kLocaleConfirmDeleteMomentMessage delegate:self cancelButtonTitle:kLocaleCancel otherButtonTitles:kLocaleDelete, nil] show];
  }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == alertView.cancelButtonIndex) {
    return;
  }
  
  if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:kLocaleDelete]) {
    [EvstMomentsEndPoint deleteMoment:self.moment success:^{
      [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSString *errorMsg) {
      [EvstCommon showAlertViewWithErrorMessage:errorMsg];
    }];
  }
}

@end
