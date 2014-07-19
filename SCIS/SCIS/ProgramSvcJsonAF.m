//
//  ProgramSvcJsonAF.m
//  week3
//
//  Created by Tim Binkley-Jones on 7/19/14.
//  Copyright (c) 2014 msse652. All rights reserved.
//

#import "ProgramSvcJsonAF.h"
#import "AFNetworking.h"
#import "Course.h"

@implementation ProgramSvcJsonAF {
    id _delegate;
}

- (NSMutableArray *)parseProgramData:(id)data {
    NSArray *array = data;

    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (int i=0; i<array.count; i++) {
        //NSLog(@"string: %@", array[i]);
        Program *program = [[Program alloc]init];
        NSDictionary *pgm = array[i];
        for (id key in pgm) {
            //Get an object and iterate thru its keys
            id value = [pgm objectForKey:key];
            //NSLog(@"key: %@, value: %@", key, value);

            if ([key isEqualToString:@"id"]) {
                program.programID = [value integerValue];
            } else {
                program.name = value;
            }
        }
        [result addObject:program];
    }
    return result;
}

- (NSMutableArray *)parseCourseData:(id)data {
    NSArray *array = data;

    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (int i=0; i<array.count; i++) {
        //NSLog(@"string: %@", array[i]);
        Course *course = [[Course alloc] init];
        course.program = [[Program alloc] init];
        NSDictionary *courses = array[i];
        for (id key in courses) {
            //Get an object and iterate thru its keys
            id value = [courses objectForKey:key];
            //NSLog(@"key: %@, value: %@", key, value);

            if ([key isEqualToString:@"id"]) {
                course.courseID = [value integerValue];
            } else if([key isEqualToString:@"name"]){
                course.name = value;
            } else if([key isEqualToString:@"pid"]){
                NSDictionary *pgm = value;
                for (id key in pgm) {
                    //Get an object and iterate thru its keys
                    id value = [pgm objectForKey:key];
                    //NSLog(@"key: %@, value: %@", key, value);

                    if ([key isEqualToString:@"id"]) {
                        course.program.programID = [value integerValue];
                    } else {
                        course.program.name = value;
                    }
                }
            }
        }
        [result addObject:course];
    }
    return result;
}


#pragma mark - ProgramSvc

- (void) setDelegate:(id <ProgramSvcDelegate>)delegate {
    _delegate = delegate;
}

- (NSArray *)retrievePrograms {
    NSLog(@"retrievePrograms Not implemented");
    return nil;
}

- (void) retrieveProgramsAsync {
    NSURL *url = [[NSURL alloc] initWithString: @"http://localhost:8080/regis2.program"];
    //NSURL *url = [[NSURL alloc] initWithString: @"http://regisscis.net/Regis2/webresources/regis2.program"];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

    operation.responseSerializer = [AFJSONResponseSerializer serializer];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"%@", responseObject);
        NSArray *results = [self parseProgramData:responseObject];
        [_delegate didFinishRetrievingPrograms:results];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Request FAILED: %@, %@", error, error.userInfo);
        [_delegate didFinishRetrievingPrograms:nil];
    }];
    [operation start];
}

- (NSArray *)retrieveCoursesForProgram:(Program *) program {
    NSLog(@"retrieveCoursesForProgram Not implemented");
    return nil;
}

- (void) retrieveCoursesForProgramAsync:(Program *) program {
    NSURL *url = [[NSURL alloc] initWithString: @"http://localhost:8080/regis2.course"];
    //NSURL *url = [[NSURL alloc] initWithString: @"http://regisscis.net/Regis2/webresources/regis2.course"];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

    operation.responseSerializer = [AFJSONResponseSerializer serializer];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSArray *courses = [self parseCourseData:responseObject];
        NSMutableArray *results = [[NSMutableArray alloc] init];
        for (int i=0; i<courses.count; i++) {
            Course *course = [courses objectAtIndex:i];
            if (course.program.programID == program.programID) {
                [results addObject:course];
            }
        }
        [_delegate didFinishRetrievingCourses:results];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Request FAILED: %@, %@", error, error.userInfo);
        [_delegate didFinishRetrievingCourses:nil];
    }];
    [operation start];
}

@end
