//
//  CarouselViewController.m
//  FSquares
//
//  Created by Stefan Stolevski on 7/19/14.
//  Copyright (c) 2014 Stefan Stolevski. All rights reserved.
//

#import "CarouselViewController.h"
#import "FSQModelController.h"
#import "UIImage+Resize.h"

@interface CarouselViewController ()

@end

@implementation CarouselViewController

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
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"image processing";
    UIBarButtonItem* buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"->" style:UIBarButtonItemStyleBordered target:nil action:nil];
    buttonItem.enabled = NO;
    [self.navigationItem setRightBarButtonItem:buttonItem];
    //configure carousel
    _carousel.type = iCarouselTypeLinear;
    _carousel.backgroundColor = [UIColor blackColor];
    _carousel.delegate = self;
    _carousel.dataSource = self;
    
    self.scrollView.scrollEnabled = YES;
    CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
    self.scrollView.contentSize = screenFrame.size;
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    //    if (modelController.image == nil) {
    //        UIAlertView *alert = [UIAlertView alloc] initWithTitle: message:<#(NSString *)#> delegate:<#(id)#> cancelButtonTitle:<#(NSString *)#> otherButtonTitles:<#(NSString *), ...#>, nil
    //    }
    
    [modelController divideImage:modelController.image withBlockSize:modelController.gridSquareSize andPutInView:self.scrollView];
    [modelController addGestureRecognizersToSubviewsFromView:self.scrollView andViewController:self];
    
    if (modelController.gridStatus == YES) {
        [modelController putBorderWithWidth:1.0 aroundImageViewsFromView:self.scrollView];
    }
    if (modelController.gridStatus == NO) {
        [modelController removeBorderAroundImageViewsFromView:self.scrollView];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated{
    
    if (modelController.gridStatus == YES) {
        [modelController removeBorderAroundImageViewsFromView:self.scrollView];
    }
    modelController.image = [modelController snapshot:self.scrollView];
}

- (void)tap:(UITapGestureRecognizer*)gesture
{
    modelController.selectedSubImageView = [modelController getImageViewWithTag:gesture.view.tag fromView:gesture.view.superview];
    
    [self.carousel reloadData];
    
//    if (modelController.usePreselectedFilterStatus == YES) {
//        modelController.selectedSubImageView.image = [modelController processImage:modelController.selectedSubImageView.image withFilterName:modelController.filterNameSelectedCI];
//        
//    }
    
//    if (modelController.usePreselectedFilterStatus == NO) {
//        FSQProcessSquareViewController *processSquareController = [[FSQProcessSquareViewController alloc] init];
//        [self presentViewController:processSquareController animated:YES completion:nil];
//    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    //return the total number of items in the carousel
    return modelController.filterNamesCI.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    NSLog(@"filter index %d", index);
    //create new view if no view is available for recycling
    if (view == nil)
    {
        //don't do anything specific to the index within
        //this `if (view == nil) {...}` statement because the view will be
        //recycled and used with other index values later
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, carousel.frame.size.height, carousel.frame.size.height)];
        view.contentMode = UIViewContentModeCenter;
    }
    
    
    UIImage *outputImage = [modelController processImage:[modelController.selectedSubImageView.image resizedImageToSize:view.frame.size] withFilterName:[modelController.filterNamesCI objectAtIndex:index]];
    ((UIImageView *)view).image = outputImage;

    return view;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index{
    NSLog(@"carousel item selected %d", index);
    
    modelController.filterNameSelectedCI = [modelController.filterNamesCI objectAtIndex:index];
 modelController.selectedSubImageView.image = [modelController processImage:modelController.selectedSubImageView.image withFilterName:modelController.filterNameSelectedCI];
    [carousel reloadData];
    
    
    if (modelController.gridStatus == YES) {
        [modelController removeBorderAroundImageViewsFromView:self.scrollView];
    }
    modelController.image = [modelController snapshot:self.scrollView];
    
    if (modelController.gridStatus == YES) {
        [modelController putBorderWithWidth:1.0 aroundImageViewsFromView:self.scrollView];
    }
    if (modelController.gridStatus == NO) {
        [modelController removeBorderAroundImageViewsFromView:self.scrollView];
    }

    
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if (option == iCarouselOptionSpacing)
    {
        return value * 1.03f;
    }
    return value;
}

@end
