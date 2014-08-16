//
//  NoteSvc.m
//  SCIS
//
//  Created by Tim Binkley-Jones on 8/9/14.
//  Copyright (c) 2014 msse652. All rights reserved.
//

#import "NoteSvcCloud.h"

static NSString *const NOTE_ID = @"noteId_";

@implementation NoteSvcCloud {
    NSMutableArray *_notes;
    void (^_handler)();
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _notes = [[NSMutableArray alloc] init];
        [self unpackNotes];

        NSLog(@"registering for notification");
        NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(storeDidChange:)
                                                     name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                                                   object:store];
    }
    return self;
}

/**
 * A custom init routine that accepts a handler block. The handler is called
 * whenever the collection of notes is changed. The handler will be called by
 * the addNote, updateNote, and deleteNote methods. The handler is also called
 * when external changes are received from iCloud.
 */
- (instancetype)initWithHandler:(void(^)())handler
{
    self = [self init];
    if (self) {
        _handler = handler;
    }
    return self;
}

/**
 * A priviate method to provide a friendly string for NSUbiquitousKeyValueStoreXXXChange enums
 * sent as part of the NSUbiquitousKeyValueStoreDidChangeExternallyNotification
 */
- (NSString *)stringForReasonEnum:(NSNumber *)reason {
    NSString *reasonString = nil;
    switch ([reason integerValue]) {
        case NSUbiquitousKeyValueStoreServerChange:
            reasonString = @"Server Change";
            break;
        case NSUbiquitousKeyValueStoreInitialSyncChange:
            reasonString = @"Initial Sync";
            break;
        case NSUbiquitousKeyValueStoreQuotaViolationChange:
            reasonString = @"Quota Violation";
            break;
        case NSUbiquitousKeyValueStoreAccountChange:
            reasonString = @"Account Change";
            break;
        default:
            reasonString = @"Unknown";
            break;
    }
    return reasonString;
}

/**
 * A NotificationCenter hanlder for NSUbiquitousKeyValueStoreDidChangeExternallyNotification
 */
- (void)storeDidChange:(NSNotification *)notification {
    [[NSUbiquitousKeyValueStore defaultStore] synchronize];

    // notification.userInfo dictionary may contain NSUbiquitousKeyValueStoreChangeReasonKey and NSUbiquitousKeyValueStoreChangedKeysKey
    // the NSUbiquitousKeyValueStoreChangeReasonKey key indicates why the key-value store changed.
    NSNumber *reason = [notification.userInfo objectForKey:NSUbiquitousKeyValueStoreChangeReasonKey];
    NSLog(@"Store did change externally: %@", [self stringForReasonEnum:reason]);

    // the NSUbiquitousKeyValueStoreChangedKeysKey, when present, is an array of strings, each the name of a key whose value changed.
    NSArray *changedKeys = [notification.userInfo objectForKey:NSUbiquitousKeyValueStoreChangedKeysKey];
    [changedKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self unpackNoteWithKey:obj];
    }];

    dispatch_async(dispatch_get_main_queue(), ^{
        _handler();
    });
}

/**
 * A private method to extract an archived note (i.e. stored as NSData) from the 
 * NSUbiquitousKeyValueStore and update the _notes array. Updates include adding, 
 * replacing, or deleteing a note in the _notes array.
 */
- (void)unpackNoteWithKey:(id)key {
    if ([key hasPrefix:NOTE_ID]) {
        NSData *noteData = [[NSUbiquitousKeyValueStore defaultStore] dataForKey:key];

        if (noteData == nil) {
            // this mean that the key was deleted from the KV store, and should be deleted from the _notes array
            NSString *dateString = [key substringFromIndex:NOTE_ID.length];
            // find an existing note with a date matching the date value placed in the key.
            NSUInteger index = [_notes indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                Note *existingNote = obj;
                return [dateString isEqual:existingNote.date.description];
            }];
            if (index != NSNotFound) {
                NSLog(@"Removing note deleted from key value store: %@", [_notes objectAtIndex:index]);
                [_notes removeObjectAtIndex:index];
            }
        } else {
            Note *newNote = [NSKeyedUnarchiver unarchiveObjectWithData:noteData];
            NSUInteger index = [_notes indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                Note *existingNote = obj;
                return [newNote.date isEqual:existingNote.date];
            }];
            if (index == NSNotFound) {
                NSLog(@"Adding note from key value store: %@", newNote);
                [_notes addObject:newNote];
            } else {
                NSLog(@"Replacing note with note found in key value store: %@", newNote);
                [_notes replaceObjectAtIndex:index withObject: newNote];
            }
        }
    } else {
        NSLog(@"Ignoring key %@", key);
    }
}

/**
 * A private method to extract all notes from the NSUbiquitousKeyValueStore
 */
- (void) unpackNotes {
    NSDictionary *store = [[NSUbiquitousKeyValueStore defaultStore] dictionaryRepresentation];
    NSEnumerator *enumerator = [store keyEnumerator];
    id key;

    while ((key = [enumerator nextObject])) {
        [self unpackNoteWithKey:key];
    }
}

/**
 * A private method to archive a Note (to NSData) and add the note to the NSUbiquitousKeyValueStore
 */
- (void) packNote:(Note *)note {
    NSLog(@"packing Note");
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:note];
    NSString *noteKey = [NSString stringWithFormat:@"%@%@", NOTE_ID, note.date];
    [[NSUbiquitousKeyValueStore defaultStore] setData:data forKey:noteKey];
}

#pragma mark - public NoteSvc methods

- (NSArray *)retrieveAllNotes {
    return _notes;
}

- (void)addNote:(Note *)note {
    // check that an existing note with a matching date does not exist in the array.
    NSUInteger index = [_notes indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        Note *existingNote = obj;
        return [note.date isEqual:existingNote.date];
    }];
    // if found, do nothing
    // if not found, add the note to the array and the key value store.
    if (index == NSNotFound) {
        [_notes addObject:note];
        [self packNote:note];
        dispatch_async(dispatch_get_main_queue(), ^{
            _handler();
        });
    }
}

- (void)updateNote:(Note *)note {
    // find an existing note with a date matching the date in the given note.
    NSUInteger index = [_notes indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        Note *existingNote = obj;
        return [note.date isEqual:existingNote.date];
    }];

    // if found, update the array and the key value store.
    // if not found, do nothing.
    if (index != NSNotFound) {
        [_notes replaceObjectAtIndex:index withObject: note];
        [self packNote:note];
        dispatch_async(dispatch_get_main_queue(), ^{
            _handler();
        });
    }
}

- (void)deleteNote:(Note *)note {
    // find an existing note with a date matching the date in the given note.
    NSUInteger index = [_notes indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        Note *existingNote = obj;
        return [note.date isEqual:existingNote.date];
    }];

    // if found, remove the note from the array and the key value store.
    // if not found, do nothing.
    if (index != NSNotFound) {
        [_notes removeObjectAtIndex:index];
        NSString *noteKey = [NSString stringWithFormat:@"%@%@", NOTE_ID, note.date];
        [[NSUbiquitousKeyValueStore defaultStore] removeObjectForKey:noteKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            _handler();
        });
    }
}
@end
