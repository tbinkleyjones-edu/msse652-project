//
//  SocialMediaSvc.h
//  SCIS
//
//  Created by Tim Binkley-Jones on 8/2/14.
//  Copyright (c) 2014 msse652. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * The SocialMediaSvc wraps calls to UIActivityViewController, SLComposeViewController, and SLRequest.
 */
@interface SocialMediaSvc : NSObject

/** 
 * Share a message using UIActivityViewController. The message is constructed form
 * the provided message and URL. The user will be able to alter the message before it is sent. 
 * The user may choose not to send the message.
 */
+ (void) shareMessage:(NSString *)message andUrl:(NSURL *)url fromViewController:(UIViewController*) viewController;

/**
 * Update Facebook status using SLComposeViewController. The message is constructed form
 * the provided message and URL. The user will be able to alter the message before it is sent. 
 * The user may choose not to send the message.
 */
+ (void) updateFacebookWithMessage:(NSString *)message andUrl:(NSURL *)url fromViewController:(UIViewController*) viewController;

/**
 * Send a Twitter tweet using SLComposeViewController. The message is constructed form
 * the provided message and URL. The user will be able to alter the message before it is sent. 
 * The user may choose not to send the message.
 */
+ (void) tweetMessage:(NSString *)message  andUrl:(NSURL *)url fromViewController:(UIViewController*) viewController;

/**
 * Retrieve an array of recent Twitter tweets matching the given query. The completion block
 * is passed an array of SocialMediaStatus objects, or nil if the request failed. 
 * The completion block executes on the UI thread.
 */
+ (void) fetchTweetsUsingQuery:(NSString *)query completion:(void(^)(NSArray *))completion;

@end
