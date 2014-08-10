//
//  NoteSvc.h
//  SCIS
//
//  Created by Tim Binkley-Jones on 8/10/14.
//  Copyright (c) 2014 msse652. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Note.h"

/**
 * The ProgramSvc protocol defines methods for retrieving and storing Notes.
 */
@protocol NoteSvc <NSObject>

/**
 * Retrieves an array of Notes
 */
- (NSArray *)retrieveAllNotes;

/**
 * Add (and persist) a new Note
 */
- (void)addNote:(Note *)note;

/**
 * Persist changes to a Note
 */
- (void)updateNote:(Note *)note;

/**
 * Delete a note from persisted storage
 */
- (void)deleteNote:(Note *)note;

@end
