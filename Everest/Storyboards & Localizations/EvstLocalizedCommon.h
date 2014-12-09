//
//  EvstLocalizedCommon.h
//  Everest
//
//  Created by Rob Phillips on 12/9/13.
//  Copyright (c) 2013 Evrst, Inc. (Everest). All rights reserved. See LICENCE for more information.
//

// All common or general localized strings (Note: this is not a dumping ground; please break strings out into logical headers)

#pragma mark - Common / General

#define kLocaleConfirm                          NSLocalizedString(@"Confirm", nil)
#define kLocaleSearch                           NSLocalizedString(@"Search", nil)
#define kLocaleSearchTheWeb                     NSLocalizedString(@"Search the web", nil) // TRANSLATED
#define kLocaleSearchBar                        NSLocalizedString(@"Search Bar", nil)
#define kLocaleBack                             NSLocalizedString(@"Back", nil)
#define kLocaleOK                               NSLocalizedString(@"OK", nil)
#define kLocaleInfo                             NSLocalizedString(@"Info", nil)
#define kLocaleError                            NSLocalizedString(@"Error", nil)
#define kLocaleDone                             NSLocalizedString(@"Done", nil)
#define kLocaleCancel                           NSLocalizedString(@"Cancel", nil)
#define kLocaleAdd                              NSLocalizedString(@"Add", nil)
#define kLocaleEdit                             NSLocalizedString(@"Edit", nil)
#define kLocaleDelete                           NSLocalizedString(@"Delete", nil)
#define kLocalePost                             NSLocalizedString(@"Post", nil)
#define kLocaleSave                             NSLocalizedString(@"Save", nil)
#define kLocaleSend                             NSLocalizedString(@"Send", nil)
#define kLocaleTakePhoto                        NSLocalizedString(@"Take photo", nil)
#define kLocaleChooseExisting                   NSLocalizedString(@"Choose existing", nil)
#define kLocaleShare                            NSLocalizedString(@"Share", nil) // TRANSLATE
#define kLocaleShareLink                        NSLocalizedString(@"Share Link", nil) // TRANSLATE
#define kLocaleShareToFacebook                  NSLocalizedString(@"Share to Facebook", nil)
#define kLocaleShareToTwitter                   NSLocalizedString(@"Share to Twitter", nil)
#define kLocaleCopyLink                         NSLocalizedString(@"Copy Link", nil)
#define kLocaleOpenInBrowser                    NSLocalizedString(@"Open In Browser", nil) // TRANSLATE
#define kLocaleBigAddMomentButton               NSLocalizedString(@"Big Add Moment Button", nil)
#define kLocaleOptions                          NSLocalizedString(@"Options", nil)
#define kLocaleCopied                           NSLocalizedString(@"Copied!", nil)

#pragma mark - Search

#define kLocaleSearchMoments                    NSLocalizedString(@"Search Moments", nil)
#define kLocaleSearchPeople                     NSLocalizedString(@"Search people", nil) // TRANSLATE UPDATE
#define kLocaleNoResults                        NSLocalizedString(@"No results", nil) // TRANSLATED

#pragma mark - Images

#define kLocalePhotoSearchResults               NSLocalizedString(@"Photo search results", nil) // Used in DZNPhotoPickerController
#define kLocalePhotoEditor                      NSLocalizedString(@"Photo editor", nil) 

#pragma mark - Errors

#define kLocaleBadFacebookCredentialsError      NSLocalizedString(@"We had an issue signing you in with that Facebook account.", nil) // TRANSLATED
#define kLocaleBadCredentialsError              NSLocalizedString(@"Incorrect email or password.", nil) // TRANSLATED
#define kLocale401Error                         NSLocalizedString(@"Hmm... it seems you don't have access to this.", nil) // TRANSLATED
#define kLocale500Error                         NSLocalizedString(@"Oops... looks like something went wrong.", nil) // TRANSLATED
#define kLocale404Error                         NSLocalizedString(@"Hmm... it looks like that item doesn't exist anymore or you don't have access to it.", nil) // TRANSLATED
#define kLocaleOops                             NSLocalizedString(@"Oops", nil) // TRANSLATE

#define kLocaleNoEmailAccountsOnDevice          NSLocalizedString(@"There are no email accounts setup on this device.  Please open your device settings and set one up first.", nil)
#define kLocaleErrorSendingEmail                NSLocalizedString(@"There was an error sending your email", nil)
#define kLocaleNoInternetConnection             NSLocalizedString(@"No Internet Connection", nil)
#define kLocaleUploadImageBackgroundError       NSLocalizedString(@"There was an error uploading your photo. Try keeping Everest open while it uploads.", nil) // TRANSLATED

#pragma mark - Relative Time

#define kLocaleXYearsFormat                     NSLocalizedString(@"%d years", nil)
#define kLocaleXYearFormat                      NSLocalizedString(@"%d year", nil)
#define kLocaleXMonthsFormat                    NSLocalizedString(@"%d months", nil)
#define kLocaleXMonthFormat                     NSLocalizedString(@"%d month", nil)
#define kLocaleXWeeksFormat                     NSLocalizedString(@"%d weeks", nil)
#define kLocaleXWeekFormat                      NSLocalizedString(@"%d week", nil)
#define kLocaleXDaysFormat                      NSLocalizedString(@"%d days", nil)
#define kLocaleXDayFormat                       NSLocalizedString(@"%d day", nil)
#define kLocaleXMinutesFormat                   NSLocalizedString(@"%d minutes", nil)
#define kLocaleXMinuteFormat                    NSLocalizedString(@"%d minute", nil)
#define kLocaleXHoursFormat                     NSLocalizedString(@"%d hours", nil)
#define kLocaleXHourFormat                      NSLocalizedString(@"%d hour", nil)
#define kLocaleXSecondsFormat                   NSLocalizedString(@"%d seconds", nil)
#define kLocaleXSecondFormat                    NSLocalizedString(@"%d second", nil)
#define kLocaleShortXWeeksFormat                NSLocalizedString(@"%dw", nil)
#define kLocaleShortXDaysFormat                 NSLocalizedString(@"%dd", nil)
#define kLocaleShortXMinutesFormat              NSLocalizedString(@"%dm", nil)
#define kLocaleShortXHoursFormat                NSLocalizedString(@"%dh", nil)
#define kLocaleShortXSecondsFormat              NSLocalizedString(@"%ds", nil)
#define kLocaleAgo                              NSLocalizedString(@"ago", nil)
