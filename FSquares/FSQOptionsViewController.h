//
//  FSQOptionsViewController.h
//  FSquares
//
//  Created by Stefan Stolevski on 7/12/14.
//  Copyright (c) 2014 Stefan Stolevski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSQOptionsViewController : UIViewController  <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *gridStatus;
@property (weak, nonatomic) IBOutlet UIPickerView *filterPicker;
@property (strong,nonatomic) NSArray *filterNames;
@property (strong, nonatomic) NSString *filterNameCoreImageSelected;
@property (weak, nonatomic) IBOutlet UISegmentedControl *usePredefinedFilterStatus;

- (IBAction)usePredefinedFilterStatusChanged:(UISegmentedControl *)sender;

@end
