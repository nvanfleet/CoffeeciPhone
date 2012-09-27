//
//  DataManager.m
//  CanadaVisa
//
//  Created by Nathan Mcdavitt-Van Fleet on 11-07-13.
//  Copyright 2011 Logic Pretzel. All rights reserved.
//

#import "DataManager.h"

static NSString * const BOUNDRY = @"0xKhTmLbOuNdArY";

static DataManager *sharedInstance = nil;

@implementation DataManager

@synthesize port, ipaddress;

#pragma mark - Data Requests

-(DataRequest *) freeDataRequest
{
    DataRequest *dr = nil;
    
    for(int i=0; i<[dataRequests count]; i++)
    {
        dr = [dataRequests objectAtIndex:i];
        
        if(![dr active])
        {
            return dr;
        }
    }
    
    dr = [DataRequest dataRequest];
    [dataRequests addObject:dr];
    
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
    DataRequest *dr = [self freeDataRequest];
    [dr sendCommand:command address:ipaddress port:port callback:cb];
}

#pragma mark - Singleton

// Get the shared instance and create it if necessary.
-(id) init
{
    if((self = [super init]))
    {
        self.ipaddress = @"192.168.1.64";
        self.port = [NSNumber numberWithInt:4949];
        dataRequests = [[NSMutableArray alloc] init];
    }
    
    return self;
}

+(DataManager *)sharedInstance {
    static dispatch_once_t pred;
    static DataManager *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[DataManager alloc] init];
    });
    return shared;
}

//+ (DataManager*) sharedInstance 
//{
//    if (sharedInstance == nil) {
//        sharedInstance = [[super allocWithZone:NULL] init];
//    }
//    
//    return sharedInstance;
//}
//
//// We don't want to allocate a new instance, so return the current one.
//+ (id)allocWithZone:(NSZone*)zone {
//    return [[self sharedInstance] retain];
//}
//
//// Equally, we don't want to generate multiple copies of the singleton.
//- (id)copyWithZone:(NSZone *)zone {
//    return self;
//}
//
//// Once again - do nothing, as we don't have a retain counter for this object.
//- (id)retain {
//    return self;
//}
//
//// Replace the retain counter so we can never release this object.
//- (NSUInteger)retainCount {
//    return NSUIntegerMax;
//}
//
//// This function is empty, as we don't want to let the user release this object.
//- (oneway void)release {
//    
//}
//
////Do nothing, other than return the shared instance - as this is expected from autorelease.
//- (id)autorelease {
//    return self;
//}
@end
