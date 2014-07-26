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
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"
#import "CarouselViewController.h"
#import "MLPSpotlight.h"

@interface FSQOptionsViewController ()

@end

@implementation FSQOptionsViewController

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
    [MLPSpotlight addSpotlightInView:self.view atPoint:self.view.center];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.view setAlpha:0];
    [UIView animateWithDuration:0.9
                          delay:0.1
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.view setAlpha:1.0];
                     }completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
  modelController.image = nil;
}


- (IBAction)gridStatusChanged:(UISegmentedControl *)sender {
    
    UINavigationController *navigationController = (UINavigationController *)self.sidePanelController.centerPanel;
    CarouselViewController *carouselController = [navigationController.viewControllers objectAtIndex:0];
    
    if (sender.selectedSegmentIndex == 0) {
        modelController.gridStatus = YES;
        [modelController putBorderWithWidth:0.8 aroundImageViewsFromView:carouselController.scrollView];
    
    }
    
    if (sender.selectedSegmentIndex == 1) {
        modelController.gridStatus = NO;
        [modelController removeBorderAroundImageViewsFromView:carouselController.scrollView];
    }
    
}


- (IBAction)savePhoto:(UIButton *)sender {
  UIImageWriteToSavedPhotosAlbum(modelController.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
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
    
    switch (sender.selectedSegmentIndex) {
        case 0:
            modelController.gridSquareSize = 20;
            break;
        case 1:
            modelController.gridSquareSize = 40;
            break;
        case 2:
            modelController.gridSquareSize = 80;
            break;
        case 3:
            modelController.gridSquareSize = 160;
            break;
        default:
            break;
    }
    
    [self performSelector:@selector(applySquareSizeChanges) withObject:nil afterDelay:0.2];
}
- (void)applySquareSizeChanges{
    UINavigationController *navigationController = (UINavigationController *)self.sidePanelController.centerPanel;
    CarouselViewController *carouselController = [navigationController.viewControllers objectAtIndex:0];
    
    if (modelController.gridStatus == YES) {
        [modelController removeBorderAroundImageViewsFromView:carouselController.scrollView];
    }
    modelController.image = [modelController snapshot:carouselController.scrollView];
    
    modelController.subImageViews = [modelController divideImage];
    [modelController putSubImageViews:[modelController divideImage] InView:carouselController.scrollView];
    [modelController addGestureRecognizersToSubviewsFromView:carouselController.scrollView andViewController:carouselController];
    
    if (modelController.gridStatus == YES) {
        [modelController putBorderWithWidth:0.8 aroundImageViewsFromView:carouselController.scrollView];
    }
    if (modelController.gridStatus == NO) {
        [modelController removeBorderAroundImageViewsFromView:carouselController.scrollView];
    }

    
}

@end
