//
//  CarouselViewController.m
//  Squareness
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
#import "DDIndicator.h"
#import "SIAlertView.h"

@interface CarouselViewController ()

@property(assign, nonatomic) int tapCount;
@property(assign, nonatomic) BOOL shouldNotDisplayDoubleTapAlert;

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
    if (modelController.image && (modelController.filterNamesChosen.count > 0)) {
    DDIndicator *ind = [[DDIndicator alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [self.view addSubview:ind];
    [ind startAnimating];
    self.navigationItem.titleView = ind;
    [self performSelectorInBackground:@selector(applyRandomFiltersBackground) withObject:nil];
    }
}

- (void)applyRandomFiltersBackground{
    for (UIView *subview in self.scrollView.subviews) {
        UIImageView *subImageView = (UIImageView *)subview;
        
        if (arc4random() % 2 == 1) { //skip some sub images - we don't need to process every sub image
            subImageView.image = [modelController processImage:subImageView.image withFilterName:[modelController.filterNamesChosen objectAtIndex:(arc4random() % modelController.filterNamesChosen.count)]];
        }
    }
        
    self.navigationItem.titleView = [self buttonForTitleView];
}

- (UIButton *)buttonForTitleView{
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectZero];
    [button addTarget:self action:@selector(applyRandomFilters:) forControlEvents:UIControlEventTouchUpInside];
    //[button setImage:[[FAKFontAwesome thIconWithSize:30] imageWithSize:CGSizeMake(30.f, 30.f)] forState:UIControlStateNormal];
     [button setImage:[UIImage imageNamed:@"random_icon.ico"] forState:UIControlStateNormal];
    
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
    _carousel.centerItemWhenSelected = YES;

    
    self.scrollView.scrollEnabled = YES;
    CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
    self.scrollView.contentSize = screenFrame.size;
    
    [self.sidePanelController showLeftPanelAnimated:YES];
     self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.shouldNotDisplayDoubleTapAlert = [defaults boolForKey:@"shouldNotDisplayDoubleTapAlert"];
    
    
    
    CGImageRef newCgIm = CGImageCreateCopy(modelController.originalImage.CGImage);
    modelController.image = [UIImage imageWithCGImage:newCgIm scale:modelController.originalImage.scale orientation:modelController.originalImage.imageOrientation];
    
    
    UINavigationController *navigationController = (UINavigationController *)self.sidePanelController.centerPanel;
    CarouselViewController *carouselController = [navigationController.viewControllers objectAtIndex:0];
    
    modelController.originalSubImageViews = [modelController divideOriginalImage];
    [modelController putSubImageViews:[modelController divideImage] InView:carouselController.scrollView];
    [modelController addGestureRecognizersToSubviewsFromView:carouselController.scrollView andViewController:carouselController];
    
    if (modelController.gridStatus == YES) {
        [modelController putBorderWithWidth:0.8 aroundImageViewsFromView:carouselController.scrollView];
    }
    if (modelController.gridStatus == NO) {
        [modelController removeBorderAroundImageViewsFromView:carouselController.scrollView];
    }
    
    
    carouselController.carousel.delegate = carouselController;
    carouselController.carousel.dataSource = carouselController;
    
    modelController.selectedSubImageView = carouselController.scrollView.subviews[1];
    
    [modelController.selectedSubImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [modelController.selectedSubImageView.layer setBorderWidth: 2.0];
    
    [carouselController.carousel reloadData];

}

- (IBAction)displayInfoForDoubleTap{
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"T i p" andMessage:@"If you need to undo the applied effects for a particular square, just double tap on the square"];
    
    [alertView addButtonWithTitle:@"O K"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              [alert dismissAnimated:YES];
                          }];
    
    alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
    alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
    alertView.titleColor = [UIColor grayColor];
    alertView.messageColor = [UIColor grayColor];
    
    
    [alertView show];
    
}

- (void)tap:(UITapGestureRecognizer*)gesture
{
    self.tapCount++;
    if (modelController.gridStatus == YES) {
        [modelController.selectedSubImageView.layer setBorderColor: [[UIColor blackColor] CGColor]];
        [modelController.selectedSubImageView.layer setBorderWidth:0.8];
    }
    else{
        [modelController.selectedSubImageView.layer setBorderWidth:0.0];
    }

    modelController.selectedSubImageView = (UIImageView *)gesture.view;
    
    [modelController.selectedSubImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [modelController.selectedSubImageView.layer setBorderWidth: 2.0];
    
    if (self.tapCount == 4) {
        if (!self.shouldNotDisplayDoubleTapAlert) {
            [self displayInfoForDoubleTap];
            
  
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:YES forKey:@"shouldNotDisplayDoubleTapAlert"];
            [defaults synchronize];
        }
    }
    [self.carousel performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
}

- (void)doubletapAction:(UITapGestureRecognizer*)gesture
{
    if (modelController.gridStatus == YES) {
        [modelController.selectedSubImageView.layer setBorderColor: [[UIColor blackColor] CGColor]];
        [modelController.selectedSubImageView.layer setBorderWidth:0.8];
    }
    else{
        [modelController.selectedSubImageView.layer setBorderWidth:0.0];
    }
    
    UIImageView *touchedSubImageView = (UIImageView *)gesture.view;
    
        UIImageView *originalSubImageView = (UIImageView *)[modelController.originalSubImageViews objectForKey:[NSNumber numberWithInt:touchedSubImageView.tag]];
    
        [touchedSubImageView setImage:originalSubImageView.image];
    
    
    modelController.selectedSubImageView = touchedSubImageView;
    
    
    [modelController.selectedSubImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [modelController.selectedSubImageView.layer setBorderWidth: 2.0];
    
    [self.carousel performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
}


#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    //return the total number of items in the carousel
    return modelController.filterNamesChosen.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    //NSLog(@"filter index %lu", (unsigned long)index);
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
        UIImage *outputImage = [modelController processImage:[modelController.selectedSubImageView.image resizedImageToSize:view.frame.size] withFilterName:[modelController.filterNamesChosen objectAtIndex:index]];
        ((UIImageView *)view).image = outputImage;
    }
    
    return view;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index{
    //NSLog(@"carousel item selected %ld", (long)index);
    
    modelController.filterNameSelectedCI = [modelController.filterNamesChosen objectAtIndex:index];
    modelController.selectedSubImageView.image = [modelController processImage:modelController.selectedSubImageView.image withFilterName:modelController.filterNameSelectedCI];
    [carousel reloadData];
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if (option == iCarouselOptionSpacing)
    {
        return value * 1.05f;
    }
    return value;
}

@end
