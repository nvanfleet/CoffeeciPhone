// Copyright (C) 2013 Nathan Van Fleet
//
// This is free software, licensed under the GNU General Public License v2.
// See /LICENSE for more information.
//
//  DataManager.h
//  CanadaVisa
//
//  Created by Nathan Mcdavitt-Van Fleet on 11-07-13.
//  Copyright 2011 Logic Pretzel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataRequest.h"
#import "ServerConfiguration.h"
#import "SavedDataManager.h"

@interface DataRequestManager : NSObject
@property (strong) SavedDataManager *savedDataManager;
+(id) sharedInstance;
-(void) checkServerOnline:(ServerConfiguration *)serverConfiguration key:(NSString *)key caller:(id)caller;
-(void) queueCommand:(NSString *)command caller:(id)caller key:(NSString *)key;
-(void) removeRequestFromQueue:(DataRequest *)request;
-(void) flushAllRequests;
@end
