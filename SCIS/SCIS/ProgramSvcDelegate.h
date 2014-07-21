//
//  ProgramSvcDelegate.h
//  SCIS
//
//  Created by Tim Binkley-Jones on 7/12/14.
//  Copyright (c) 2014 msse652. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 ProgramSvcDelegate protocol defines methods called by ProgramSvc implementations
 when asynchronous operations are complete.
 */
@protocol ProgramSvcDelegate <NSObject>

- (void)didFinishRetrievingPrograms:(NSArray *)programs;
- (void)didFinishRetrievingCourses:(NSArray *)programs;

@end
