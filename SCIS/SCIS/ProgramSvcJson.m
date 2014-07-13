//
//  ProgramSvcJson.m
//  SCIS
//
//  Created by Tim Binkley-Jones on 7/12/14.
//  Copyright (c) 2014 msse652. All rights reserved.
//

#import "ProgramSvcJson.h"
#import "Program.h"
#import "Course.h"

@implementation ProgramSvcJson {
    id _delegate;
    Program *_program;
    NSURLConnection *_programConnection;
    NSURLConnection *_courseConnection;
    NSMutableData *_programData;
    NSMutableData *_courseData;
}

- (NSMutableArray *)parseProgramData:(NSData *)data {
    NSError *error;
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

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

- (NSMutableArray *)parseCourseData:(NSData *)data {
    NSError *error;
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

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


- (void) retrieveProgramsAsync {
    NSURL *url = [NSURL URLWithString:@"http://regisscis.net/Regis2/webresources/regis2.program"];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    _programConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (NSMutableArray *) retrievePrograms {
    NSError *error;

    NSURL *url = [NSURL URLWithString:@"http://regisscis.net/Regis2/webresources/regis2.program"];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    NSURLResponse *response = nil;

    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

    NSMutableArray *result = [self parseProgramData:data];

    return result;
}

- (NSArray *)retrieveCoursesForProgram:(Program *) program {
    NSError *error;

    NSURL *url = [NSURL URLWithString:@"http://regisscis.net/Regis2/webresources/regis2.course"];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    NSURLResponse *response = nil;

    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

    NSMutableArray *courses = [self parseCourseData:data];

    NSArray *results;

    for (int i=0; i<courses.count; i++) {
        Course *course = [courses objectAtIndex:i];
        if (course.program.programID == program.programID) {
            results = [NSArray arrayWithObject:course];
            break;
        }
    }
        
    return results;
}
- (void) retrieveCoursesForProgramAsync:(Program *) program {
    NSURL *url = [NSURL URLWithString:@"http://regisscis.net/Regis2/webresources/regis2.course"];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    _program = program;
    _courseConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

#pragma mark - NSURLConnectionDelegate

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection == _programConnection) {
        _programData = [[NSMutableData alloc] init];
    } else {
        _courseData = [[NSMutableData alloc] init];
    }
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection == _programConnection) {
        [_programData appendData:data];
    } else {
        [_courseData appendData:data];
    }
}

- (NSCachedURLResponse *) connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    if (connection == _programConnection) {
        NSMutableArray *results = [self parseProgramData:_programData];
        _programData = nil;
        _programConnection = nil;
        [_delegate didFinishRetrievingPrograms:results];
    } else {
        NSMutableArray *courses = [self parseCourseData:_courseData];
        NSArray *results;

        for (int i=0; i<courses.count; i++) {
            Course *course = [courses objectAtIndex:i];
            if (course.program.programID == _program.programID) {
                results = [NSArray arrayWithObject:course];
                break;
            }
        }
        _courseData = nil;
        _courseConnection = nil;
        _program = nil;
        [_delegate didFinishRetrievingCourses:results];
    }
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
}

@end
