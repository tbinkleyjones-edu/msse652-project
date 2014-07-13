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

@protocol ProgramSvc <NSObject>

- (NSArray *)retrievePrograms;
- (void) retrieveProgramsAsync;

- (NSArray *)retrieveCoursesForProgram:(Program *) program;
- (void) retrieveCoursesForProgramAsync:(Program *) program;

- (void) setDelegate:(id <ProgramSvcDelegate>)delegate;

@end
