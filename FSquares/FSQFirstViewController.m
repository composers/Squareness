//
//  FSQFirstViewController.m
//  FSquares
//
//  Created by Stefan Stolevski on 7/12/14.
//  Copyright (c) 2014 Stefan Stolevski. All rights reserved.
//

#import "FSQFirstViewController.h"
#import "UIImage+Resize.h"

@interface FSQFirstViewController ()

@end

@implementation FSQFirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        UITabBarItem * tabBarItem = [[UITabBarItem alloc] initWithTitle: @"new image"
                                                                image: nil //or your icon
                                                                  tag: 0];
        [self setTabBarItem:tabBarItem];
        
        UIImage *backgroundImage = [[UIImage imageNamed:@"squares_drawing.jpg"] resizedImageToSize:self.view.frame.size];
        
        self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
