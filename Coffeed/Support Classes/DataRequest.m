//
//  DataRequest.m
//  CanadaVisa
//
//  Created by Nathan Van Fleet on 11-10-26.
//  Copyright (c) 2011 Logic Pretzel. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>

#import "DataRequest.h"

#import "ServerConfiguration.h"
#import "DataRequestManager.h"

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
-(void) sendData;
-(void) decodeData:(NSString *)data;
-(void) failure:(NSString *)failMessage;
-(void) setServerAddress:(struct in_addr)resolvedaddr;
@end

static void hostnameCallback(CFHostRef inHostInfo, CFHostInfoType inType, const CFStreamError *inError, void *info)
{
	DataRequest *client = (__bridge DataRequest *) info;
	
	NSLog();
	
	if(inError->error == noErr)
	{
		DataRequest *client = (__bridge DataRequest *) info;
		NSArray *addresses = (__bridge NSArray *) CFHostGetAddressing(inHostInfo, NULL);
		CFDataRef address = (__bridge CFDataRef) [addresses objectAtIndex:0];
		// just grab 1st
		struct sockaddr_in *addr =(struct sockaddr_in *)CFDataGetBytePtr(address);
		
		[client setServerAddress:addr->sin_addr];
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
	{
		NSString *receivedData = [[NSString alloc] initWithData:(__bridge NSData *)data encoding:NSUTF8StringEncoding];
		[client decodeData:receivedData];
	}
	else if(type == kCFSocketWriteCallBack)
	{
		[client sendData];
	}
}

@implementation DataRequest

-(void) failure:(NSString *)failMessage
{
	[self.caller dataManagerDidFail:self withObject:failMessage];
	[[DataRequestManager sharedInstance] removeRequestFromQueue:self];
}

#pragma mark decode

-(NSDictionary *) decodeMessageToDict:(NSString *)command
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

-(void) decodeData:(NSString *)response
{
	if(response != nil)
	{
		NSDictionary *message = [self decodeMessageToDict:response];
		[self.caller dataManagerDidSucceed:self withObject:message];
		[[DataRequestManager sharedInstance] removeRequestFromQueue:self];
	}
	else
		[self failure:@"no response"];
}

#pragma mark CFSocket

-(void) sendData
{
	CFSocketError error;
	CFTimeInterval timeout = 5;
	const char *cmd = [_command UTF8String];
	
	CFDataRef data = CFDataCreate(NULL, (UInt8 *) cmd, strlen(cmd)*sizeof(char)+1);
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
	
	CFRelease(hostRef);
}

-(void) setServerAddress:(struct in_addr)resolvedaddr
{
	if (resolvedaddr.s_addr == INADDR_NONE)
	{
		[self failure:@"bad address"];
		return;
	}
	
	[self setResolvedHost:[NSString stringWithFormat:@"%s",inet_ntoa(resolvedaddr)]];
}

-(void) setResolvedHost:(NSString *)resolved
{
	_server.resolvedAddress = resolved;
	
	server_address.sin_addr.s_addr = inet_addr([resolved UTF8String]);
	server_address.sin_port = htons([_server.port intValue]);
	
	[self checkStatus];
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
	CFSocketCallBackType callbacks = kCFSocketDataCallBack | kCFSocketWriteCallBack;
//	CFSocketCallBackType callbacks = kCFSocketDataCallBack | kCFSocketConnectCallBack | kCFSocketWriteCallBack | kCFSocketReadCallBack | kCFSocketAcceptCallBack;
	cfsocket = CFSocketCreate(kCFAllocatorDefault, AF_INET, SOCK_STREAM, IPPROTO_TCP, callbacks, socketCallback, &context);

	if(cfsocket == NULL)
		[self failure:@"CFSocket failure"];
	
	rls = CFSocketCreateRunLoopSource(NULL, cfsocket, 0);

	if(rls == NULL)
		[self failure:@"Runloop failure"];
	
	CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopDefaultMode);
	
	CFRelease(rls);
}

#pragma mark Command Wrangling

-(void) setupCommand:(NSString *)command configuration:(ServerConfiguration *)config caller:(id)caller key:(NSString *)key
{
	self.server = config;
    self.caller = caller;
	self.command = command;
    self.key = key;
	
	if(_server.resolvedAddress)
		[self setResolvedHost:_server.resolvedAddress];
	else
		[self resolveHost:_server.address];
}

-(void) checkStatus
{
	if(_server.resolvedAddress && canSend)
	{
		[self connect];
	}
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

-(void) dealloc
{
	[self closeSocket];
}

-(id) init
{
    if((self = [super init]))
    {
		memset(&server_address, 0, sizeof(server_address));
		server_address.sin_family = AF_INET;
		
		[self setupSocket];
	
		canSend = FALSE;
    }
    
    return self;
}

@end
