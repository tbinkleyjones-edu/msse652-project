//
//  ProgramSvcFakeTests.m
//  SCIS
//
//  Created by Tim Binkley-Jones on 7/6/14.
//  Copyright (c) 2014 msse652. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ProgramSvcFake.h"

@interface ProgramSvcFakeTests : XCTestCase <ProgramSvcDelegate>

@end

@implementation ProgramSvcFakeTests {
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

- (void)testRetrievePrograms
{
    id <ProgramSvc> service = [[ProgramSvcFake alloc] init];
    NSArray *programs = [service retrievePrograms];
    NSUInteger count = programs.count;
    XCTAssertEqual(count, 10);
    for (int i=0; i<programs.count; i++) {
        Program *program = [programs objectAtIndex:i];
        XCTAssertNotNil(program);
        XCTAssertNotNil(program.name);
        XCTAssertEqual(program.programID, i);
    }

    Program *program = [programs objectAtIndex:0];
    NSArray *courses = [service retrieveCoursesForProgram:program];
    XCTAssert(courses.count > 0, @"Unexpected empty list");
}

- (void)testRetrieveProgramsAsync {

    _programs = nil;

    id <ProgramSvc> service = [[ProgramSvcFake alloc] init];
    [service setDelegate:self];
    [service retrieveProgramsAsync];

    while(_programs == nil) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }

    NSUInteger count = _programs.count;
    XCTAssertEqual(count, 10);
    for (int i=0; i<_programs.count; i++) {
        Program *program = [_programs objectAtIndex:i];
        XCTAssertNotNil(program);
        XCTAssertNotNil(program.name);
        XCTAssertEqual(program.programID, i);
    }

    Program *program = [_programs objectAtIndex:0];
    [service retrieveCoursesForProgramAsync:program];

    while(_courses == nil) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    NSLog(@"done waiting for courses");
    XCTAssert(_courses.count > 0, @"Unexpected empty list");
}

@end
