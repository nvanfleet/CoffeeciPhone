// Copyright (C) 2013 Nathan Van Fleet
//
// This is free software, licensed under the GNU General Public License v2.
// See /LICENSE for more information.
//
//  GraphViewController.h
//  Coffeed
//
//  Created by Nathan Van Fleet on 2012-11-18.
//  Copyright (c) 2012 Nathan Van Fleet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCLineChartView.h"
#import "DataRequestManager.h"

@interface GraphViewController : UIViewController <DataRequestDelegate>
@property (assign) IBOutlet UIImageView *statusImage;
@property (assign) IBOutlet PCLineChartView *lineChartView;
@end
