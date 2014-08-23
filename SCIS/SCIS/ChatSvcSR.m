//
//  ChatSvcSR.m
//  SCIS
//
//  Created by Tim Binkley-Jones on 8/21/14.
//  Copyright (c) 2014 msse652. All rights reserved.
//

#import "ChatSvcSR.h"
#import "SRWebSocket.h"

NSString *const CHATURL = @"ws://echo.websocket.org/";
//NSString *const CHATURL = @"http://www.regisscis.net:8080/";

@interface ChatSvcSR () <SRWebSocketDelegate>

@end

@implementation ChatSvcSR {
    SRWebSocket *_webSocket;
    void (^_handler)(NSString* message);
}

- (instancetype)initWithHandler:(void(^)(NSString *message))handler {
    self = [self init];
    if (self) {
        _handler = handler;
    }
    return self;
}

#pragma mark - ChatSvc

/**
 * Create and open the websocket, setting this instance as the delegate
 */
- (void) connect {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    _webSocket = [[SRWebSocket alloc] initWithURLRequest: [NSURLRequest requestWithURL:[NSURL URLWithString:CHATURL]]];
    _webSocket.delegate = self;

    [_webSocket open];
}

/**
 * Sends a message to the websocket.
 */
- (void) send:(NSString *) message {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [_webSocket send:message];
}

/**
 * Close and clean up the web socket.
 */
- (void) disconnect {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [_webSocket close];
    _webSocket = nil;
}

#pragma mark - SRWebSocketDelegate

/**
 * Forward the received message to the handler block.
 */
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSLog(@"%s", __PRETTY_FUNCTION__);

    NSString *msg = (NSString *)message;
    NSLog(@"%@", msg);
    _handler(msg);
}

/**
 * Does nothing
 */
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

/**
 * Clean up the failed socket.
 */
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"Websocket failed with error: %@", error);
    _webSocket = nil;
}

/**
 * Clean the socket, sending a closed message to the handler block. 
 */
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"Websocket closed with code: %i and reason:%@", code, reason);
    _handler(@"Connection closed");
    _webSocket = nil;
}

@end
