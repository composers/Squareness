//
//  CarouselViewController.m
//  Squareness
//
//  Created by Stefan Stolevski on 7/19/14.
//  Copyright (c) 2014 Stefan Stolevski. All rights reserved.
//

#import "CarouselViewController.h"
#import "UIImage+Resize.h"
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"
#import "FontAwesomeKit/FAKFontAwesome.h"
#import "DDIndicator.h"
#import "SIAlertView.h"
#import "UIImage+Border.h"
#import "UIView+Divide.h"

@interface CarouselViewController ()

@property(assign, nonatomic) int tapCount;
@property(assign, nonatomic) BOOL shouldNotDisplayDoubleTapAlert;
@property(assign, nonatomic) NSUInteger selectedIndex;

@end

@implementation CarouselViewController

- (void)applyRandomFilters:(id)sender{
    if (self.sharedModel.filterNamesChosen.count > 0)
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
                            subImageView.image = [self.sharedModel processImage:subImageView.image
                                                                 withFilterName:[self.sharedModel.filterNamesChosen objectAtIndex:(arc4random() % self.sharedModel.filterNamesChosen.count)]];
                            [self.sharedModel.subImages setObject:subImageView.image forKey:[NSNumber numberWithInteger:subImageView.tag]];
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

- (UIButton *)buttonForTitleView
{
    
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
    CGFloat scrollViewHeight = screenFrame.size.width * self.sharedModel.image.size.height / self.sharedModel.image.size.width;
    self.scrollView.contentSize = CGSizeMake(screenFrame.size.width, scrollViewHeight);

    self.scrollView.backgroundColor = [UIColor blackColor];
    
    
    [self.sidePanelController showLeftPanelAnimated:YES];
    self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.shouldNotDisplayDoubleTapAlert = [defaults boolForKey:@"shouldNotDisplayDoubleTapAlert"];
    
    CGImageRef newCgIm = CGImageCreateCopy(self.sharedModel.originalImage.CGImage);
    self.sharedModel.image = [UIImage imageWithCGImage:newCgIm
                                                 scale:self.sharedModel.originalImage.scale
                                           orientation:self.sharedModel.originalImage.imageOrientation];
    CGImageRelease(newCgIm);

    [self divideOriginalImage];
    [self divideProcessedImage];
    [self addGestureRecognizersToSubviews];
    
    self.carousel.delegate = self;
    self.carousel.dataSource = self;
    
    self.sharedModel.selectedSubImageView = self.scrollView.subviews[1];
    
    [self.sharedModel.selectedSubImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [self.sharedModel.selectedSubImageView.layer setBorderWidth: WHITE_BORDER_WIDTH];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
         [self.carousel reloadData];
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

- (void)divideOriginalImage
{
    self.sharedModel.originalSubImages = [self.scrollView addImage:self.sharedModel.originalImage
                                                    withSquareSize:self.sharedModel.gridSquareSize];
}

- (void)divideProcessedImage
{
    self.sharedModel.subImages = [self.scrollView addImage:self.sharedModel.image
                                            withSquareSize:self.sharedModel.gridSquareSize];
}

- (void)addGestureRecognizersToSubviews
{
    for (UIView *subveiw in self.scrollView.subviews)
    {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(tap:)];
        tap.numberOfTapsRequired = 1;
        [subveiw addGestureRecognizer:tap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(doubletapAction:)];
        doubleTap.numberOfTapsRequired = 2;
        [subveiw addGestureRecognizer:doubleTap];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                action:@selector(longPressAction:)];
        longPress.numberOfTouchesRequired = 1;
        longPress.minimumPressDuration = 0.5;
        [subveiw addGestureRecognizer:longPress];
    }
}


- (void)putBorderWithWidth:(float)borderWidth
{
    for (UIView *subview in self.scrollView.subviews)
    {
        if ([subview isKindOfClass:[UIImageView class]])
        {
            UIImageView *subImageView = (UIImageView *)subview;
            subImageView.image = [subImageView.image imageWithBorder:borderWidth];
            [self.sharedModel.subImages setObject:subImageView.image
                                           forKey:[NSNumber numberWithInteger:subImageView.tag]];
        }
    }
}

- (void)tap:(UITapGestureRecognizer*)gesture
{
    self.tapCount++;

    [self.sharedModel.selectedSubImageView.layer setBorderWidth:0.0];

    
    self.sharedModel.selectedSubImageView = (UIImageView *)gesture.view;
    
    [self.sharedModel.selectedSubImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [self.sharedModel.selectedSubImageView.layer setBorderWidth: WHITE_BORDER_WIDTH];
    
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
    [self.sharedModel.selectedSubImageView.layer setBorderWidth:0.0];

    UIImageView *touchedSubImageView = (UIImageView *)gesture.view;
    
    UIImage *originalSubImage = [self.sharedModel.originalSubImages objectForKey:[NSNumber numberWithInteger:touchedSubImageView.tag]];
    
    [touchedSubImageView setImage:originalSubImage];
    
    [self.sharedModel.subImages setObject:originalSubImage forKey:[NSNumber numberWithInteger:touchedSubImageView.tag]];
    
    self.sharedModel.selectedSubImageView = touchedSubImageView;
    
    [self.sharedModel.selectedSubImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [self.sharedModel.selectedSubImageView.layer setBorderWidth: WHITE_BORDER_WIDTH];
    
    [self.carousel performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
    
//      dispatch_async(dispatch_get_main_queue(), ^{
//        [self.carousel reloadData];
//    });
}

- (void)longPressAction:(UILongPressGestureRecognizer*)gesture{
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        CGPoint previousPoint = self.sharedModel.selectedSubImageView.frame.origin;
        UIImageView *touchedSubImageView = (UIImageView *)gesture.view;
        CGPoint currentPoint = touchedSubImageView.frame.origin;
        
        if (previousPoint.x == currentPoint.x)
        {
            for (UIImageView *imageView in self.sharedModel.selectedSubImageView.superview.subviews)
            {
                if ([imageView isKindOfClass:[UIImageView class]])
                {
                    if (imageView.frame.origin.x == currentPoint.x)
                    {
                        if((imageView.frame.origin.y >= previousPoint.y && imageView.frame.origin.y <= currentPoint.y) || (imageView.frame.origin.y <= previousPoint.y && imageView.frame.origin.y >= currentPoint.y))
                        {
                            imageView.image = [self.sharedModel processImage:imageView.image withFilterName:self.sharedModel.filterNameSelectedCI];
                            [self.sharedModel.subImages setObject:imageView.image forKey:[NSNumber numberWithInteger:imageView.tag]];
                        }
                    }
                }
            }
        }
        
        if (previousPoint.y == currentPoint.y)
        {
            for (UIImageView *imageView in self.sharedModel.selectedSubImageView.superview.subviews)
            {
                if ([imageView isKindOfClass:[UIImageView class]])
                {
                    if (imageView.frame.origin.y == currentPoint.y)
                    {
                        if((imageView.frame.origin.x >= previousPoint.x && imageView.frame.origin.x <= currentPoint.x) || (imageView.frame.origin.x <= previousPoint.x && imageView.frame.origin.x >= currentPoint.x))
                        {
                            imageView.image = [self.sharedModel processImage:imageView.image withFilterName:self.sharedModel.filterNameSelectedCI];
                            [self.sharedModel.subImages setObject:imageView.image forKey:[NSNumber numberWithInteger:imageView.tag]];
                        }
                    }
                }
            }
        }
    }
    

    [self.sharedModel.selectedSubImageView.layer setBorderWidth:0.0];
    
    self.sharedModel.selectedSubImageView = (UIImageView *)gesture.view;
    
    [self.sharedModel.selectedSubImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [self.sharedModel.selectedSubImageView.layer setBorderWidth: WHITE_BORDER_WIDTH];
    
    [self.carousel performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.carousel reloadData];
//    });
}




#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    //return the total number of items in the carousel
    return self.sharedModel.filterNamesChosen.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
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
    
    if (self.sharedModel.selectedSubImageView.image)
    {
        UIImage *outputImage = [self.sharedModel processImage:[self.sharedModel.selectedSubImageView.image resizedImageToSize:view.frame.size] withFilterName:[self.sharedModel.filterNamesChosen objectAtIndex:index]];
        
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
    
    self.sharedModel.filterNameSelectedCI = [self.sharedModel.filterNamesChosen objectAtIndex:index];

    self.sharedModel.selectedSubImageView.image = [self.sharedModel processImage:self.sharedModel.selectedSubImageView.image withFilterName:self.sharedModel.filterNameSelectedCI];
    [self.sharedModel.subImages setObject:self.sharedModel.selectedSubImageView.image forKey:[NSNumber numberWithInteger:self.sharedModel.selectedSubImageView.tag]];
    
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
