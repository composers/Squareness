//
//  FSQOptionsViewController.h
//  Squareness
//
//  Created by Stefan Stolevski on 7/12/14.
//  Copyright (c) 2014 Stefan Stolevski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSQBaseViewController.h"

@interface FSQOptionsViewController : FSQBaseViewController

//@property (weak, nonatomic) IBOutlet UIView *gridStatusCheckboxContainer;
@property (weak, nonatomic) IBOutlet UIScrollView *chooseFiltersCheckboxContainer;
- (IBAction)squareSizeChanged:(UISegmentedControl *)sender;
@end
