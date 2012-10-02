//
//  DataManager.m
//  CanadaVisa
//
//  Created by Nathan Mcdavitt-Van Fleet on 11-07-13.
//  Copyright 2011 Logic Pretzel. All rights reserved.
//

#import "DataRequestManager.h"

@interface DataRequestManager ()
@property (strong) ServerConfiguration *serverConf;
@property (strong) NSMutableArray *dataRequests;
@end

static NSString * const BOUNDRY = @"0xKhTmLbOuNdArY";

//static DataManager *sharedInstance = nil;

@implementation DataRequestManager

-(void) setCurrentServer:(ServerConfiguration *)sConf
{
	self.serverConf = sConf;
}

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

#pragma mark Coffee

-(void) sendCommand:(NSString *)command callback:(id)cb
{
	if(!_serverConf)
	{
		NSLog(@"no configuration so no sending request");
		return;
	}
	
	DataRequest *dr = [self freeDataRequest];
    [dr sendCommand:command address:_serverConf.address port:_serverConf.port callback:cb];
}

#pragma mark - Singleton

// Get the shared instance and create it if necessary.
-(id) init
{
    if((self = [super init]))
    {
        self.dataRequests = [[NSMutableArray alloc] init];
		_serverConf = nil;
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
