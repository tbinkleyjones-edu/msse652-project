//
//  ChatSvc.h
//  SCIS
//
//  Created by Tim Binkley-Jones on 8/16/14.
//  Copyright (c) 2014 msse652. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * The ChatSvc protocol defines the methods for connecting to a chat service, 
 * sending and receiving messages, and disconnecting.
 */
@protocol ChatSvc <NSObject>

/**
 * initialize the service with a block that is called when messages are received from the remote chat service
 */
- (instancetype)initWithHandler:(void(^)(NSString *message))handler;

/** 
 * Connect to the remote chat service
 */
- (void) connect;

/**
 * Send a message to the remote chat serivce 
 */
- (void) send:(NSString *) message;

/** 
 * Disconnect from the remote chat service
 */
- (void) disconnect;

@end
