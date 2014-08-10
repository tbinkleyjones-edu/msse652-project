//
//  NoteSvcTests.m
//  SCIS
//
//  Created by Tim Binkley-Jones on 8/9/14.
//  Copyright (c) 2014 msse652. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NoteSvcCloud.h"

@interface NoteSvcCloudTests : XCTestCase

@end

@implementation NoteSvcCloudTests

- (Note*)findNote:(Note *)note inArray:(NSArray *)notes {
    __block Note *foundNote = nil;
    [notes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Note *existingNote = obj;
        if ([existingNote.date isEqual:note.date]) {
            NSLog(@"Found note: %@", existingNote);
            foundNote = existingNote;
            (*stop) = YES;
        }
    }];
    return foundNote;
}

- (void)testAddUpdateDelete
{
    NoteSvcCloud *service = [[NoteSvcCloud alloc] init];

    NSUInteger initialCount = [service retrieveAllNotes].count;
    NSString *testString1 = @"test note";
    NSString *testString2 = @"test note after update";
    NSDate *testDate = [NSDate date];

    Note *testNote = [[Note alloc] init];
    testNote.date = testDate;
    testNote.notes = testString1;

    [service addNote:testNote];

    NSUInteger countAfterAdd = [service retrieveAllNotes].count;
    XCTAssertEqual(initialCount + 1, countAfterAdd, @"Unexpected value for countAfterAdd");

    Note *foundNote = [self findNote:testNote inArray:[service retrieveAllNotes]];
    XCTAssertNotNil(foundNote, "did not find expected note in array.");
    XCTAssertEqual(testString1, foundNote.notes);
    XCTAssertEqual(testDate, foundNote.date);

    Note *testNote2 = [[Note alloc] init];
    testNote2.date = testDate;
    testNote2.notes = testString2;
    [service updateNote:testNote2];

    // since the service uses note.date to identify notes, testNote2 should be
    // considered the same note as testNote. The count should not have changed
    // and if we look for testNote, the we should get an instance with testString2

    NSUInteger countAfterUpdate = [service retrieveAllNotes].count;
    XCTAssertEqual(countAfterAdd, countAfterUpdate, @"Unexpected value for countAfterUpdate");

    foundNote = [self findNote:testNote inArray:[service retrieveAllNotes]];
    XCTAssertNotNil(foundNote, "did not find expected note in array.");
    XCTAssertEqual(testString2, foundNote.notes);
    XCTAssertEqual(testDate, foundNote.date);

    [service deleteNote:testNote];
    NSUInteger countAfterDelete = [service retrieveAllNotes].count;
    XCTAssertEqual(initialCount, countAfterDelete, @"Unexpected value for countAfterDelete");

    foundNote = [self findNote:testNote inArray:[service retrieveAllNotes]];
    XCTAssertNil(foundNote, "unexpectedly found note in array.");
}

@end
