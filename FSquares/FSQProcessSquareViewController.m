//
//  FSQProcessSquareViewController.m
//  FSquares
//
//  Created by Stefan Stolevski on 7/14/14.
//  Copyright (c) 2014 Stefan Stolevski. All rights reserved.
//

#import "FSQProcessSquareViewController.h"
#import "FSQModelController.h"
#import "UIImage+Resize.h"
#import "FSQImageViewController.h"

@interface FSQProcessSquareViewController ()

@end

@implementation FSQProcessSquareViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    FSQModelController *modelController = [FSQModelController sharedInstance];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    [self.imageView setImage:modelController.selectedSubImageView.image];
  
    NSString *imgPath= [[NSBundle mainBundle] pathForResource:@"squares" ofType:@"jpg"];
    UIImage *backgroundImage = [UIImage imageWithContentsOfFile:imgPath];
    self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    
    CALayer * l = [self.imageView layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:45.0];
    
    [self.imageView.layer setBorderColor: [[UIColor blackColor] CGColor]];
    [self.imageView.layer setBorderWidth: 3.0];
}

- (void)viewWillAppear:(BOOL)animated{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


- (IBAction)apply:(id)sender {
    FSQModelController *modelController = [FSQModelController sharedInstance];
    
    self.imageView.image = [modelController processImage:self.imageView.image withFilterName:modelController.filterNameSelectedCI];
    
    modelController.selectedSubImageView.image = [modelController processImage:modelController.selectedSubImageView.image withFilterName:modelController.filterNameSelectedCI];
    
    UIView *rootView = modelController.selectedSubImageView.superview.superview;
    modelController.processedImage = [modelController snapshot:rootView];
    
    if (modelController.gridStatus == YES) {
        [modelController removeBorderAroundImageViewsFromView:rootView];
    }
    modelController.image = modelController.processedImage;
}

- (IBAction)reset:(id)sender {
}

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
