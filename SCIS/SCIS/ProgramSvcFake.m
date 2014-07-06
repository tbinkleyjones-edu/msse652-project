//
//  ProgramSvcFake.m
//  SCIS
//
//  Created by Tim Binkley-Jones on 7/5/14.
//  Copyright (c) 2014 msse652. All rights reserved.
//

#import "ProgramSvcFake.h"

@implementation ProgramSvcFake {
    NSArray *programs;
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
        programs = [[NSArray alloc] initWithArray:array];
        return self;
    }

    return self;
}

- (NSArray *)retrieveAllPrograms {
    return programs;
}

- (NSArray *)retrieveAllCourseForProgramId:(NSInteger)programID {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i<10; i++) {
        NSString *course = [NSString stringWithFormat:@"CRS %03i", i];
        [array addObject: course];
    }
    return array;
}

@end
