//
//  DataRequest.h
//  CanadaVisa
//
//  Created by Nathan Van Fleet on 11-10-26.
//  Copyright (c) 2011 Logic Pretzel. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol DataRequestDelegate;

@interface DataRequest : NSObject {
    BOOL active;
    int com_socket;
    id callback;
}
@property BOOL active;
@property (retain,nonatomic) id callback;

+ (DataRequest *) dataRequest;
-(void) sendCommand:(NSString *)command address:(NSString *)address port:(NSNumber *)port callback:(id)cb;
@end


@protocol DataRequestDelegate <NSObject>
- (void) dataManagerDidFail:(DataRequest *)nm message:(NSString *)message;
- (void) dataManagerDidSucceed:(DataRequest *)nm withObject:(id)object;
@end