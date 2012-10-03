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
            return dr;
        }
    }
    
    dr = [DataRequest dataRequest];
    [_dataRequests addObject:dr];
    
    return dr;
}

#pragma mark - Data Cache

/*
-(NSString *) cacheFile
{
    NSString *fileName = @"CacheFile.plist";
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *component = [NSString stringWithFormat:@"/Preferences/%@",fileName];
    
	return [documentsDirectory stringByAppendingPathComponent:component];
}

-(void) saveCache:(id)object key:(NSString *)key
{
    NSString *file = [self cacheFile];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:file];
    
    if(dict == NULL)
        dict = [NSMutableDictionary dictionary];
    
    if([object isKindOfClass:[NSDictionary class]])
    {
        object = [self cleanNullFromDict:(NSDictionary*)object];
    }
    
    [dict setObject:object forKey:key];
    
    [dict writeToFile:file atomically:YES];
}

-(void) removeCache:(NSString *)key
{
    NSString *file = [self cacheFile];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:file];
    
    [dict removeObjectForKey:key];
    
    [dict writeToFile:file atomically:YES];
}

-(NSObject *) getCache:(NSString *)key
{
    NSString *file = [self cacheFile];
    
    return [[NSDictionary dictionaryWithContentsOfFile:file] objectForKey:key];
}
*/

-(void) removeRequestFromQueue:(DataRequest *)request
{
	NSLog(@"remove request");
	[self.dataRequests removeObject:request];
	
	// If there are anymore than send another command
	if([self.queuedRequests count] > 0)
		dispatch_async(dispatch_get_main_queue(), ^{
			[[self.queuedRequests objectAtIndex:0] sendCommand];
		});
}

#pragma mark Coffee

-(void) queueCommand:(NSString *)command caller:(id)caller key:(NSString *)key
{
	if(![self activeServer])
	{
		NSLog(@"no configuration so no sending request");
		return;
	}
	
	ServerConfiguration *as = [self activeServer];
	DataRequest *request = [self freeDataRequest];
	[request setupCommand:command address:as.address port:as.port caller:caller key:key];
	
	int queuedRequests = [self.queuedRequests count];
	
	// Queue request
	[self.queuedRequests addObject:request];
	
	// If it's the only object then run it immediately
	if(queuedRequests == 0)
		dispatch_async(dispatch_get_main_queue(), ^{
			[request sendCommand];
		});
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
