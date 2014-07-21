//
//  ProgramSvc.h
//  SCIS
//
//  Created by Tim Binkley-Jones on 7/5/14.
//  Copyright (c) 2014 msse652. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Program.h"
#import "ProgramSvcDelegate.h"

/**
 The ProgramSvc protocol defines synchronous and asynchronous methods for 
 retrieving SCIS Programs and Courses.
 */
@protocol ProgramSvc <NSObject>

/**
 Retrieves a list of SCIS Programs from the Regis web service.
 */
- (NSArray *)retrievePrograms;

/**
 Asychronously retreives a list of SCIS Programs from the Regis web service. 
 Results are returned by a calling the delegate's didFinishRetrievingPrograms method.
 */
- (void) retrieveProgramsAsync;

/**
 Retrieves a list of SCIS Courses for the specified program from the Regis web service.
 */
- (NSArray *)retrieveCoursesForProgram:(Program *) program;

/**
 Asychronously retreives a list of SCIS Courses from the Regis web service.
 Results are returned by a calling the delegate's didFinishRetrievingCourses method.
 */
- (void) retrieveCoursesForProgramAsync:(Program *) program;

/**
 Sets the delegate to be used during asynchronous operations.
 */
- (void) setDelegate:(id <ProgramSvcDelegate>)delegate;

@end
