//
//  DataRequest.m
//  CanadaVisa
//
//  Created by Nathan Van Fleet on 11-10-26.
//  Copyright (c) 2011 Logic Pretzel. All rights reserved.
//

#import "DataRequest.h"
#import "DataRequestManager.h"

#import "coffeec.h"

//
//#include <stdio.h>
//#include <sys/time.h>
//#include <sys/poll.h>
//#include <netinet/tcp.h>
//#include <sys/types.h>
//#include <sys/socket.h>
//#include <errno.h>
//#include <string.h>
//#include <limits.h>
//#include <unistd.h>
//#include <fcntl.h>
//#include <stdlib.h>
//#include <netinet/in.h>
//#include <stdint.h>
//#include <arpa/inet.h>
//#include <netdb.h> // DNS lookup
//
//static int connectWithTimeout (int sfd, struct sockaddr *addr, int addrlen, struct timeval *timeout)
//{
//    struct timeval sv;
//    socklen_t svlen = sizeof sv;
//    int ret;
//    
//    if (!timeout)
//        return connect (sfd, addr, addrlen);
//    if (getsockopt (sfd, SOL_SOCKET, SO_RCVTIMEO, (char *)&sv, &svlen) < 0)
//        return -1;
//    if (setsockopt (sfd, SOL_SOCKET, SO_RCVTIMEO, (char *)timeout, sizeof *timeout) < 0)
//        return -1;
//    ret = connect (sfd, addr, addrlen);
//    setsockopt (sfd, SOL_SOCKET, SO_RCVTIMEO, (char *)&sv, sizeof sv);
//    return ret;
//}

@implementation DataRequest
@synthesize active;

-(void) failed:(NSString *)message
{
    NSLog(@"FAILURE %@",message);
    [self.caller dataManagerDidFail:self withObject:message];
	
	// Remove from queue
	[[DataRequestManager sharedInstance] removeRequestFromQueue:self];
}
//
//-(BOOL) opencom_socketToAddress:(NSString *)address port:(NSNumber *)port
//{
//    NSLog(@"openSocket...");
//    
//    int z;
//    struct sockaddr_in server_addr;
//    struct timeval timeout;
//    int len_inet = sizeof(server_addr);
//
//    timeout.tv_sec = 2; /* 2 seconds */
//    timeout.tv_usec = 0; /* + 0 usec */
//    
//    memset(&server_addr,0, len_inet);
//    server_addr.sin_family = AF_INET;
//
//	// With IP address information
//	[self failed:@"DNS failed defaulting to IP address."];
//	server_addr.sin_addr.s_addr = inet_addr([address cStringUsingEncoding:NSUTF8StringEncoding]);
//	server_addr.sin_port =  htons([port intValue]);
//
//    if ( server_addr.sin_addr.s_addr == INADDR_NONE )
//    {
//        [self failed:@"bad address."];
//        return FALSE;
//    }
//    
//    // Create com_socket
//    com_socket = socket(PF_INET,SOCK_STREAM,0);
//    if ( com_socket == -1 )
//    {
//        [self failed:@"socket failed."];
//        return FALSE;
//    }
//    
//    // Connect
//    z = connectWithTimeout(com_socket, (struct sockaddr *) &server_addr, len_inet, &timeout);
//    
//    if(z == -1)
//    {
//        [self failed:@"connect failed."];
//        return FALSE;
//    }
//
//    return TRUE;
//}

//-(void) sendCommand:(NSString *)command
//{
//    const char *stringCmd = [command cStringUsingEncoding:NSUTF8StringEncoding];
//    write(com_socket, stringCmd, sizeof(stringCmd));
//}

//-(void) readOutput
//{
//    int z;
//    char *dtbuf[128];
//    
//    z = read(com_socket,&dtbuf,sizeof dtbuf-1); 
//    
//    if ( z == -1 )
//        [self failed:@"read()"];
//    
//    dtbuf[z] = 0;
//    
//	// Message caller
//    [self.caller dataManagerDidSucceed:self withObject:[NSString stringWithCString:(const char *) dtbuf encoding:NSUTF8StringEncoding]];
//	
//	// Remove from queue
//	[[DataRequestManager sharedInstance] removeRequestFromQueue:self];
//}

#pragma mark Command Wrangling

-(void) setupCommand:(NSString *)command address:(NSString *)address port:(NSNumber *)port caller:(id)caller key:(NSString *)key
{
    self.caller = caller;
    self.key = key;
	self.command = command;
	self.address = address;
	self.port = port;
}

-(void) sendCommand
{
	int bsize = 256;
	char buffer[bsize];
	
	sendMessage((char *) [self.address UTF8String], [self.port intValue], (char *) [self.command UTF8String], buffer, bsize);
	
	[self.caller dataManagerDidSucceed:self withObject:[NSString stringWithCString:(const char *) buffer encoding:NSUTF8StringEncoding]];
	
	// Remove from queue
	[[DataRequestManager sharedInstance] removeRequestFromQueue:self];
	
//	if([self opencom_socketToAddress:self.address port:self.port])
//    {
//        [self sendCommand:self.command];
//        [self readOutput];
//        close(com_socket);
//    }
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
        self.active = NO;
    }
    
    return self;
}

@end
