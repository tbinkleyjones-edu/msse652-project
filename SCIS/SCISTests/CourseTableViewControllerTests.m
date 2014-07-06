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

@interface CourseTableViewControllerTests : XCTestCase

@end

@implementation CourseTableViewControllerTests {
    NSArray *courses;
    NSString *course;
    CourseTableViewController *controller;
    NSIndexPath *zeroPath;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    ProgramSvcFake *service = [[ProgramSvcFake alloc] init];
    courses = [service retrieveAllCourseForProgramId:0];
    XCTAssertNotNil(courses);

    course = [courses objectAtIndex:0];
    XCTAssertNotNil(course);

    controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CourseTableViewControllerID"];
    XCTAssertNotNil(controller);
    [controller setCourses:courses];

    zeroPath = [NSIndexPath indexPathForRow:0 inSection:0];
}

- (void)testSectionAndRowCount {
    XCTAssertEqual([controller numberOfSectionsInTableView:controller.tableView], 1);
    XCTAssertEqual([controller tableView:controller.tableView numberOfRowsInSection: 1], courses.count);
}

- (void)testCellForRow {
    UITableViewCell *cell = [controller tableView:controller.tableView cellForRowAtIndexPath:zeroPath];
    XCTAssertNotNil(cell);
    XCTAssertTrue([cell.textLabel.text isEqualToString:course], @"%@ does not match %@", cell.detailTextLabel.text, course);
}


@end
