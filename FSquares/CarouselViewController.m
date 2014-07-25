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
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"
#import "FontAwesomeKit/FAKFontAwesome.h"

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

- (void)applyRandomFilters:(id)sender{
    UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.titleView = aiView;
    [aiView startAnimating];
    [self performSelectorInBackground:@selector(applyRandomFiltersBackground) withObject:nil];
}

- (void)applyRandomFiltersBackground{
    for (UIView *subview in self.scrollView.subviews) {
        UIImageView *subImageView = (UIImageView *)subview;
        subImageView.image = [modelController processImage:subImageView.image withFilterName:[modelController.filterNamesCI objectAtIndex:(arc4random() % modelController.filterNamesCI.count)]];
    }
    
    self.navigationItem.titleView = [self buttonForTitleView];
}

- (UIButton *)buttonForTitleView{
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectZero];
    [button addTarget:self action:@selector(applyRandomFilters:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[[FAKFontAwesome thIconWithSize:30] imageWithSize:CGSizeMake(30.f, 30.f)] forState:UIControlStateNormal];
    [button setImage:[[FAKFontAwesome qrcodeIconWithSize:30] imageWithSize:CGSizeMake(30.f, 30.f)] forState:UIControlStateHighlighted];
    
    [button sizeToFit];
    return button;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor blackColor];

    self.navigationItem.titleView = [self buttonForTitleView];
    
    //configure carousel
    _carousel.type = iCarouselTypeLinear;
    _carousel.backgroundColor = [UIColor blackColor];
    _carousel.delegate = self;
    _carousel.dataSource = self;
    
    self.scrollView.scrollEnabled = YES;
    CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
    self.scrollView.contentSize = screenFrame.size;
    
    [self.sidePanelController showLeftPanelAnimated:YES];
}



- (void)viewWillAppear:(BOOL)animated{
    //    if (modelController.image == nil) {
    //        UIAlertView *alert = [UIAlertView alloc] initWithTitle: message:<#(NSString *)#> delegate:<#(id)#> cancelButtonTitle:<#(NSString *)#> otherButtonTitles:<#(NSString *), ...#>, nil
    //    }
    
    modelController.subImageViews = [modelController divideImage:modelController.image withBlockSize:modelController.gridSquareSize];
    
    [modelController putSubImageViews:[modelController divideImage:modelController.image withBlockSize:modelController.gridSquareSize] InView:self.scrollView];
    [modelController addGestureRecognizersToSubviewsFromView:self.scrollView andViewController:self];
    
    if (modelController.gridStatus == YES) {
        [modelController putBorderWithWidth:0.8 aroundImageViewsFromView:self.scrollView];
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
    
    UIImageView *subImageView = (UIImageView *)gesture.view;
    [subImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [subImageView.layer setBorderWidth: 4.0];
    
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
    
    if (modelController.selectedSubImageView.image) {
        UIImage *outputImage = [modelController processImage:[modelController.selectedSubImageView.image resizedImageToSize:view.frame.size] withFilterName:[modelController.filterNamesCI objectAtIndex:index]];
        ((UIImageView *)view).image = outputImage;
    }
    
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
        [modelController putBorderWithWidth:0.8 aroundImageViewsFromView:self.scrollView];
    }
    if (modelController.gridStatus == NO) {
        [modelController removeBorderAroundImageViewsFromView:self.scrollView];
    }
    
    
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if (option == iCarouselOptionSpacing)
    {
        return value * 1.04f;
    }
    return value;
}

@end
