//
//  DataManager.m
//  CanadaVisa
//
//  Created by Nathan Mcdavitt-Van Fleet on 11-07-13.
//  Copyright 2011 Logic Pretzel. All rights reserved.
//

#import "DataRequestManager.h"


@interface DataRequestManager ()
@property (strong) NSMutableArray *queuedRequests;
@end

@implementation DataRequestManager

#pragma mark - Data Requests

-(void) sendNextRequest
{
//	NSLog(@"sending request %@",[self.queuedRequests objectAtIndex:0]);
	//		dispatch_async(dispatch_get_main_queue(), ^{
	//		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
	[[self.queuedRequests objectAtIndex:0] sendCommand];
	//		});
}

-(void) removeRequestFromQueue:(DataRequest *)request
{
	[self.queuedRequests removeObject:request];
	
	// If there are anymore than send another command
	if([self.queuedRequests count] > 0)
		[self sendNextRequest];
}

-(void) flushAllRequests
{
	NSLog(@"flush all requests");
	[self.queuedRequests removeAllObjects];
}

#pragma mark Coffee

-(void) queueCommand:(NSString *)command caller:(id)caller key:(NSString *)key configuration:(ServerConfiguration *)configuration
{
//	NSLog(@"queue command %@",key);
	
	if(!configuration)
	{
		NSLog(@"no configuration so no sending request");
		return;
	}
	
	DataRequest *request = [DataRequest dataRequest];
	[request setupCommand:command configuration:configuration caller:caller key:key];
	
//	NSLog(@"req %@ queuing command %@ key %@",request, command, key);
	
	int queuedRequests = [self.queuedRequests count];
	
	// Queue request
	[self.queuedRequests addObject:request];

	// If it's the only object then run it immediately
	if(queuedRequests == 0)
		[self sendNextRequest];
}

-(void) queueCommand:(NSString *)command caller:(id)caller key:(NSString *)key
{
	ServerConfiguration *as = [self activeServer];
	
	[self queueCommand:command caller:caller key:key configuration:as];
}

-(void) checkServerOnline:(ServerConfiguration *)serverConfiguration key:(NSString *)key caller:(id)caller
{
	[self queueCommand:@"VERSION" caller:caller key:key configuration:serverConfiguration];
}

#pragma mark - Singleton

-(ServerConfiguration *) activeServer
{
	return [self.savedDataManager selectedServer];
}

// Get the shared instance and create it if necessary.
-(id) init
{
    if((self = [super init]))
    {
		self.queuedRequests = [[NSMutableArray alloc] init];
		self.savedDataManager = [[SavedDataManager alloc] init];
    }
    
    return self;
}

+(DataRequestManager *)sharedInstance {
    static dispatch_once_t pred;
    static DataRequestManager *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[DataRequestManager alloc] init];
    });
    return shared;
}

@end
