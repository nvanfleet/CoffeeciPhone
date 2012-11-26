//
//  GraphViewController.m
//  Coffeed
//
//  Created by Nathan Van Fleet on 2012-11-18.
//  Copyright (c) 2012 Nathan Van Fleet. All rights reserved.
//

#import "GraphViewController.h"

@interface GraphViewController ()
@property (strong) NSTimer *timer;
@end

@implementation GraphViewController

#pragma mark - Data

- (void) dataManagerDidFail:(DataRequest *)nm withObject:(id)object
{
	[self scheduleUpdate];
	
	self.statusImage.image = [UIImage imageNamed:@"21-skull"];
}

- (void) dataManagerDidSucceed:(DataRequest *)nm withObject:(id)object
{
	[self scheduleUpdate];
	
	self.statusImage.image = [UIImage imageNamed:@"23-bird"];
	
	[_lineChartView addPoints:(NSDictionary *) object];
}

#pragma mark - Charts

-(void) setupChart
{
	PCLineChartViewComponent *component;
	NSMutableArray *components = [NSMutableArray array];
	
	// Power
	component = [[PCLineChartViewComponent alloc] init];
	[component setTitle:@"Heater"];
	[component setKey:@"POW"];
	[component setLabelFormat:@"%.0f%%"];
	[component setColour:PCColorOrange];
	[components addObject:component];
	
	// Setpoint
	component = [[PCLineChartViewComponent alloc] init];
	[component setTitle:@"Target"];
	[component setKey:@"SETPOINT"];
	[component setLabelFormat:@"%.1f"];
	[component setColour:PCColorGreen];
	[components addObject:component];
	
	// Temperature
	component = [[PCLineChartViewComponent alloc] init];
	[component setTitle:@"Temp"];
	[component setKey:@"TPOINT"];
	[component setLabelFormat:@"%.1f"];
	[component setColour:PCColorRed];
	[components addObject:component];
	
	// Temperature
	component = [[PCLineChartViewComponent alloc] init];
	[component setTitle:@"Pt"];
	[component setKey:@"PTERM"];
	[component setLabelFormat:@"%.1f"];
	[component setColour:[UIColor purpleColor]];
	[components addObject:component];
	
	// Temperature
	component = [[PCLineChartViewComponent alloc] init];
	[component setTitle:@"It"];
	[component setKey:@"ITERM"];
	[component setLabelFormat:@"%.1f"];
	[component setColour:[UIColor blueColor]];
	[components addObject:component];
	
	// Temperature
	component = [[PCLineChartViewComponent alloc] init];
	[component setTitle:@"Dt"];
	[component setKey:@"DTERM"];
	[component setLabelFormat:@"%.1f"];
	[component setColour:[UIColor yellowColor]];
	[components addObject:component];
	
	[_lineChartView setComponents:components];
	[_lineChartView setAutoscaleYAxis:YES];
}

#pragma mark - Basic and Data

-(void) updateGraphData
{
	[[DataRequestManager sharedInstance] queueCommand:@"SETPOINT,TPOINT,POW,PTERM,ITERM,DTERM" caller:self key:@"graphdata"];
}

-(void) scheduleUpdate
{
//	if(self.isViewLoaded && self.view.window)
//	{
		[self.timer invalidate];
		self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateGraphData) userInfo:nil repeats:NO];
//	}
}

-(void) viewWillAppear:(BOOL)animated
{
	[self scheduleUpdate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// Custom initialization
//	self.lineChartView = [[PCLineChartView alloc] initWithFrame:CGRectMake(10,10,[self.view bounds].size.width-20,[self.view bounds].size.height-20)];
//	[_lineChartView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
//	_lineChartView.minValue = -40;
//	_lineChartView.maxValue = 100;
//	[self.view addSubview:_lineChartView];
	
	[self setupChart];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
