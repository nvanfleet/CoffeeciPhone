//
//  DataRequest.m
//  CanadaVisa
//
//  Created by Nathan Van Fleet on 11-10-26.
//  Copyright (c) 2011 Logic Pretzel. All rights reserved.
//

#import "DataRequest.h"
#import "DataRequestManager.h"

#import <CoreFoundation/CoreFoundation.h>

#include <netinet/tcp.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>

@interface DataRequest () {
	BOOL hasHostname;
	BOOL canSend;
	CFSocketRef cfsocket;
	struct sockaddr_in server_address;
}
@property (strong) NSString *domain;
-(void) sendData;
-(void) decodeData:(const void *)data;
-(void) failure:(NSString *)failMessage;
-(void) setServerAddress:(struct sockaddr_in)addr;
@end

static void hostnameCallback(CFHostRef inHostInfo, CFHostInfoType inType, const CFStreamError *inError, void *info)
{
	DataRequest *client = (__bridge DataRequest *) info;
	
	if(inError->error == noErr)
	{
		DataRequest *client = (__bridge DataRequest *) info;
		NSArray *addresses = (__bridge NSArray *) CFHostGetAddressing(inHostInfo, NULL);
		CFDataRef address = (__bridge CFDataRef) [addresses objectAtIndex:0];
		// just grab 1st
		struct sockaddr_in *addr =(struct sockaddr_in *)CFDataGetBytePtr(address);
		struct sockaddr_in finalSocketInfo;
		
		// copy the address from the retrieved structure, and
		memset(&finalSocketInfo, 0, sizeof(finalSocketInfo));
		finalSocketInfo.sin_addr = addr->sin_addr;
		finalSocketInfo.sin_family = AF_INET;
		
		[client setServerAddress:finalSocketInfo];
	}
	else
	{
		// handle the error
		[client failure:@"no connectivity"];
	}
}

static void socketCallback(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
{
	DataRequest *client = (__bridge DataRequest *) info;

	if(type == kCFSocketDataCallBack)
		[client decodeData:data];
	else if(type == kCFSocketConnectCallBack)
		[client sendData];
}

@implementation DataRequest
@synthesize active;

-(void) failure:(NSString *)failMessage
{
	[self closeSocket];
	[self setupSocket];
	[self.caller dataManagerDidFail:self withObject:failMessage];
}

#pragma mark CFSocket

-(void) decodeData:(const void *)data
{
	NSString *response = [[NSString alloc] initWithData:(__bridge NSData *)data encoding:NSUTF8StringEncoding];
	
	if(response != nil)
	{
		NSDictionary *message = [self decodeMessage:response];
		[self.caller dataManagerDidSucceed:self withObject:message];
	}
	else
		[self.caller dataManagerDidFail:self withObject:nil];
	
	[self closeSocket];
	[self setupSocket];
	
	// Remove from queue
	[[DataRequestManager sharedInstance] removeRequestFromQueue:self];
}

-(void) sendData
{
	CFSocketError error;
	CFTimeInterval timeout = 5;
	const char *cmd = [_command UTF8String];
	CFDataRef data = CFDataCreate(NULL, (UInt8 *) cmd, strlen(cmd));
	error = CFSocketSendData(cfsocket, NULL, data, timeout);
	CFRelease(data);
	
	if(error == kCFSocketError)
		[self failure:@"SEND kCFSocketError"];
	else if(error == kCFSocketTimeout)
		[self failure:@"SEND kCFSocketTimeout"];
}

-(void) connect
{
	CFSocketError error;
	CFTimeInterval timeout = 5;

	CFDataRef address = CFDataCreate(NULL, (UInt8 *) &server_address, sizeof(server_address));

	// CONNECT
	error = CFSocketConnectToAddress(cfsocket, address, timeout);
	
	if(error == kCFSocketError)
		[self failure:@"CONNECT kCFSocketError"];
	else if(error == kCFSocketTimeout)
		[self failure:@"CONNECT kCFSocketTimeout"];
	
	CFRelease(address);
}

-(void)resolveHost:(NSString *)hostname
{
	CFHostRef hostRef = CFHostCreateWithName(kCFAllocatorDefault, (__bridge CFStringRef)hostname);
	CFHostClientContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
	
	CFHostSetClient(hostRef, hostnameCallback, &context);
	CFHostScheduleWithRunLoop(hostRef, CFRunLoopGetCurrent(),kCFRunLoopCommonModes);
	CFStreamError error = { 0, 0 };
	CFHostStartInfoResolution(hostRef, kCFHostAddresses, &error);
	
//	CFRelease(hostRef);
}

-(void) setServerAddress:(struct sockaddr_in)addr
{
	int port = [self.port intValue];
	server_address = addr;
	server_address.sin_port = htons(port);

	NSLog(@"HOST RESOLVED %s %d",inet_ntoa(server_address.sin_addr),port);
	
	hasHostname = TRUE;
	[self checkStatus];
}

-(void) setupAddress:(NSString *)a port:(NSNumber *)p
{
	[self resolveHost:a];
	
//	const char *addr = [a UTF8String];
//	int port = [p intValue];
//	
//	int z;
//	in_addr_t address = inet_addr(addr);
//	
//    // Server
//    memset(&server_address, 0, sizeof(server_address));
//    server_address.sin_family = AF_INET;
//    server_address.sin_port = htons(port);
//    server_address.sin_addr.s_addr = address;
//	
//	// Bad IP or possibly a DNS address
//    if (server_address.sin_addr.s_addr == INADDR_NONE)
//	{
//		// Check DNS
//		char portstr[10];
//		snprintf(portstr, 10-1, "%d", port);
//		
//		struct addrinfo hints, *p, *servinfo;
//		
//		memset(&hints, 0, sizeof hints);
//		hints.ai_family = AF_INET;
//		hints.ai_socktype = SOCK_STREAM;
//		
//		// get ready to connect
//		if ((z = getaddrinfo(addr, portstr, &hints, &servinfo)) != 0) {
//			fprintf(stderr, "getaddrinfo error: %s\n", gai_strerror(z));
//		}
//		
//		for(p = servinfo;p != NULL; p = p->ai_next)
//		{
//			// get the pointer to the address itself,
//			// different fields in IPv4 and IPv6:
//			if (p->ai_family == AF_INET) { // IPv4
//				struct sockaddr_in *ipv4 = (struct sockaddr_in *)p->ai_addr;
//				server_address.sin_addr = ipv4->sin_addr;
//				z = 1;
//			} else { // IPv6
//				printf("no ipv6 support");
//				//            struct sockaddr_in6 *ipv6 = (struct sockaddr_in6 *)p->ai_addr;
//				//            server_address.sin6_addr = ipv6->sin6_addr;
//				z = 0;
//			}
//		}
//		
//		// servinfo now points to a linked list of 1 or more struct addrinfos
//		freeaddrinfo(servinfo); // free the linked-list
//		
//		if(z == 0)
//		{
//			fprintf(stderr, "No DNS found\n");
//		}
//	}
//	
//	if(z == 0)
//		[self failure:@"no address"];
}

-(void) closeSocket
{
	// Remove data read option
	CFOptionFlags sockopt = CFSocketGetSocketFlags (cfsocket);
	sockopt &= kCFSocketDataCallBack;
	CFSocketSetSocketFlags(cfsocket, sockopt);
	
	CFSocketInvalidate(cfsocket);
	CFRelease(cfsocket);
}

-(void) setupSocket
{
	CFRunLoopSourceRef rls;
	CFSocketContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
	CFSocketCallBackType callbacks = kCFSocketDataCallBack | kCFSocketConnectCallBack;
	cfsocket = CFSocketCreate(kCFAllocatorDefault, AF_INET, SOCK_STREAM, IPPROTO_TCP, callbacks, socketCallback, &context);

	if(cfsocket == NULL)
		NSLog(@"CFSocket failure");
	
	rls = CFSocketCreateRunLoopSource(NULL, cfsocket, 0);
	assert(rls != NULL);
	
	CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopDefaultMode);
	
	CFRelease(rls);
}

#pragma mark decode

-(NSDictionary *) decodeMessage:(NSString *)command
{
	NSCharacterSet *delim = [NSCharacterSet characterSetWithCharactersInString:@","];
	NSArray *options = [command componentsSeparatedByCharactersInSet:delim];

	NSArray *pieces;
	NSCharacterSet *equal = [NSCharacterSet characterSetWithCharactersInString:@"="];
	NSMutableDictionary *rdict = [NSMutableDictionary dictionary];
	
	for(int i=0; i<[options count]; i++)
	{
		pieces = [options[i] componentsSeparatedByCharactersInSet:equal];

		if([pieces count] == 2)
		{
			[rdict setObject:pieces[1] forKey:pieces[0]];
		}
	}
	
	return rdict;
}

#pragma mark Command Wrangling

-(void) setupCommand:(NSString *)command address:(NSString *)address port:(NSNumber *)port caller:(id)caller key:(NSString *)key
{
	canSend = FALSE;
	hasHostname = FALSE;
    self.caller = caller;
    self.key = key;
	self.command = command;
	self.address = address;
	self.port = port;
	[self setupAddress:_address port:_port];
}

-(void) checkStatus
{
	if(hasHostname && canSend)
	{
		NSLog(@"SENDING MESSAGE %d %d",hasHostname,canSend);
		[self connect];
	}
	else
		NSLog(@"not yet ready %d %d",hasHostname,canSend);
}

-(void) sendCommand
{
	canSend = TRUE;
	[self checkStatus];
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
		[self setupSocket];
        self.active = NO;
    }
    
    return self;
}

@end
