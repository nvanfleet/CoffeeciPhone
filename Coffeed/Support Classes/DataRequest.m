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

@implementation DataRequest
@synthesize active;

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
    self.caller = caller;
    self.key = key;
	self.command = command;
	self.address = address;
	self.port = port;
}

-(NSString *) messageHandle
{
	int response;
	int bsize = 256;
	char buffer[bsize];
	
	response = sendMessage((char *) [self.address UTF8String], [self.port intValue], (char *) [self.command UTF8String], buffer, bsize);
	
	return [NSString stringWithCString:(const char *) buffer encoding:NSUTF8StringEncoding];
}

-(void) sendCommand
{
//	NSString *response = [self sendCommand:self.command domain:self.address port:self.port];
	NSString *response = [self messageHandle];
	
	if(response != nil)
	{
		NSDictionary *message = [self decodeMessage:response];
		[self.caller dataManagerDidSucceed:self withObject:message];
	}
	else
		[self.caller dataManagerDidFail:self withObject:nil];
	
	// Remove from queue
	[[DataRequestManager sharedInstance] removeRequestFromQueue:self];
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
