//
//  ProgramSvcFake.m
//  SCIS
//
//  Created by Tim Binkley-Jones on 7/5/14.
//  Copyright (c) 2014 msse652. All rights reserved.
//

#import "ProgramSvcFake.h"
#import "Course.h"

@implementation ProgramSvcFake {
    NSArray *_programs;
    id <ProgramSvcDelegate> _delegate;
}

- (ProgramSvcFake *) init {
    if (self = [super init]) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (int i = 0; i<10; i++) {
            Program *program = [[Program alloc] init];
            program.programID = i;
            NSString *name = [NSString stringWithFormat:@"PRG%i", i];
            program.name = name;
            [array addObject: program];
        }
        _programs = [[NSArray alloc] initWithArray:array];
        return self;
    }

    return self;
}

- (void) setDelegate:(id <ProgramSvcDelegate>)delegate {
    _delegate = delegate;
}

- (NSArray *)retrievePrograms {
    return _programs;
}

- (void) retrieveProgramsAsync {
    dispatch_async(dispatch_get_global_queue (DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //background processing goes here

        dispatch_async(dispatch_get_main_queue(), ^{
            //update UI here
            [_delegate didFinishRetrievingPrograms:_programs];
        });
    });
};

- (NSArray *)retrieveCoursesForProgram:(Program *)program {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i<10; i++) {
        Course *course = [[Course alloc] init];
        course.courseID = i;
        course.name = [NSString stringWithFormat:@"SCIS %03i A Regis Course", i];
        course.program = [[Program alloc] init];
        course.program = program;
        [array addObject: course];
    }
    return array;
}

- (void) retrieveCoursesForProgramAsync:(Program *)program  {
    dispatch_async(dispatch_get_global_queue (DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //background processing goes here
        NSArray *courses = [self retrieveCoursesForProgram:program];

        dispatch_async(dispatch_get_main_queue(), ^{
            //update UI here
            [_delegate didFinishRetrievingCourses:courses];
        });
    });
};


@end
