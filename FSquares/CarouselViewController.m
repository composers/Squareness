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
@property(assign, nonatomic) NSUInteger selectedIndex;

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
    if (modelController.filterNamesChosen.count > 0)
    {
        DDIndicator *ind = [[DDIndicator alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [self.view addSubview:ind];
        [ind startAnimating];
        self.navigationItem.titleView = ind;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            for (UIView *subview in self.scrollView.subviews)
            {
                if ([subview isKindOfClass:[UIImageView class]])
                {
                    if (arc4random() % 20 < 7)
                    {
                        UIImageView *subImageView = (UIImageView *)subview;
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            subImageView.image = [modelController processImage:subImageView.image withFilterName:[modelController.filterNamesChosen objectAtIndex:(arc4random() % modelController.filterNamesChosen.count)]];
                            [modelController.subImages setObject:subImageView.image forKey:[NSNumber numberWithInteger:subImageView.tag]];
                        });

                    }
                }
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.navigationItem.titleView = [self buttonForTitleView];
            });
        });
    }
    else
    {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"N o  e f f e c t s  s e l e c t e d" andMessage:@"Add some effects into the carousel from the effects palette"];
        
        [alertView addButtonWithTitle:@"O K"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alert) {
                                  [alert dismissAnimated:YES];
                              }];
        
        alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
        alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
        alertView.titleColor = [UIColor darkGrayColor];
        alertView.messageColor = [UIColor darkGrayColor];
        alertView.alpha = 0.85;
        
        [alertView show];

    }
}

- (UIButton *)buttonForTitleView{
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
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
    self.scrollView.backgroundColor = [UIColor blackColor];
    
    
    [self.sidePanelController showLeftPanelAnimated:YES];
    self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.shouldNotDisplayDoubleTapAlert = [defaults boolForKey:@"shouldNotDisplayDoubleTapAlert"];
    
    CGImageRef newCgIm = CGImageCreateCopy(modelController.originalImage.CGImage);
    modelController.image = [UIImage imageWithCGImage:newCgIm scale:modelController.originalImage.scale orientation:modelController.originalImage.imageOrientation];
    CGImageRelease(newCgIm);
    
    UINavigationController *navigationController = (UINavigationController *)self.sidePanelController.centerPanel;
    CarouselViewController *carouselController = [navigationController.viewControllers objectAtIndex:0];
    
    modelController.originalSubImages = [modelController divideImage:modelController.originalImage withSquareSize:modelController.gridSquareSize andPutInView:carouselController.scrollView];
    
    modelController.subImages = [modelController divideImage:modelController.image withSquareSize:modelController.gridSquareSize andPutInView:carouselController.scrollView];
    
    [modelController addGestureRecognizersToSubviewsFromView:carouselController.scrollView andViewController:carouselController];
    
    carouselController.carousel.delegate = carouselController;
    carouselController.carousel.dataSource = carouselController;
    
    modelController.selectedSubImageView = carouselController.scrollView.subviews[1];
    
    [modelController.selectedSubImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [modelController.selectedSubImageView.layer setBorderWidth: WHITE_BORDER_WIDTH];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
         [carouselController.carousel reloadData];
    });
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
    alertView.titleColor = [UIColor darkGrayColor];
    alertView.messageColor = [UIColor darkGrayColor];
    alertView.alpha = 0.85;
    
    [alertView show];
    
}

- (void)tap:(UITapGestureRecognizer*)gesture
{
    self.tapCount++;

    [modelController.selectedSubImageView.layer setBorderWidth:0.0];

    
    modelController.selectedSubImageView = (UIImageView *)gesture.view;
    
    [modelController.selectedSubImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [modelController.selectedSubImageView.layer setBorderWidth: WHITE_BORDER_WIDTH];
    
    if (self.tapCount == 4)
    {
        if (!self.shouldNotDisplayDoubleTapAlert)
        {
            [self displayInfoForDoubleTap];
            
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:YES forKey:@"shouldNotDisplayDoubleTapAlert"];
            [defaults synchronize];
        }
    }
    
    [self.carousel performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.carousel reloadData];
//    });
}

- (void)doubletapAction:(UITapGestureRecognizer*)gesture
{
    [modelController.selectedSubImageView.layer setBorderWidth:0.0];

    UIImageView *touchedSubImageView = (UIImageView *)gesture.view;
    
    UIImage *originalSubImage = [modelController.originalSubImages objectForKey:[NSNumber numberWithInteger:touchedSubImageView.tag]];
    
    [touchedSubImageView setImage:originalSubImage];
    
    [modelController.subImages setObject:originalSubImage forKey:[NSNumber numberWithInteger:touchedSubImageView.tag]];
    
    modelController.selectedSubImageView = touchedSubImageView;
    
    [modelController.selectedSubImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [modelController.selectedSubImageView.layer setBorderWidth: WHITE_BORDER_WIDTH];
    
    [self.carousel performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
    
//      dispatch_async(dispatch_get_main_queue(), ^{
//        [self.carousel reloadData];
//    });
}

- (void)longPressAction:(UILongPressGestureRecognizer*)gesture{
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        CGPoint previousPoint = modelController.selectedSubImageView.frame.origin;
        UIImageView *touchedSubImageView = (UIImageView *)gesture.view;
        CGPoint currentPoint = touchedSubImageView.frame.origin;
        
        if (previousPoint.x == currentPoint.x)
        {
            for (UIImageView *imageView in modelController.selectedSubImageView.superview.subviews)
            {
                if ([imageView isKindOfClass:[UIImageView class]])
                {
                    if (imageView.frame.origin.x == currentPoint.x)
                    {
                        if((imageView.frame.origin.y >= previousPoint.y && imageView.frame.origin.y <= currentPoint.y) || (imageView.frame.origin.y <= previousPoint.y && imageView.frame.origin.y >= currentPoint.y))
                        {
                            imageView.image = [modelController processImage:imageView.image withFilterName:modelController.filterNameSelectedCI];
                            [modelController.subImages setObject:imageView.image forKey:[NSNumber numberWithInteger:imageView.tag]];
                        }
                    }
                }
            }
        }
        
        if (previousPoint.y == currentPoint.y)
        {
            for (UIImageView *imageView in modelController.selectedSubImageView.superview.subviews)
            {
                if ([imageView isKindOfClass:[UIImageView class]])
                {
                    if (imageView.frame.origin.y == currentPoint.y)
                    {
                        if((imageView.frame.origin.x >= previousPoint.x && imageView.frame.origin.x <= currentPoint.x) || (imageView.frame.origin.x <= previousPoint.x && imageView.frame.origin.x >= currentPoint.x))
                        {
                            imageView.image = [modelController processImage:imageView.image withFilterName:modelController.filterNameSelectedCI];
                            [modelController.subImages setObject:imageView.image forKey:[NSNumber numberWithInteger:imageView.tag]];
                        }
                    }
                }
            }
        }
    }
    

    [modelController.selectedSubImageView.layer setBorderWidth:0.0];
    
    modelController.selectedSubImageView = (UIImageView *)gesture.view;
    
    [modelController.selectedSubImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [modelController.selectedSubImageView.layer setBorderWidth: WHITE_BORDER_WIDTH];
    
    [self.carousel performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.carousel reloadData];
//    });
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
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, carousel.frame.size.height - 5, carousel.frame.size.height - 5)];
        view.contentMode = UIViewContentModeCenter;
    }
    
    if (modelController.selectedSubImageView.image)
    {
        UIImage *outputImage = [modelController processImage:[modelController.selectedSubImageView.image resizedImageToSize:view.frame.size] withFilterName:[modelController.filterNamesChosen objectAtIndex:index]];
        
        ((UIImageView *)view).image = outputImage;
        
        if (index == self.selectedIndex)
        {
            [view.layer setBorderColor:[[UIColor whiteColor] CGColor]];
            [view.layer setBorderWidth: WHITE_BORDER_WIDTH];
        }
        else
        {
            [view.layer setBorderWidth:0.0];
        }
    }
    
    return view;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index{
    //NSLog(@"carousel item selected %ld", (long)index);
    
    self.selectedIndex = index;
    
    modelController.filterNameSelectedCI = [modelController.filterNamesChosen objectAtIndex:index];

    modelController.selectedSubImageView.image = [modelController processImage:modelController.selectedSubImageView.image withFilterName:modelController.filterNameSelectedCI];
    [modelController.subImages setObject:modelController.selectedSubImageView.image forKey:[NSNumber numberWithInteger:modelController.selectedSubImageView.tag]];
    
    [self.carousel performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.carousel reloadData];
//    });
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if (option == iCarouselOptionSpacing)
    {
        return value * 1.06f;
    }
    return value;
}

@end
