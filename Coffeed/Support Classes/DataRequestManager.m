//
//  DataManager.m
//  CanadaVisa
//
//  Created by Nathan Mcdavitt-Van Fleet on 11-07-13.
//  Copyright 2011 Logic Pretzel. All rights reserved.
//

#import "DataRequestManager.h"


@interface DataRequestManager ()
@property (strong) NSMutableArray *dataRequests;
@property (strong) NSMutableArray *queuedRequests;
@end

@implementation DataRequestManager

#pragma mark - Data Requests

-(DataRequest *) freeDataRequest
{
    DataRequest *dr = nil;
    
    for(int i=0; i<[_dataRequests count]; i++)
    {
        dr = [_dataRequests objectAtIndex:i];
        
        if(![dr active])
        {
			dr.active = YES;
            return dr;
        }
    }
    
    dr = [DataRequest dataRequest];
    [_dataRequests addObject:dr];
	dr.active = YES;
    
    return dr;
}

-(void) removeRequestFromQueue:(DataRequest *)request
{
	[self.queuedRequests removeObject:request];
	
	request.active = NO;
	
	// If there are anymore than send another command
	if([self.queuedRequests count] > 0)
//		dispatch_async(dispatch_get_main_queue(), ^{
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{		
			[[self.queuedRequests objectAtIndex:0] sendCommand];
		});
}

#pragma mark Coffee

-(void) queueCommand:(NSString *)command caller:(id)caller key:(NSString *)key configuration:(ServerConfiguration *)configuration
{
	if(!configuration)
	{
		NSLog(@"no configuration so no sending request");
		return;
	}
	
	DataRequest *request = [self freeDataRequest];
	[request setupCommand:command address:configuration.address port:configuration.port caller:caller key:key];
	
	int queuedRequests = [self.queuedRequests count];
	
	// Queue request
	[self.queuedRequests addObject:request];
	
	// If it's the only object then run it immediately
	if(queuedRequests == 0)
//		dispatch_async(dispatch_get_main_queue(), ^{
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[request sendCommand];
		});
}

-(void) queueCommand:(NSString *)command caller:(id)caller key:(NSString *)key
{
	ServerConfiguration *as = [self activeServer];
	
	[self queueCommand:command caller:caller key:key configuration:as];
}

-(void) queueCommand:(NSString *)command caller:(id)caller
{
	[self queueCommand:command caller:caller key:command];
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
        self.dataRequests = [[NSMutableArray alloc] init];
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
