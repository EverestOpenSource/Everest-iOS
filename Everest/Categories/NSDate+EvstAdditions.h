//
//  NSDate+EvstAdditions.h
//  Everest
//
//  Created by Rob Phillips on 1/16/14.
//  Copyright (c) 2014 Everest, Inc. All rights reserved. See LICENCE for more information.
//

#import <Foundation/Foundation.h>

@interface NSDate (EvstAdditions)

/*!
 * Returns the relative time from now until this date as a long string (e.g. 22 minutes ago, yesterday)
 */
- (NSString *)relativeTimeLongString;

/*!
 * Returns the relative time from now until this date as a string (e.g. 22m, 1d)
 */
- (NSString *)relativeTimeShortString;

/*!
 * Returns the relative time between this date and the given date as a string (e.g. 22 minutes ago, yesterday, Tuesday)
 *\param date The date you want to calculate the time between
 */
- (NSString *)relativeTimeStringFromDate:(NSDate *)date;

/*!
 * Returns the relative time between this date and the given date as a string and and shows longer formats if the @c borderDate is within a prior year (e.g. 22 minutes ago, Dec 15, Mar 14, 2011)
 *\param date The date you want to calculate the time between
 *\param borderDate A date to check against to see if the date is still within this year or if it's in a prior year
 */
- (NSString *)relativeTimeStringFromDate:(NSDate *)date withBorderDate:(NSDate *)borderDate;

/*!
 * Returns the relative time between now and the given date as a string and and shows longer formats if the @c borderDate is within a prior year (e.g. 22 minutes ago, Dec 15, Mar 14, 2011)
 *\param borderDate A date to check against to see if the date is still within this year or if it's in a prior year
 *\param longStyle A @c BOOL specifying that you'd like the string to have a longer format
 */
- (NSString *)relativeTimeStringWithBorderDate:(NSDate *)borderDate longStyle:(BOOL)longStyle;


@end
