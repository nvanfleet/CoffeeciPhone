//
//  DataManager.h
//  CanadaVisa
//
//  Created by Nathan Mcdavitt-Van Fleet on 11-07-13.
//  Copyright 2011 Logic Pretzel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataRequest.h"

@interface DataRequestManager : NSObject {
    NSMutableArray *dataRequests;
    
    NSString *ipaddress;
    NSNumber *port;
}

@property (retain,nonatomic) NSNumber *port;
@property (retain,nonatomic) NSString *ipaddress;

+ (id)sharedInstance;

-(void) sendCommand:(NSString *)command callback:(id)cb;
@end
