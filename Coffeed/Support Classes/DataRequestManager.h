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

@interface DataRequestManager : NSObject

+(id) sharedInstance;
-(void) sendCommand:(NSString *)command callback:(id)cb;
-(void) setCurrentServer:(ServerConfiguration *)sConf;

@end
