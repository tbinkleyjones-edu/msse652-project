//
//  CourseTableViewControllerTests.m
//  SCIS
//
//  Created by Tim Binkley-Jones on 7/6/14.
//  Copyright (c) 2014 msse652. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CourseTableViewController.h"
#import "ProgramSvcFake.h"
#import "Course.h"

@interface CourseTableViewControllerTests : XCTestCase

@end

@implementation CourseTableViewControllerTests {
    NSArray *courses;
    Course *course;
    CourseTableViewController *controller;
    NSIndexPath *zeroPath;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    ProgramSvcFake *service = [[ProgramSvcFake alloc] init];

    NSArray *programs = [service retrievePrograms];
    XCTAssertNotNil(programs);

    Program *program = [programs objectAtIndex:0];
    XCTAssertNotNil(program);

    courses = [service retrieveCoursesForProgram:program];
    XCTAssertNotNil(courses);

    course = [courses objectAtIndex:0];
    XCTAssertNotNil(course);

    NSLog(@"setup starting constroller construction");
    controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CourseTableViewControllerID"];
    NSLog(@"setup finished controller construction");

    XCTAssertNotNil(controller);
    [controller setProgram:program];
    controller.service = service;

    zeroPath = [NSIndexPath indexPathForRow:0 inSection:0];
}

- (void)testSectionAndRowCount {
    while(controller.areCoursesLoaded == NO) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }

    XCTAssertEqual([controller numberOfSectionsInTableView:controller.tableView], 1);
    XCTAssertEqual([controller tableView:controller.tableView numberOfRowsInSection: 1], courses.count);
}

- (void)testCellForRow {
    while(controller.areCoursesLoaded == NO) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }

    UITableViewCell *cell = [controller tableView:controller.tableView cellForRowAtIndexPath:zeroPath];
    XCTAssertNotNil(cell);
    XCTAssertTrue([cell.textLabel.text isEqualToString:course.name], @"%@ does not match %@", cell.detailTextLabel.text, course.name);
}


@end
