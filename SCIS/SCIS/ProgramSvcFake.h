//
//  ProgramSvcFake.h
//  SCIS
//
//  Created by Tim Binkley-Jones on 7/5/14.
//  Copyright (c) 2014 msse652. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "ProgramSvc.h"

/**
 A fake implementation of ProgramSvc to be used for testing. The implemenation
 returns hard coded arrays of program and course data.
 */
@interface ProgramSvcFake : NSObject <ProgramSvc>

@end
