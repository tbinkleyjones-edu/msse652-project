//
//  ChatSvc.m
//  SCIS
//
//  Created by Tim Binkley-Jones on 8/15/14.
//  Copyright (c) 2014 msse652. All rights reserved.
//

#import "ChatSvcCF.h"

CFStringRef CHAT_HOST = (CFStringRef)@"www.regisscis.net";
UInt32 CHAT_PORT = 8080;

@implementation ChatSvcCF {
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    void (^_handler)(NSString* message);
}

- (instancetype)initWithHandler:(void(^)(NSString *message))handler {
    self = [self init];
    if (self) {
        _handler = handler;
    }
    return self;
}

/**
 * Create and open the input and output streams (which automatically opens the socket),
 * schedule the streams with a run loop, and set the streams delegate
 */
- (void) connect {
    NSLog(@"Connecting");
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, CHAT_HOST, CHAT_PORT, &readStream, &writeStream);
    inputStream = (NSInputStream *)CFBridgingRelease(readStream);
    outputStream = (NSOutputStream *)CFBridgingRelease(writeStream);

    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

    [inputStream open];
    [outputStream open];
}

/** 
 * Sends a message by writing to the outputStream.
 */
- (void) send:(NSString *) message {
    NSLog(@"Sending message: %@", message);
    NSData *data = [[NSData alloc] initWithData:[message dataUsingEncoding:NSASCIIStringEncoding]];
    [outputStream write:[data bytes] maxLength:[data length]];
}

/**
 * Retrieve a message from the inputStream. Called by the handleEvent method when processing NSStreamEventHasBytesAvailable.
 */
- (NSString *) retrieve {
    NSMutableString *message = [[NSMutableString alloc] init];
    uint8_t buffer[1024];
    int len = 0;
    while ([inputStream hasBytesAvailable]) {
        len = [inputStream read:buffer maxLength: sizeof(buffer)];
        if (len > 0) {
            NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
            if (output != nil) {
                [message appendString:output];
            }
        }
    }
    NSLog(@"Retrieved message: %@", message);
    return message;
}

/**
 * Close and clean up the input and output streams.
 */
- (void) disconnect {
    [inputStream close];
    [outputStream close];
    [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream setDelegate:nil];
    [outputStream setDelegate:nil];
    inputStream = nil;
    outputStream = nil;
    NSLog(@"Diconnected");
}

#pragma mark - NSStreamDelegate

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
	NSLog(@"stream event %u", streamEvent);

	switch (streamEvent) {
		case NSStreamEventOpenCompleted:
			NSLog(@"Stream opened");
			break;
		case NSStreamEventHasBytesAvailable:
            NSLog(@"Bytes available ");
            if (theStream == inputStream) {
				NSString *message = [self retrieve];
                NSLog(@"Received message: %@", message);
                if (message.length > 0) {
                    _handler(message);
                }
			}
			break;
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"Output stream has space available");
            break;
		case NSStreamEventErrorOccurred:
			NSLog(@"Can not connect to the host!");
			break;
		case NSStreamEventEndEncountered:
            NSLog(@"Closing stream");
            _handler(@"Connection closed");
			break;
		default:
			NSLog(@"Unknown event");
	}
}

@end
