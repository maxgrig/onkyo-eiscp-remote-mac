//
//  main.m
//  octl
//
//  Created by Jan-Gerd Tenberge on 03.06.12.
//  Copyright (c) 2012 Jan-Gerd Tenberge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JTSocketDelegte.h"
#import "JTOnkyoHelper.h"
#import "GCDAsyncSocket.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        JTSocketDelegte *delegate = [[JTSocketDelegte alloc] init];
        GCDAsyncSocket *asyncSocket;
        NSUInteger port = 60128;
        NSString *address;
        NSString *userCommand;
        
        switch (argc) {
            case 4:
                port = atol(argv[3]);
            case 3:
                userCommand = [NSString stringWithFormat:@"!1%s", argv[1]];
                address = [NSString stringWithCString:argv[2] encoding:NSASCIIStringEncoding];
                break;
            default:
                printf("USAGE: octl command ipAddress [port]\n");
                printf("       octl RESQSTN 192.168.2.239 60128\n");
                return 1;
                break;
        }

        NSError *error = nil;
        asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:delegate delegateQueue:dispatch_queue_create(0, 0)];
        BOOL connected = [asyncSocket connectToHost:address onPort:port withTimeout:0.05 error:&error];
        
        if (error != nil) {
            printf("Error: %s", error.description.UTF8String);
            return (int)error.code;
        }
        if (!connected) {
            printf("Error: Could not connect to receiver");
            return 1;
        }
        
        NSData *command = [JTOnkyoHelper dataForCommand:userCommand];
        [asyncSocket writeData:command withTimeout:1.0 tag:0];
        [asyncSocket readDataWithTimeout:0.5 tag:0];
        sleep(2);
    }
    return 0;
}
