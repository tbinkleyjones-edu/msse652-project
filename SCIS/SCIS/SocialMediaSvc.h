//
//  SocialMediaSvc.h
//  SCIS
//
//  Created by Tim Binkley-Jones on 8/2/14.
//  Copyright (c) 2014 msse652. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SocialMediaSvc : NSObject

+ (void) postMessage:(NSString *)message andUrl:(NSURL *)url fromViewController:(UIViewController*) viewController;
+ (void) updateFacebookWithMessage:(NSString *)message andUrl:(NSURL *)url fromViewController:(UIViewController*) viewController;
+ (void) tweetMessage:(NSString *)message  andUrl:(NSURL *)url fromViewController:(UIViewController*) viewController;
+ (void) fetchTweetsUsingQuery:(NSString *)query completion:(void(^)(NSArray *))completion;

@end
