//
//  FSQOptionsViewController.h
//  FSquares
//
//  Created by Stefan Stolevski on 7/12/14.
//  Copyright (c) 2014 Stefan Stolevski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSQOptionsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISegmentedControl *gridStatus;
- (IBAction)gridStatusChanged:(UISegmentedControl *)sender;
- (IBAction)savePhoto:(UIButton *)sender;
- (IBAction)squareSizeChanged:(UISegmentedControl *)sender;
@end
