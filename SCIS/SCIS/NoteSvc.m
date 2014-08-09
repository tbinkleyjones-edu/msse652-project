//
//  NoteSvc.m
//  SCIS
//
//  Created by Tim Binkley-Jones on 8/9/14.
//  Copyright (c) 2014 msse652. All rights reserved.
//

#import "NoteSvc.h"

static NSString *const NOTE_ID = @"noteId_";

@implementation NoteSvc {
    NSMutableArray *_notes;
    void (^_handler)();
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _notes = [[NSMutableArray alloc] init];
        [self unpackNotes];

        NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(storeDidChange:)
                                                     name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                                                   object:store];
        [[NSUbiquitousKeyValueStore defaultStore] synchronize];
    }
    return self;
}

- (instancetype)initWithHandler:(void(^)())handler
{
    self = [self init];
    if (self) {
        _handler = handler;
    }
    return self;
}

- (void)storeDidChange:(NSNotification *)notification {
    // notification.userInfo dictionary may contain
    // the NSUbiquitousKeyValueStoreChangeReasonKey key indicates why the key-value store changed.
    // the NSUbiquitousKeyValueStoreChangedKeysKey, when present, is an array of strings, each the name of a key whose value changed.

    // The notification object is the NSUbiquitousKeyValueStore object whose contents changed.
    // It should be the default store
    //NSUbiquitousKeyValueStore *store = notification.object;
    NSLog(@"storeDidChange");
    [[NSUbiquitousKeyValueStore defaultStore] synchronize];
    [self unpackNotes];
    dispatch_async(dispatch_get_main_queue(), ^{
        _handler();
    });

}

- (void) unpackNotes {
    NSDictionary *store = [[NSUbiquitousKeyValueStore defaultStore] dictionaryRepresentation];
    [store enumerateKeysAndObjectsUsingBlock:^(id key, id noteData, BOOL *stop) {
        if ([key hasPrefix:NOTE_ID]) {
            Note *newNote = [NSKeyedUnarchiver unarchiveObjectWithData:noteData];
            NSUInteger index = [_notes indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                Note *existingNote = obj;
                return [newNote.date isEqual:existingNote.date];
            }];
            if (index == NSNotFound) {
                NSLog(@"Adding note from key value store");
                [_notes addObject:newNote];
            } else {
                NSLog(@"Replacing note with note found in key value store");
                [_notes replaceObjectAtIndex:index withObject: newNote];
            }
        } else {
            NSLog(@"Ignoring key %@", key);
        }
    }];
}

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
    [_notes addObject:note];
    [self packNote:note];
    dispatch_async(dispatch_get_main_queue(), ^{
        _handler();
    });
}

- (void)updateNote:(Note *)note {
    // find an existing note with a matching date.
    NSUInteger index = [_notes indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        Note *existingNote = obj;
        return [note.date isEqual:existingNote.date];
    }];
    if (index != NSNotFound) {
        [_notes replaceObjectAtIndex:index withObject: note];
        [self packNote:note];
        dispatch_async(dispatch_get_main_queue(), ^{
            _handler();
        });
    }
}

- (void)deleteNote:(Note *)note {
    // find an existing note with a matching date.
    NSUInteger index = [_notes indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        Note *existingNote = obj;
        return [note.date isEqual:existingNote.date];
    }];
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
