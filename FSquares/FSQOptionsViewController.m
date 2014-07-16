//
//  FSQOptionsViewController.m
//  FSquares
//
//  Created by Stefan Stolevski on 7/12/14.
//  Copyright (c) 2014 Stefan Stolevski. All rights reserved.
//

#import "FSQOptionsViewController.h"
#import "FSQModelController.h"
#import "UIImage+Resize.h"

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
      
      NSString *imgPath= [[NSBundle mainBundle] pathForResource:@"squares" ofType:@"jpg"];
      UIImage *backgroundImage = [UIImage imageWithContentsOfFile:imgPath];        
      self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.filterPicker.delegate = self;
    self.filterPicker.dataSource = self;
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
  FSQModelController *modelController = [FSQModelController sharedInstance];
  modelController.image = nil;
  modelController.processedImage = nil;
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

- (IBAction)savePhoto:(UIButton *)sender {
  FSQModelController *modelController = [FSQModelController sharedInstance];
  UIImageWriteToSavedPhotosAlbum(modelController.processedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *alertTitle;
    NSString *alertMessage;
    
    if(!error)
    {
        alertTitle   = @"Image Saved";
        alertMessage = @"Image saved to photo album successfully.";
    }
    else
    {
        alertTitle   = @"Error";
        alertMessage = @"Unable to save to photo album.";
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                    message:alertMessage
                                                   delegate:self
                                          cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil];
    [alert show];
}

- (IBAction)squareSizeChanged:(UISegmentedControl *)sender {
    FSQModelController *model = [FSQModelController sharedInstance];
    
    switch (sender.selectedSegmentIndex) {
        case 0:
            model.gridSquareSize = 40;
            break;
        case 1:
            model.gridSquareSize = 80;
            break;
        case 2:
            model.gridSquareSize = 160;
            break;
        case 3:
            model.gridSquareSize = -1;
            break;
        default:
            break;
    }

}


@end
