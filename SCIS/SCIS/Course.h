//
//  Course.h
//  SCIS
//
//  Created by Tim Binkley-Jones on 7/12/14.
//  Copyright (c) 2014 msse652. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Program.h"

@interface Course : NSObject

@property (nonatomic) NSInteger courseID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) Program *program;

@end
