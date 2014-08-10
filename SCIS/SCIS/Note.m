//
//  Note.m
//  SCIS
//
//  Created by Tim Binkley-Jones on 8/9/14.
//  Copyright (c) 2014 msse652. All rights reserved.
//

#import "Note.h"

static NSString *const NOTES = @"notes";
static NSString *const DATE = @"date";

@implementation Note

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _notes = [coder decodeObjectForKey:NOTES];
        _date = [coder decodeObjectForKey:DATE];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.notes forKey:NOTES];
    [coder encodeObject:self.date forKey:DATE];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", _notes];
}
@end