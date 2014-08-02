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

+ (void) postMessage:(NSString *)message andUrl:(NSURL *)url fromViewController:(UIViewController*) viewController {
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

+ (void) composeMessage:(NSString *)message andUrl:(NSURL *)url fromViewController:(UIViewController*) viewController forServiceType:(NSString *)serviceType {
    if ([SLComposeViewController isAvailableForServiceType:serviceType])
    {
        // Device is able to send a Twitter message
        SLComposeViewController *composeController = [SLComposeViewController composeViewControllerForServiceType:serviceType];

        [composeController setInitialText:message];
        //[composeController addImage:postImage.image];
        [composeController addURL: url];

        [viewController presentViewController:composeController animated:YES completion:nil];
    }
}

//@"%23thisisregis%20OR%20%40RegisUniversity%20OR%20%40regisunivcps"
+ (void) fetchTweetsUsingQuery:(NSString *) query completion:(void(^)(NSArray *))completion {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {

        // Get the twitter account managed by the operating system
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        ACAccountType *twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        [accountStore requestAccessToAccountsWithType:twitterAccountType options:NULL completion:^(BOOL granted, NSError *error) {
            if (granted) {
                //  Step 2:  Create a request
                NSArray *twitterAccounts =
                [accountStore accountsWithAccountType:twitterAccountType];
                NSURL *url = [NSURL URLWithString:@"https://api.twitter.com" @"/1.1/search/tweets.json"];

                NSDictionary *params = @{
                    @"q" : query,
                    @"resultl_type": @"recent"
                };

                SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:params];

                //  Attach an account to the request
                [request setAccount:[twitterAccounts lastObject]];

                // Execute the request
                [request performRequestWithHandler: ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    NSArray *results = nil;
                    if (responseData) {
                        if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                            results = [SocialMediaSvc parseTwitterQueryResponseData: responseData];
                        } else {
                            // an error occured
                            NSLog(@"The response status code is %d", urlResponse.statusCode);
                            // complete with nil (i.e. leave results as is)
                        }
                    }
                    // complete with results
                    completion(results);
                }];
            } else {
                // Access was not granted to the twitter account, or an error occurred
                NSLog(@"%@", [error localizedDescription]);
                // complete with nil;
                completion(nil);
            }
        }];
    } else {
        // complete immediately with nil;
        completion(nil);
    }
}

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

@end
