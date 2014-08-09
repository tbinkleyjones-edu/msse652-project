//
//  SocialMediaSvc.m
//  SCIS
//
//  Created by Tim Binkley-Jones on 8/2/14.
//  Copyright (c) 2014 msse652. All rights reserved.
//

#import "SocialMediaSvc.h"
#import "SocialMediaStatus.h"

@implementation SocialMediaSvc

+ (void) shareMessage:(NSString *)message andUrl:(NSURL *)url fromViewController:(UIViewController*) viewController {
    // Send NSString and NSURL items. UIActivityViewController will present an list of
    // activities that accept a string and/or a url. If facebook, twitter or other social
    // media apps are configured, they will appear in the list of activities, as will email, copy, print, etc.
    NSArray *activityItems = @[message, url];
    UIActivityViewController *activityController =[[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [viewController presentViewController:activityController animated:YES completion:nil];
}

+ (void) updateFacebookWithMessage:(NSString *)message andUrl:(NSURL *)url fromViewController:(UIViewController *)viewController {
    [SocialMediaSvc composeMessage:message andUrl:url fromViewController:viewController forServiceType:SLServiceTypeFacebook];
}

+ (void) tweetMessage:(NSString *)message andUrl:(NSURL *)url fromViewController:(UIViewController *)viewController {
    [SocialMediaSvc composeMessage:message andUrl:url fromViewController:viewController forServiceType:SLServiceTypeTwitter];
}

/**
 * Compose a social media message using SLComposeViewController. The message is constructed form
 * the provided message and URL and sent to the specified service type.
 */
+ (void) composeMessage:(NSString *)message andUrl:(NSURL *)url fromViewController:(UIViewController*) viewController forServiceType:(NSString *)serviceType {
    // Check that the specified serivce is configured. If not, do nothing.
    if ([SLComposeViewController isAvailableForServiceType:serviceType])
    {
        // Device is able to send a Twitter message
        SLComposeViewController *composeController = [SLComposeViewController composeViewControllerForServiceType:serviceType];

        [composeController setInitialText:message];
        [composeController addURL: url];

        [viewController presentViewController:composeController animated:YES completion:nil];
    }
}

+ (void) fetchTweetsUsingQuery:(NSString *) query completion:(void(^)(NSArray *))completion {
    // Check that Twitter is configured. If not, do nothing.
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        // Asynchronously get the twitter account managed by the operating system. The account credentials are required by the Twitter API.
        // If not provided, The request will fail.
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        ACAccountType *twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        [accountStore requestAccessToAccountsWithType:twitterAccountType options:NULL completion:^(BOOL granted, NSError *error) {
            if (granted) {
                NSLog(@"Sending request");
                // Create the request with the twitter account, the Twitter API URL for searching, and URL params containing the search.
                NSArray *twitterAccounts = [accountStore accountsWithAccountType:twitterAccountType];
                NSURL *url = [NSURL URLWithString:@"https://api.twitter.com" @"/1.1/search/tweets.json"];
                NSDictionary *params = @{
                    @"q" : query,
                    @"resultl_type": @"recent"
                };

                SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:params];

                // Attach the user's twitter account to the request
                [request setAccount:[twitterAccounts lastObject]];

                // Asynchronously execute the request
                [request performRequestWithHandler: ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    NSArray *results = nil;
                    if (responseData) {
                        if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                            results = [SocialMediaSvc parseTwitterQueryResponseData: responseData];
                        } else {
                            // an error occured, complete with nil (i.e. leave results as is)
                            NSLog(@"The response status code is %ld", (long)urlResponse.statusCode);
                        }
                    }
                    // complete with results
                    [SocialMediaSvc completeOnUIThread:results completion:completion];
                }];
            } else {
                // Access was not granted to the twitter account, or an error occurred. Complete with nil.
                NSLog(@"%@", [error localizedDescription]);
                [SocialMediaSvc completeOnUIThread:nil completion:completion];
            }
        }];
    } else {
        // Complete immediately with nil;
        NSLog(@"Twitter is not available");
        [SocialMediaSvc completeOnUIThread:nil completion:completion];
    }
}

/** 
 * Parse the JSON document returned from Twitter. Specifically, find the status text, and username
 * located at statuses[i].text and statuses[i].user.name.
 */
+ (NSArray*)parseTwitterQueryResponseData:(NSData *)responseData {
    NSMutableArray *results = [[NSMutableArray alloc] init];
    //NSLog(@"%@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);

    NSError *jsonError;
    NSDictionary *twitterResponse = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&jsonError];
    if (twitterResponse) {
        //NSLog(@"Twitter Response: %@\n", twitterResponse);
        NSArray *statuses = [twitterResponse objectForKey:@"statuses"];
        for ( id status in statuses) {
            SocialMediaStatus *tweet = [[SocialMediaStatus alloc] init];
            tweet.text = [status objectForKey:@"text"];
            tweet.name = [[status objectForKey:@"user"] objectForKey:@"name"];
            [results addObject:tweet];
        }
    } else {
        // Our JSON deserialization went awry
        NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
    }
    return results;
}

/**
 * Sends the provided results to the provided completion block. Executes the completion block on the UI thread.
 */
+ (void)completeOnUIThread:(NSArray *)results completion:(void(^)(NSArray *))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        completion(results);
    });
}

@end
