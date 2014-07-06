//
//  ProgramSvcFakeTests.m
//  SCIS
//
//  Created by Tim Binkley-Jones on 7/6/14.
//  Copyright (c) 2014 msse652. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ProgramSvcFake.h"

@interface ProgramSvcFakeTests : XCTestCase

@end

@implementation ProgramSvcFakeTests

- (void)testInit
{
    id service = [[ProgramSvcFake alloc] init];
    NSArray *programs = [service retrieveAllPrograms];
    NSUInteger count = programs.count;
    XCTAssertEqual(count, 10);
    for (int i=0; i<programs.count; i++) {
        Program *program = [programs objectAtIndex:i];
        XCTAssertNotNil(program);
        XCTAssertNotNil(program.name);
        XCTAssertEqual(program.programID, i);
    }
}

@end
