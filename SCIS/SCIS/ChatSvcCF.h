//
//  ChatSvc.h
//  SCIS
//
//  Created by Tim Binkley-Jones on 8/15/14.
//  Copyright (c) 2014 msse652. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatSvc.h"

/**
 * A chat service implementation that uses Core Foundation sockets and streams.
 * The ChatSvc connects to the Regis chat service found at www.regisscis.net:8080.
 *
 * The Regis chat service responds with "** Thank you **" upon receiving a end of
 * line character, and then closes the socket.
 *
 * This implementation will call the received message handler with
 * "Connection closed" when the Regis service closes the connection.
 */
@interface ChatSvcCF : NSObject <ChatSvc, NSStreamDelegate>

@end
