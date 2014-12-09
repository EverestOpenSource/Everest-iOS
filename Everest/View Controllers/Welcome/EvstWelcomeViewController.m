//
//  EvstWelcomeViewController.m
//  Everest
//
//  Created by Chris Cornelis on 01/10/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import "EvstWelcomeViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UIView+EvstAdditions.h"
#import "EvstSessionsEndPoint.h"
#import "EvstKnockoutButton.h"
#import "EvstSignUpViewController.h"
#import "EvstLoginViewController.h"
#import "EvstWebViewController.h"

static CGFloat const kEvstWhiteAreaAlpha = 0.9f;

@interface EvstWelcomeViewController()
@property (nonatomic, weak) IBOutlet UIView *videoView;
@property (nonatomic, weak) IBOutlet UIButton *loginButton;
@property (nonatomic, weak) IBOutlet UIImageView *everestLogoImageView;
@property (nonatomic, strong) UILabel *oneLifeLabel;
@property (nonatomic, strong) TTTAttributedLabel *valuePropLabel;
@property (nonatomic, strong) UIImageView *whiteBannerImageView;
@property (nonatomic, strong) EvstKnockoutButton *signInWithFacebookButton;
@property (nonatomic, strong) EvstKnockoutButton *signUpWithEmailButton;
@property (nonatomic, strong) TTTAttributedLabel *termsOfServiceLabel;

@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
@end

@implementation EvstWelcomeViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self registerForDidLoadNotifications];
  self.navigationItem.title = kLocaleWelcome;
  [self setupViews];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self registerForWillAppearNotifications];
  [self.moviePlayer play];
  
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
  self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [self seriallyFadeInView];
  
  [EvstAnalytics track:kEvstAnalyticsDidViewWelcome];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [self unregisterWillAppearNotifications];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  
  [self.moviePlayer stop];
}

- (void)dealloc {
  [self unregisterNotifications];
}

#pragma mark - Setup

- (void)setupViews {
  [self setupMovie];
  [self setupLoginButton];
  [self setupValuePropArea];
  [self setupSignupButtonsArea];
}

- (void)setupMovie {
  NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"welcome_video" ofType:@"mp4"];
  NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
  self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
  self.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
  self.moviePlayer.controlStyle = MPMovieControlStyleNone;
  [self.videoView addSubview:self.moviePlayer.view];
  self.moviePlayer.view.frame = self.videoView.bounds;
  self.moviePlayer.view.accessibilityLabel = kLocaleWelcomeVideo;
  [self.moviePlayer prepareToPlay];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlaybackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
}

- (void)setupLoginButton {
  [self.loginButton setTitle:kLocaleLogin forState:UIControlStateNormal];
  self.loginButton.alpha = 0.f;
  self.loginButton.accessibilityLabel = kLocaleLogin;
  [self.loginButton fullyRoundCornersWithBorderWidth:1.f borderColor:kColorWhite];
  [self.loginButton addTarget:self action:@selector(loginButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupValuePropArea {
  self.oneLifeLabel = [[UILabel alloc] init];
  self.oneLifeLabel.alpha = 0.f;
  self.oneLifeLabel.font = kFontTrumpGothicEastMedium27;
  self.oneLifeLabel.textColor = kColorWhite;
  self.oneLifeLabel.textAlignment = NSTextAlignmentCenter;
  self.oneLifeLabel.attributedText = [[NSAttributedString alloc] initWithString:kLocaleOneLifeManyJourneysAllCaps attributes:@{NSKernAttributeName : [NSNumber numberWithDouble:kEvstTrumpGothicEastMediumKerning]}];
  self.oneLifeLabel.accessibilityLabel = kLocaleOneLifeManyJourneysAllCaps;
  [self.view addSubview:self.oneLifeLabel];
  [self.oneLifeLabel makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.view.left).offset(kEvstDefaultPadding);
    make.right.equalTo(self.view.right).offset(-kEvstDefaultPadding);
    make.bottom.equalTo(self.view.bottom).offset(-165.f);
    make.height.equalTo(@32);
  }];
  
  self.valuePropLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
  self.valuePropLabel.alpha = 0.f;
  self.valuePropLabel.numberOfLines = 0;
  self.valuePropLabel.font = kFontHelveticaNeueLight12;
  self.valuePropLabel.textColor = kColorWhite;
  self.valuePropLabel.textAlignment = NSTextAlignmentCenter;
  self.valuePropLabel.lineHeightMultiple = 1.1f;
  self.valuePropLabel.kern = 0.2f;
  self.valuePropLabel.accessibilityLabel = kLocaleWelcomeValueProp;
  [self.valuePropLabel setText:kLocaleWelcomeValueProp];
  [self.view addSubview:self.valuePropLabel];
  [self.valuePropLabel makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.oneLifeLabel.bottom).offset(3.f);
    make.left.equalTo(self.view.left).offset(kEvstDefaultPadding);
    make.right.equalTo(self.view.right).offset(-kEvstDefaultPadding);
  }];
}

- (void)setupSignupButtonsArea {
  self.whiteBannerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Welcome White Banner"]];
  self.whiteBannerImageView.alpha = 0.f;
  [self.view addSubview:self.whiteBannerImageView];
  [self.whiteBannerImageView makeConstraints:^(MASConstraintMaker *make) {
    make.bottom.equalTo(self.view.bottom);
  }];
  
  self.signInWithFacebookButton = [[EvstKnockoutButton alloc] init];
  self.signInWithFacebookButton.alpha = 0.f;
  self.signInWithFacebookButton.titleLabel.font = kFontHelveticaNeue12;
  self.signInWithFacebookButton.titleLabel.textAlignment = NSTextAlignmentCenter;
  self.signInWithFacebookButton.knockoutText = self.signInWithFacebookButton.accessibilityLabel = kLocaleSignInWithFacebook;
  self.signInWithFacebookButton.backgroundColor = kColorWhite;
  [self.signInWithFacebookButton roundCornersWithRadius:3.f];
  [self.signInWithFacebookButton addTarget:self action:@selector(signInWithFacebook:) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:self.signInWithFacebookButton];
  [self.signInWithFacebookButton makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.whiteBannerImageView.top).offset(15.f);
    make.left.equalTo(self.whiteBannerImageView.left).offset(11.f);
    make.width.equalTo([NSNumber numberWithDouble:kEvstSignInButtonWidth]);
    make.height.equalTo([NSNumber numberWithDouble:kEvstSignInButtonHeight]);
  }];
  
  self.signUpWithEmailButton = [[EvstKnockoutButton alloc] init];
  self.signUpWithEmailButton.alpha = 0.f;
  self.signUpWithEmailButton.titleLabel.font = kFontHelveticaNeue12;
  self.signUpWithEmailButton.titleLabel.textAlignment = NSTextAlignmentCenter;
  self.signUpWithEmailButton.knockoutText = self.signUpWithEmailButton.accessibilityLabel = kLocaleSignUpWithEmail;
  self.signUpWithEmailButton.backgroundColor = kColorWhite;
  [self.signUpWithEmailButton roundCornersWithRadius:3.f];
  [self.signUpWithEmailButton addTarget:self action:@selector(signUpWithEmailButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:self.signUpWithEmailButton];
  [self.signUpWithEmailButton makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.signInWithFacebookButton.top);
    make.left.equalTo(self.whiteBannerImageView.left).offset(166.f);
    make.width.equalTo([NSNumber numberWithDouble:kEvstSignInButtonWidth]);
    make.height.equalTo([NSNumber numberWithDouble:kEvstSignInButtonHeight]);
  }];
  
  // Legal labels and buttons
  UIColor *tosBlack = [UIColor colorWithWhite:63.f/255.f alpha:1.f];
  self.termsOfServiceLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
  self.termsOfServiceLabel.font = kFontHelveticaNeue7;
  self.termsOfServiceLabel.delegate = self;
  self.termsOfServiceLabel.textColor = tosBlack;
  self.termsOfServiceLabel.textAlignment = NSTextAlignmentCenter;
  self.termsOfServiceLabel.alpha = 0.f;
  NSString *legalString = [NSString stringWithFormat:kLocalePrivacyPolicyAndTermsOfService, kLocalePrivacyPolicy, kLocaleTermsOfService];
  self.termsOfServiceLabel.activeLinkAttributes = nil;
  self.termsOfServiceLabel.linkAttributes = @{(id)kCTForegroundColorAttributeName : tosBlack,
                                              (id)kCTUnderlineStyleAttributeName : [NSNumber numberWithInt:kCTUnderlineStyleNone],
                                              (NSString *)kCTFontAttributeName: (id)kFontHelveticaNeueBold7};
  [self.termsOfServiceLabel setText:legalString];
  self.termsOfServiceLabel.accessibilityLabel = legalString;
  [self.view addSubview:self.termsOfServiceLabel];
  [self.termsOfServiceLabel makeConstraints:^(MASConstraintMaker *make) {
    make.bottom.equalTo(self.whiteBannerImageView.bottom).offset(-10.f);
    make.left.equalTo(self.view.left);
    make.right.equalTo(self.view.right);
  }];
  
  // Links
  [self.termsOfServiceLabel addLinkToURL:[NSURL URLWithString:kEvstTermsOfServiceURL] withRange:[legalString rangeOfString:kLocaleTermsOfService]];
  [self.termsOfServiceLabel addLinkToURL:[NSURL URLWithString:kEvstPrivacyPolicyURL] withRange:[legalString rangeOfString:kLocalePrivacyPolicy]];
}

#pragma mark - Serially Fading In View

- (void)seriallyFadeInView {
  [self.moviePlayer play];
  
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [UIView animateWithDuration:1.f animations:^{
      self.oneLifeLabel.alpha = 1.f;
    } completion:^(BOOL finished) {
      [UIView animateWithDuration:1.f animations:^{
        self.loginButton.alpha = 1.f;
        self.whiteBannerImageView.alpha = self.signInWithFacebookButton.alpha = self.signUpWithEmailButton.alpha = self.termsOfServiceLabel.alpha = kEvstWhiteAreaAlpha;
      } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
          [UIView animateWithDuration:1.f animations:^{
            self.valuePropLabel.alpha = 1.f;
          }];
        });
      }];
    }];
  });
}

#pragma mark - IBActions

- (IBAction)moviePlaybackDidFinish:(id)sender {
  [self.moviePlayer play];
}

- (IBAction)signInWithFacebook:(id)sender {
  [EvstFacebook selectFacebookAccountFromViewController:self withPermissions:[EvstFacebook readOnlyPermissions] linkWithEverest:NO success:^(ACAccount *facebookAccount) {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [EvstFacebook getActiveFacebookUserInfoAndSignInWithSuccess:^(EverestUser *user) {
      [SVProgressHUD dismiss];
    } failure:^(NSString *errorMsg) {
      [SVProgressHUD dismiss];
      [EvstCommon showAlertViewWithErrorMessage:errorMsg];
    }];
  } failure:^(NSString *errorMsg) {
    [SVProgressHUD dismiss];
    [EvstCommon showAlertViewWithErrorMessage:errorMsg];
  } cancel:nil];
}

- (IBAction)loginButtonTapped:(id)sender {
  [self setupBackButton];
  EvstLoginViewController *loginVC = [[EvstCommon storyboard] instantiateViewControllerWithIdentifier:@"EvstLoginViewController"];
  [self.navigationController pushViewController:loginVC animated:YES];
}

- (IBAction)signUpWithEmailButtonTapped:(id)sender {
  [self setupBackButton];
  EvstSignUpViewController *signUpVC = [[EvstCommon storyboard] instantiateViewControllerWithIdentifier:@"EvstSignUpViewController"];
  [self.navigationController pushViewController:signUpVC animated:YES];
}

#pragma mark - Notifications

- (void)registerForDidLoadNotifications {
  // Ensure the video gets restarted if it's paused by backgrounding the app
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unpauseMovie:) name:kEvstDidBecomeActiveNotification object:nil];
}

- (void)registerForWillAppearNotifications {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)unregisterWillAppearNotifications {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)unpauseMovie:(NSNotification *)notification {
  if ([notification.name isEqualToString:kEvstDidBecomeActiveNotification]) {
    [self.moviePlayer play];
  }
}

- (void)didBecomeActive:(NSNotification *)notification {
  if ([notification.name isEqualToString:UIApplicationDidBecomeActiveNotification]) {
    // Hide any HUDs left over from cancelled FB auth flow
    [SVProgressHUD cancelOrDismiss];
  }
}

#pragma mark TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
  [EvstWebViewController presentWithURL:url inViewController:self];
}

@end
