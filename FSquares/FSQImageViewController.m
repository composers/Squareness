//
//  FSQImageViewController.m
//  FSquares
//
//  Created by Stefan Stolevski on 7/12/14.
//  Copyright (c) 2014 Stefan Stolevski. All rights reserved.
//

#import "FSQImageViewController.h"
#import "FSQOptionsViewController.h"
#import "UIImage+Resize.h"
#import <QuartzCore/QuartzCore.h>
#import "GPUImage.h"
#import "NSString+ContainsString.h"

@interface FSQImageViewController ()
@property (nonatomic, retain) NSString *filterName;
@property (nonatomic, assign) NSInteger touchedId;
@property (nonatomic, retain) UIImage *mainImage;
@end

@implementation FSQImageViewController
@synthesize filterName;
@synthesize touchedId;
@synthesize mainImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UITabBarItem * tabBarItem = [[UITabBarItem alloc] initWithTitle: @"process image"
                                                                  image: nil //or your icon
                                                                    tag: 0];
        [self setTabBarItem:tabBarItem];
        
        self.mainImage = [UIImage imageNamed:@"stefce.jpg"];
        
        NSString *filterNamesPlistPath = [[NSBundle mainBundle] pathForResource:@"FilterNamesCoreImage" ofType:@"plist"];
        NSArray *filterNamesCoreImage = [NSArray arrayWithContentsOfFile:filterNamesPlistPath];
        
        self.filterName = [NSString stringWithString:[filterNamesCoreImage objectAtIndex:0]];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    scrollView.scrollEnabled = YES;
    scrollView.showsVerticalScrollIndicator = YES;
    CGFloat additionalHeight = self.tabBarController.tabBar.frame.size.height;
    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height + additionalHeight);
    self.view = scrollView;
    
    [self divideImage:self.mainImage withBlockSize:80 andPutInView:self.view];


   }

- (void)viewWillAppear:(BOOL)animated{
    
    NSInteger gridStatus = 0; //ON
    
    for (UIViewController *viewController in self.tabBarController.viewControllers)
    {
        if ([viewController isKindOfClass:[FSQOptionsViewController class]])
        {
            FSQOptionsViewController *vc = (FSQOptionsViewController *)viewController;
            gridStatus = vc.gridStatus.selectedSegmentIndex;
        }
    }
    
    if (gridStatus == 0) {
        [self putBorderWithWidth:80/80 aroundImageViewsFromView:self.view];
    }
    if (gridStatus == 1) {
        [self removeBorderAroundImageViewsFromView:self.view];
    }

}

- (void)divideImage:(UIImage *)image withBlockSize:(int)blockSize andPutInView:(UIView *)rootView{
    
    [[rootView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)]; //remove all subviews first
    
    CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
    UIImage *resizedImage = [image resizedImageToSize:screenFrame.size];
    [rootView setBackgroundColor:[UIColor blackColor]];
    
    int partId = 100;
    for (int x = 0; x < screenFrame.size.width; x += blockSize) {
        for(int y = 0; y < screenFrame.size.height; y += blockSize) {
            
            CGImageRef cgImgage = CGImageCreateWithImageInRect(resizedImage.CGImage, CGRectMake(x, y, blockSize, blockSize));
            UIImage *part = [UIImage imageWithCGImage:cgImgage];
            UIImageView *iv = [[UIImageView alloc] initWithImage:part];
            
            UIView *sView = [[UIView alloc] initWithFrame:CGRectMake(x, y, blockSize, blockSize)];
            [sView addSubview:iv];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(tap:)];
            tap.numberOfTapsRequired = 1;
            [sView addGestureRecognizer:tap];
            
            sView.tag = partId;
            
            [rootView addSubview:sView];
            partId++;
            CGImageRelease(cgImgage);
        }
    }
}

- (void)divideView:(UIView *)rootView withBlockSize:(int)blockSize{
    for (int x = 0; x < rootView.frame.size.width; x += blockSize) {
        for(int y = 0; y < rootView.frame.size.height; y += blockSize) {
            UIView *blockView = [[UIView alloc] initWithFrame:CGRectMake(x, y, blockSize, blockSize)];
            [rootView addSubview:blockView];
        }
    }
    
}


- (UIImageView *)getImageViewWithTag:(NSInteger)tag fromView:(UIView *)rootView{
    UIView *tempView;
    for (UIView *view in rootView.subviews) {
        if (view.tag == tag) {
            tempView = view;
            break;
        }
    }
    
    UIImageView *imageView = tempView.subviews[0];
    return imageView;
}

- (void)putBorderWithWidth:(float)borderWidth aroundImageViewsFromView:(UIView *)rootView{
    NSLog(@"SUBVIEWS COUNT = %d", rootView.subviews.count);
    for (UIView *view in rootView.subviews) {
        if (view.subviews.count > 0) {
            if ([view.subviews[0] isKindOfClass:[UIImageView class]]){
                UIImageView *imageView = view.subviews[0];
                [imageView.layer setBorderColor: [[UIColor blackColor] CGColor]];
                [imageView.layer setBorderWidth: borderWidth];
            }
        }
    }
}

- (void)removeBorderAroundImageViewsFromView:(UIView *)rootView{
    for (UIView *view in rootView.subviews) {
        if (view.subviews.count > 0) {
            if ([view.subviews[0] isKindOfClass:[UIImageView class]]){
                UIImageView *imageView = view.subviews[0];
                [imageView.layer setBorderWidth:0.0];
            }
        }
    }
}

- (void)tap:(UITapGestureRecognizer*)gesture
{
    self.touchedId = gesture.view.tag;
    
    NSInteger usePredefinedFilterStatus = 0;
    FSQOptionsViewController *vc;
    
    for (UIViewController *viewController in self.tabBarController.viewControllers)
    {
        if ([viewController isKindOfClass:[FSQOptionsViewController class]])
        {
            vc = (FSQOptionsViewController *)viewController;
            usePredefinedFilterStatus = vc.usePredefinedFilterStatus.selectedSegmentIndex;
        }
    }
    
    if (usePredefinedFilterStatus == 1) {
        
        if (vc.filterNameCoreImageSelected) {
            self.filterName = vc.filterNameCoreImageSelected;
        }
        
        UIImageView *imageView = [self getImageViewWithTag:self.touchedId fromView:self.view];
        UIImage *image = [self processImage:imageView.image withFilterName:self.filterName];
        [imageView setImage:image];
    }
    
    if (usePredefinedFilterStatus == 0) {
        
        NSString *filterNamesPlistPath = [[NSBundle mainBundle] pathForResource:@"FilterNamesUser" ofType:@"plist"];
        NSArray *filterNamesUser = [NSArray arrayWithContentsOfFile:filterNamesPlistPath];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Filter options"
                                                        message:@"Choose Filter"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:nil];
        
        for (NSString *title in filterNamesUser) {
            [alert addButtonWithTitle:title];
        }
        
        [alert show];
    }

    }


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) { //Cancel
        return;
    }
    
    NSString *filterNamesPlistPath = [[NSBundle mainBundle] pathForResource:@"FilterNamesCoreImage" ofType:@"plist"];
    NSArray *filterNamesCoreImage = [NSArray arrayWithContentsOfFile:filterNamesPlistPath];
    
    self.filterName = [NSString stringWithString:[filterNamesCoreImage objectAtIndex:(buttonIndex-1)]];
    
    UIImageView *imageView = [self getImageViewWithTag:self.touchedId fromView:self.view];
    UIImage *image = [self processImage:imageView.image withFilterName:self.filterName];
    
    [imageView setImage:image];
}


- (UIImage *)processImage:(UIImage *)myImage withFilterName:(NSString *)filterName{;
    
    UIImage *outputImage;
    
    if ([filterName containsString:@"GPUImage"]) {
        
        id filterGPU;
        
        if ([filterName isEqualToString:@"GPUImageCrosshatchFilter"]) {
            filterGPU = [[GPUImageCrosshatchFilter alloc] init];
        }
        
        
        
        GPUImagePicture *inputImage = [[GPUImagePicture alloc] initWithImage:myImage];
        
        [inputImage addTarget:filterGPU];
        [filterGPU useNextFrameForImageCapture];
        [inputImage processImage];
        
        outputImage = [filterGPU imageFromCurrentFramebuffer];
        return outputImage;
    }
    else{
    
    CIContext *context = [CIContext contextWithOptions:nil];               // 1
    CIImage *image = [CIImage imageWithCGImage:myImage.CGImage];               // 2
    CIFilter *filter = [CIFilter filterWithName:filterName];           // 3
    [filter setValue:image forKey:kCIInputImageKey];
    
    [filter setDefaults];
    
    CIImage *result = [filter valueForKey:kCIOutputImageKey];              // 4
    CGRect extent = [result extent];
    CGImageRef cgImage = [context createCGImage:result fromRect:extent];   // 5
    outputImage = [UIImage imageWithCGImage:cgImage];
    
    return outputImage;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
