//
//  SavedDataManager.h
//  Coffeed
//
//  Created by Nathan Van Fleet on 12-10-01.
//  Copyright (c) 2012 Nathan Van Fleet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerConfiguration.h"

@interface SavedDataManager : NSObject

-(NSMutableDictionary *) configurations;
-(void) addServer:(NSDictionary *)dictionary;
-(void) deleteServer:(NSString *)dictionary;

-(ServerConfiguration *) selectedServer;
-(void) setSelectedServer:(ServerConfiguration *)server;
@end
