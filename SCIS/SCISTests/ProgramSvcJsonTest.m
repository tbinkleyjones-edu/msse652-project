//
//  ProgramSvcJsonTest.m
//  SCIS
//
//  Created by Tim Binkley-Jones on 7/12/14.
//  Copyright (c) 2014 msse652. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ProgramSvcJson.h"

@interface ProgramSvcJsonTest : XCTestCase <ProgramSvcDelegate>

@end

@implementation ProgramSvcJsonTest {
    NSArray *_programs;
    NSArray *_courses;
}

#pragma mark - ProgramSvcDelegate

- (void)didFinishRetrievingPrograms:(NSArray *)programs {
    _programs = programs;
}

- (void)didFinishRetrievingCourses:(NSArray *)courses {
    _courses = courses;
}

#pragma mark - Tests

- (void)testProgramSvcJson
{
    id <ProgramSvc> service = [[ProgramSvcJson alloc] init];
    NSArray *programs = [service retrievePrograms];
    XCTAssert(programs.count > 0, @"Unexpected empty list");

    Program *program = [programs objectAtIndex:0];
    NSArray *courses = [service retrieveCoursesForProgram:program];
    XCTAssert(courses.count > 0, @"Unexpected empty list");
}

- (void)testProgramSvcJsonAsync {

    _programs = nil;
    _courses = nil;

    id <ProgramSvc> service = [[ProgramSvcJson alloc] init];
    [service setDelegate:self];
    [service retrieveProgramsAsync];

    while(_programs == nil) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    NSLog(@"done waiting for programs");
    XCTAssert(_programs.count > 0, @"Unexpected empty list");

    Program *program = [_programs objectAtIndex:0];
    [service retrieveCoursesForProgramAsync:program];

    while(_courses == nil) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    NSLog(@"done waiting for courses");
    XCTAssert(_courses.count > 0, @"Unexpected empty list");
}


@end
