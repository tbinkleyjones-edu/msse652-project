//
//  SocialMediaStatus.h
//  SCIS
//
//  Created by Tim Binkley-Jones on 8/2/14.
//  Copyright (c) 2014 msse652. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 * The SocialMediaStatus class represents basic information from a Twitter tweet or a Facebook status update.
 */
@interface SocialMediaStatus : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *text;

@end
