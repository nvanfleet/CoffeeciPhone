//
//  DataRequest.m
//  CanadaVisa
//
//  Created by Nathan Van Fleet on 11-10-26.
//  Copyright (c) 2011 Logic Pretzel. All rights reserved.
//

#import "DataRequest.h"

#include <stdio.h>
#include <sys/time.h>
#include <sys/poll.h>
#include <netinet/tcp.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <errno.h>
#include <string.h>
#include <limits.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <netinet/in.h>
#include <stdint.h>
#include <arpa/inet.h>

static int connectWithTimeout (int sfd, struct sockaddr *addr, int addrlen, struct timeval *timeout)
{
    struct timeval sv;
    socklen_t svlen = sizeof sv;
    int ret;
    
    if (!timeout)
        return connect (sfd, addr, addrlen);
    if (getsockopt (sfd, SOL_SOCKET, SO_RCVTIMEO, (char *)&sv, &svlen) < 0)
        return -1;
    if (setsockopt (sfd, SOL_SOCKET, SO_RCVTIMEO, (char *)timeout, sizeof *timeout) < 0)
        return -1;
    ret = connect (sfd, addr, addrlen);
    setsockopt (sfd, SOL_SOCKET, SO_RCVTIMEO, (char *)&sv, sizeof sv);
    return ret;
}

@implementation DataRequest
@synthesize callback,active;

-(void) failed:(NSString *)message
{
    NSLog(@"%@",message);
    [callback dataManagerDidFail:self message:message];
}

-(BOOL) opencom_socketToAddress:(NSString *)address port:(NSNumber *)port
{
    NSLog(@"openSocket");
    
    int z;
    struct sockaddr_in server_addr;
    struct timeval timeout;
    int len_inet = sizeof(server_addr);
    
    timeout.tv_sec = 2; /* 2 seconds */ 
    timeout.tv_usec = 0; /* + 0 usec */
    
    memset(&server_addr,0, len_inet);
    server_addr.sin_family = AF_INET;
    server_addr.sin_port =  htons([port intValue]);
    server_addr.sin_addr.s_addr = inet_addr([address cStringUsingEncoding:NSUTF8StringEncoding]);

    if ( server_addr.sin_addr.s_addr == INADDR_NONE )
    {
        [self failed:@"bad address."];
        return FALSE;
    }
    
    NSLog(@"address");
    
    // Create com_socket
    com_socket = socket(PF_INET,SOCK_STREAM,0);
    if ( com_socket == -1 )
    {
        [self failed:@"socket failed."];
        return FALSE;
    }
    
    NSLog(@"socket");
    
    // Connect
    z = connectWithTimeout(com_socket, (struct sockaddr *) &server_addr, len_inet, &timeout);
    
    if(z == -1)
    {
        [self failed:@"connect failed."];
        return FALSE;
    }
    
    NSLog(@"connect");
    
    return TRUE;
}

-(void) sendCommand:(NSString *)command
{
    const char *stringCmd = [command cStringUsingEncoding:NSUTF8StringEncoding];
    write(com_socket, stringCmd, sizeof(stringCmd));
}

-(void) readOutput
{
    int z;
    char *dtbuf[128];
    
    z = read(com_socket,&dtbuf,sizeof dtbuf-1); 
    
    if ( z == -1 )
        [self failed:@"read()"];
    
    dtbuf[z] = 0;
    
    [callback dataManagerDidSucceed:self withObject:[NSString stringWithCString:(const char *) dtbuf encoding:NSUTF8StringEncoding]];
}

-(void) sendCommand:(NSString *)command address:(NSString *)address port:(NSNumber *)port callback:(id)cb
{
    active = YES;
    self.callback = cb;
    
    if([self opencom_socketToAddress:address port:port])
    {
        [self sendCommand:command];
        [self readOutput];
        close(com_socket);
    }
}

#pragma mark - Basic

+(DataRequest *) dataRequest
{
    DataRequest *dr = [[DataRequest alloc] init];
    
    return dr;
}

-(id) init
{
    if((self = [super init]))
    {
        active = YES;
    }
    
    return self;
}

@end