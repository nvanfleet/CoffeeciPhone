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
	int response;
	int bsize = 256;
	char buffer[bsize];

	response = sendMessage((char *) [self.address UTF8String], [self.port intValue], (char *) [self.command UTF8String], buffer, bsize);
	
	if(response)
		[self.caller dataManagerDidSucceed:self withObject:[NSString stringWithCString:(const char *) buffer encoding:NSUTF8StringEncoding]];
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
