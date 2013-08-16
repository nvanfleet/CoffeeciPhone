// Copyright (C) 2013 Nathan Van Fleet
//
// This is free software, licensed under the GNU General Public License v2.
// See /LICENSE for more information.
//
//  DataRequest.h
//  CanadaVisa
//
//  Created by Nathan Van Fleet on 11-10-26.
//  Copyright (c) 2011 Logic Pretzel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ServerConfiguration;
@protocol DataRequestDelegate;

@interface DataRequest : NSObject
@property (strong) id caller;
@property (nonatomic) NSString *key;
@property (nonatomic) NSString *command;
@property (nonatomic) ServerConfiguration *server;

+ (DataRequest *) dataRequest;
-(void) setupCommand:(NSString *)command configuration:(ServerConfiguration *)config caller:(id)caller key:(NSString *)key;
-(void) sendCommand;
@end

@protocol DataRequestDelegate <NSObject>
- (void) dataManagerDidFail:(DataRequest *)nm withObject:(id)object;
- (void) dataManagerDidSucceed:(DataRequest *)nm withObject:(id)object;
@end
