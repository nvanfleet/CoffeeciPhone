//
//  NetworkClient.m
//  Coffeed
//
//  Created by Nathan Van Fleet on 12-10-23.
//  Copyright (c) 2012 Nathan Van Fleet. All rights reserved.
//

#import "NetworkClient.h"

#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <stdint.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>

#include <sys/time.h>

#include <sys/poll.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>

#include <errno.h>
#include <limits.h>

#include <fcntl.h>
#include <errno.h>

@interface NetworkClient () {
	CFSocketRef cfsocket;
	struct sockaddr_in server_address;
	
}
@property (strong) NSString *domain;
-(void) readData;
-(void) sendData;
@end

/*
 "Coffeec Version 2.1"
 "SETTING\n------------------\n"
 "VERSION             Get the version of coffeed\n"
 "SLEEP=<TRUE/FALSE>  Set to sleep or wake\n"
 "ACTIVE=<TRUE/FALSE> Set to sleep or wake (inverse of above)\n"
 "SHUTD               Shutdown the system (WARNING: stops daemon)\n"
 "TPOINT              Get the current temperature (read only)\n"
 "POW                 Get the current heater power\n"
 "PTERM               Get the current P value\n"
 "ITERM               Get the current I value\n"
 "DTERM               Get the current D value\n"
 "BMODE=<TRUE/FALSE>  Set to brewmode or steam mode\n"
 "SMODE=<TRUE/FALSE>  Set to brewmode or steam mode (inverse of above)\n"
 "SETPOINT            Get the current target temperature\n"
 "BPOINT=<float>      Get/Set Brew setpoint\n"
 "SPOINT=<float>      Get/Set Steam setpoint\n"
 "PGAIN=<float>       Get/Set PID p-gain\n"
 "IGAIN=<float>       Get/Set PID i-gain\n"
 "DGAIN=<float>       Get/Set PID d-gain\n"
 "TOFFEST=<float>     Get/Set thermocouple accuracy offset\n"
 "OFFSET=<float>      Get/Set boiler temp offset\n"
 */

static void socketCallback(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
{
	NetworkClient *client = (__bridge NetworkClient *) info;
	
	NSLog(@"client connected %@",client);
	
	if(type == kCFSocketReadCallBack)
	{
		NSLog(@"READ client connected %@",client);
		[client readData];

	}
	else if(type == kCFSocketWriteCallBack)
	{
		NSLog(@"WRITE client connected %@",client);
//		[client sendData];
	}
}

@implementation NetworkClient

#pragma mark CFSocket

-(void) readData
{
	int z = 0;
	int com_socket = CFSocketGetNative(cfsocket);
	int bsize = 256;
	char buffer[bsize];
	
	// READ
	z = recv(com_socket, buffer, bsize, 0);
	if (z < 0)
	{
		fprintf(stderr,"receive failure\n");
	}
	
}

-(void) sendData:(NSString *)command
{
	int z = 0;
	int com_socket = CFSocketGetNative(cfsocket);

	const char *cmd = [command UTF8String];
	
	// SEND
	z = send(com_socket, cmd, strlen(cmd)+1, 0);
	if (z < 0)
	{
		fprintf(stderr,"send failure\n");
	}
}


-(void) createSocket
{
	CFRunLoopSourceRef rls;
	
	// Create com_socket
    int com_socket = socket(PF_INET, SOCK_STREAM, 0);
    if (com_socket == -1)
	{
		fprintf(stderr, "Socket failed\n");
	}
	
	CFSocketContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
	cfsocket = CFSocketCreateWithNative(NULL, com_socket, kCFSocketReadCallBack | kCFSocketWriteCallBack, socketCallback, &context);
	
	// The socket will now take care of cleaning up our file descriptor.
	
	assert( CFSocketGetSocketFlags(cfsocket) & kCFSocketCloseOnInvalidate );
	com_socket = -1;
	
	rls = CFSocketCreateRunLoopSource(NULL, cfsocket, 0);
	assert(rls != NULL);
	
	CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopDefaultMode);
	
	CFRelease(rls);
}

-(void) connect
{
	// CONNECT
	CFTimeInterval timeout = 2;
	CFDataRef address = CFDataCreate(NULL, (UInt8 *) &server_address, sizeof(struct sockaddr_in));
	CFSocketConnectToAddress(cfsocket, address, timeout);
}

#pragma mark something

-(void) sendCommand:(NSString *)command domain:(NSString *)domain port:(NSNumber *)port
{
	
	
	[self createSocket];
	[self connect];
	[self sendData:command];
	
//	
//	int bufsize = 256;
//	char buffer[bufsize];
//	NSString *responseString = nil;
//	
//	if(![self.domain isEqualToString:domain])
//		[self setDomain:domain port:port];
//	
//	[self connect];
//	
//	int ret = [self sendMessage:[command UTF8String] buffer:buffer bufferSize:bufsize];
//	
//	[self closeSocket];
//	
//	if(ret > 0)
//	{
//		responseString = [NSString stringWithCString:(const char *) buffer encoding:NSUTF8StringEncoding];
//	}
//	
//	if([responseString length]==0)
//		return nil;
//	
//	return responseString;
}



#pragma mark Lower Level

-(void) setDomain:(NSString *)domain port:(NSNumber *)port
{
	self.domain = domain;
	[self setupSocket:[domain UTF8String] port:[port intValue]];
}

-(int) setupSocket:(const char *)addr port:(int)port
{
	int z=1;
	
	in_addr_t address = inet_addr(addr);
	
    // Server
    memset(&server_address, 0, sizeof(server_address));
    server_address.sin_family = AF_INET;
    server_address.sin_port = htons(port);
    server_address.sin_addr.s_addr = address;
	
	// Bad IP or possibly a DNS address
    if (server_address.sin_addr.s_addr == INADDR_NONE)
	{
		//		fprintf(stderr, "Server IP address failed trying DNS...\n");
		
		// Check DNS
		char portstr[10];
		snprintf(portstr, 10-1, "%d", port);
		
		struct addrinfo hints, *p, *servinfo;
		
		memset(&hints, 0, sizeof hints);
		hints.ai_family = AF_INET;
		hints.ai_socktype = SOCK_STREAM;
		
		// get ready to connect
		if ((z = getaddrinfo(addr, portstr, &hints, &servinfo)) != 0) {
			fprintf(stderr, "getaddrinfo error: %s\n", gai_strerror(z));
			return 0;
		}
		
		for(p = servinfo;p != NULL; p = p->ai_next)
		{
			// get the pointer to the address itself,
			// different fields in IPv4 and IPv6:
			if (p->ai_family == AF_INET) { // IPv4
				struct sockaddr_in *ipv4 = (struct sockaddr_in *)p->ai_addr;
				server_address.sin_addr = ipv4->sin_addr;
				z = 1;
			} else { // IPv6
				fprintf(stderr, "no ipv6 support");
				//            struct sockaddr_in6 *ipv6 = (struct sockaddr_in6 *)p->ai_addr;
				//            server_address.sin6_addr = ipv6->sin6_addr;
				z = 0;
			}
		}
		
		// servinfo now points to a linked list of 1 or more struct addrinfos
		freeaddrinfo(servinfo); // free the linked-list
		
		if(z == 0)
		{
			fprintf(stderr, "No DNS found\n");
			return 0;
		}
	}
	
	// Create com_socket
    com_socket = socket(PF_INET, SOCK_STREAM, 0);
    if (com_socket == -1)
	{
		fprintf(stderr, "Socket failed\n");
		return 0;
	}
	
	CFSocketContext     context = {0, (__bridge void *)(self), NULL, NULL, NULL};
	CFSocketRef cfsocket = CFSocketCreateWithNative(kCFAllocatorDefault, com_socket, kCFSocketReadCallBack, (*CFSocketCallBack) socketCallback, &context);
	
	// The socket will now take care of cleaning up our file descriptor.
	
	assert( CFSocketGetSocketFlags(self->_socket) & kCFSocketCloseOnInvalidate );
	fd = -1;
	
	return z;
}

@end
