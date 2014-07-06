//
//  SCISTests.m
//  SCISTests
//
//  Created by Tim Binkley-Jones on 7/5/14.
//  Copyright (c) 2014 msse652. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ProgramTableViewController.h"
#import "ProgramSvcFake.h"
#import "CourseTableViewController.h"

@interface ProgramTableViewControllerTests : XCTestCase

@end

@implementation ProgramTableViewControllerTests {
    NSArray *programs;
    Program *program;
    ProgramTableViewController *controller;
    NSIndexPath *zeroPath;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    ProgramSvcFake *service = [[ProgramSvcFake alloc] init];
    programs = [service retrieveAllPrograms];
    XCTAssertNotNil(programs);

    program = [programs objectAtIndex:0];
    XCTAssertNotNil(program);

    controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ProgramTableViewControllerID"];
    [controller setProgramSvc: service];
    XCTAssertNotNil(controller);

    zeroPath = [NSIndexPath indexPathForRow:0 inSection:0];
}

- (void)testSectionAndRowCount {
    XCTAssertEqual([controller numberOfSectionsInTableView:controller.tableView], 1);
    XCTAssertEqual([controller tableView:controller.tableView numberOfRowsInSection: 1], programs.count);
}

- (void)testCellForRow {
    UITableViewCell *cell = [controller tableView:controller.tableView cellForRowAtIndexPath:zeroPath];
    XCTAssertNotNil(cell);
    XCTAssertTrue([cell.textLabel.text isEqualToString:program.name], @"%@ does not match %@", cell.detailTextLabel.text, program.name);
}

- (void)testPrepareForSequeSetsProgramId {
    CourseTableViewController *destination = [[CourseTableViewController alloc] init];
    UIStoryboardSegue *segue = [[UIStoryboardSegue alloc] initWithIdentifier:@"FromProgramToCourse" source:controller destination:destination];

    [controller.tableView selectRowAtIndexPath:zeroPath animated:YES scrollPosition:UITableViewScrollPositionNone];

    [controller prepareForSegue:segue sender:nil];

    XCTAssertNotNil(destination.courses);
}

@end
