//
//  EvstLocalizedSocialSharing.h
//  Everest
//
//  Created by Rob Phillips on 12/5/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

// All localized strings relating to social networks or sharing

// General
#define kLocaleAuthorizing                      NSLocalizedString(@"Authorizing...", nil) // TRANSLATE
#define kLocaleLinking                          NSLocalizedString(@"Linking...", @"Linking a user's social account")
#define kLocaleUnlinking                        NSLocalizedString(@"Unlinking...", @"Unlinking a user's social account")
#define kLocaleChooseAccount                    NSLocalizedString(@"Choose account", @"choose a social network account to link with")
#define kLocaleWhichAccountHeader               NSLocalizedString(@"Which account would you like to use to share your Everest activity?", nil)

// Facebook
#define kLocaleFacebook                         NSLocalizedString(@"Facebook", nil) // DO NOT TRANSLATE
#define kLocaleCannotAccessFacebookAccount      NSLocalizedString(@"Cannot access Facebook accounts", nil)
#define kLocaleLaunchSettingsAppForFacebook     NSLocalizedString(@"To use your Facebook account with this app, launch the Settings app -> Facebook and make sure this app is turned on.", nil)
#define kLocaleCurrentFacebookSessionIsInvalid  NSLocalizedString(@"Your current Facebook session is no longer valid. Please try again.", nil)
#define kLocaleFacebookAuthenticationError      NSLocalizedString(@"There was an error authenticating with Facebook (their service might be down or you cancelled).  Please try again later.", nil)
#define kLocalePleaseRetryFacebookErrorFormat   NSLocalizedString(@"Please retry.\n\nIf the problem persists, please contact us and mention this Facebook error code: %@", nil)

#define kLocaleErrorLinkingFacebook             NSLocalizedString(@"Error occurred while linking your Facebook account to Everest", nil)
#define kLocaleInviteFacebookFriend             NSLocalizedString(@"I'd like to share my Journeys and goals with you. See my Journey on Everest.", nil)

// Twitter
#define kLocaleTwitter                          NSLocalizedString(@"Twitter", nil) // DO NOT TRANSLATE
#define kLocaleTwitterAccountNotLinked          NSLocalizedString(@"You have not linked your Twitter account.", nil)
#define kLocaleTwitterAccountsDoNotMatch        NSLocalizedString(@"The account you authorized on Twitter (@%@) does not match the account you originally chose to link with (@%@).", @"twitter accounts don't match")
#define kLocaleTwitterAuthenticationError       NSLocalizedString(@"There was an error authenticating with Twitter (their service might be down or you cancelled).  Please try again later.", nil)
#define kLocaleLaunchSettingsAppForTwitter      NSLocalizedString(@"To use your Twitter account with this app, launch the Settings app -> Twitter and make sure this app is turned on.", @"user needs to grant Everest access in their device settings")

// Sharing & Invites
#define kLocaleTapToInviteFriendsBanner               NSLocalizedString(@"Tap to invite your friends and find weekly featured people!", nil) // TRANSLATE
#define kLocaleEverestIsBetterWithFriendsBanner       NSLocalizedString(@"Everest is better with friends! Invite them with a simple text!", nil) // TRANSLATE
#define kLocaleDeviceDoesntSupportSMS                 NSLocalizedString(@"Your device doesn't support SMS, but you can tell your friends to download Everest at http://download.everest.com instead!", nil) // TRANSLATE
#define kLocaleSMSFailedToSend                        NSLocalizedString(@"Looks like the SMS failed to send, but it will be queued to send again when available!", nil) // TRANSLATE
#define kLocaleSMSBodyMessage                         NSLocalizedString(@"Every journey on Everest tells a story about a different part of your life. Download it so I can follow your journeys: http://download.everest.com", nil) // TRANSLATE

