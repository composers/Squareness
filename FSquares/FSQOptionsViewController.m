//
//  FSQOptionsViewController.m
//  FSquares
//
//  Created by Stefan Stolevski on 7/12/14.
//  Copyright (c) 2014 Stefan Stolevski. All rights reserved.
//

#import "FSQOptionsViewController.h"
#import "FSQModelController.h"

@interface FSQOptionsViewController ()

@end

@implementation FSQOptionsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UITabBarItem * tabBarItem = [[UITabBarItem alloc] initWithTitle: @"options"
                                                                  image: nil //or your icon
                                                                    tag: 0];
        [self setTabBarItem:tabBarItem];
        self.filterPicker.delegate = self;
        self.filterPicker.dataSource = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
    FSQModelController *modelController = [FSQModelController sharedInstance];
    modelController.filterNameSelectedCI = [modelController.filterNamesCI objectAtIndex:row];
    
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    FSQModelController *modelController = [FSQModelController sharedInstance];
    return modelController.filterNamesUI.count;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    FSQModelController *modelController = [FSQModelController sharedInstance];
    return [modelController.filterNamesUI objectAtIndex:row];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)usePredefinedFilterStatusChanged:(UISegmentedControl *)sender {
    FSQModelController *modelController = [FSQModelController sharedInstance];
    
    switch (sender.selectedSegmentIndex) {
        case 0:
            [self.filterPicker setHidden:YES];
            modelController.usePreselectedFilterStatus = NO;
            break;
        case 1:
            [self.filterPicker setHidden:NO];
            modelController.usePreselectedFilterStatus = YES;
            break;
        default:
            break;
    }
}

- (IBAction)gridStatusChanged:(UISegmentedControl *)sender {
    FSQModelController *modelController = [FSQModelController sharedInstance];

    if (sender.selectedSegmentIndex == 0) {
        modelController.gridStatus = YES;
    }
    
    if (sender.selectedSegmentIndex == 1) {
        modelController.gridStatus = NO;
    }
    
}
@end
