//
//  NoteSvc.h
//  SCIS
//
//  Created by Tim Binkley-Jones on 8/9/14.
//  Copyright (c) 2014 msse652. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NoteSvc.h"

/**
 * A NoteSvc implementation that uses iCloud's NSUbiquitousKeyValueStore as the 
 * persisted storgage.
 * 
 * This implementation uses the Note's date value as a key or identifier. There
 * is a chance that a Note will be created at the same exact instance on two different
 * devices - in this case, behavior is undefined.
 */
@interface NoteSvcCloud : NSObject <NoteSvc>

- (instancetype)initWithHandler:(void(^)())handler;

@end
