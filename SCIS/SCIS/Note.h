//
//  Note.h
//  SCIS
//
//  Created by Tim Binkley-Jones on 8/9/14.
//  Copyright (c) 2014 msse652. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Note : NSObject <NSCoding>

@property (nonatomic, strong) NSString *notes;
@property (nonatomic, strong) NSDate *date;

@end