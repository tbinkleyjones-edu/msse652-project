//
//  ProgramSvc.h
//  SCIS
//
//  Created by Tim Binkley-Jones on 7/5/14.
//  Copyright (c) 2014 msse652. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Program.h"

@protocol ProgramSvc <NSObject>

- (NSArray *)retrieveAllPrograms;
- (NSArray *)retrieveAllCourseForProgramId:(NSInteger) programID;

@end
