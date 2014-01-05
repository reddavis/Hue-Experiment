//
//  HUERootViewController.m
//  Hue Ambience
//
//  Created by Red Davis on 02/01/2014.
//  Copyright (c) 2014 Red Davis. All rights reserved.
//

#import "HUERootViewController.h"
#import "HUEHomeViewController.h"


@interface HUERootViewController ()

@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) HUEHomeViewController *homeViewController;

@end


@implementation HUERootViewController

#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
	{
		self.homeViewController = [[HUEHomeViewController alloc] initWithNibName:nil bundle:nil];
		self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.homeViewController];
		
		[self addChildViewController:self.navigationController];
    }
	
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.view addSubview:self.navigationController.view];	
}

- (void)viewDidLayoutSubviews
{
	CGRect bounds = self.view.bounds;
	self.navigationController.view.frame = bounds;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
