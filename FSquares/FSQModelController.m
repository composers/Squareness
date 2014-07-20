//
//  FSQModelController.m
//  FSquares
//
//  Created by Stefan Stolevski on 7/14/14.
//  Copyright (c) 2014 Stefan Stolevski. All rights reserved.
//

#import "FSQModelController.h"
#import "NSString+ContainsString.h"
#import "GPUImage.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Resize.h"
#import "UIView+Copy.h"

@implementation FSQModelController

+ (id)sharedInstance {
    static FSQModelController *sharedMyInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyInstance = [[self alloc] init];
    });
    return sharedMyInstance;
}

- (id)init {
    if (self = [super init]) {
        
        NSString *filterNamesUIPlistPath = [[NSBundle mainBundle] pathForResource:@"FilterNamesUser" ofType:@"plist"];
        self.filterNamesUI = [NSArray arrayWithContentsOfFile:filterNamesUIPlistPath];
        
        NSString *filterNamesCIPlistPath = [[NSBundle mainBundle] pathForResource:@"FilterNamesCoreImage" ofType:@"plist"];
        self.filterNamesCI = [NSArray arrayWithContentsOfFile:filterNamesCIPlistPath];
        
        self.filterNameSelectedCI = [self.filterNamesCI objectAtIndex:0];
        
        NSString *imgPath= [[NSBundle mainBundle] pathForResource:@"stefce" ofType:@"jpg"];
        self.image = [UIImage imageWithContentsOfFile:imgPath];
        
        self.gridStatus = YES;
        self.usePreselectedFilterStatus = NO;
        self.gridSquareSize = 80;
        
        self.selectedSubImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"squares.jpg"]];
        
    }
    return self;
}

- (UIImage *)processImage:(UIImage *)myImage withFilterName:(NSString *)filterName{
    
    //DO NOT PROCESS ON THE MAIN THREAD: USE THIS
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //        // switch to a background thread and perform your expensive operation
    //
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //            // switch back to the main thread to update your UI
    //
    //        });
    //    });
    NSLog(@"Image processing...");
    
    if ([filterName containsString:@"GPUImage"]) {
        
        id filterGPU;
        
        if ([filterName isEqualToString:@"GPUImageCrosshatchFilter"]) {
            filterGPU = [[GPUImageCrosshatchFilter alloc] init];
        }
        
        if ([filterName isEqualToString:@"GPUImagePixellateFilter"]) {
            filterGPU = [[GPUImagePixellateFilter alloc] init];
        }
        if ([filterName isEqualToString:@"GPUImageSmoothToonFilter"]) {
            filterGPU = [[GPUImageSmoothToonFilter alloc] init];
        }
        
        if ([filterName isEqualToString:@"GPUImageSwirlFilter"]) {
            filterGPU = [[GPUImageSwirlFilter alloc] init];
        }
        
        GPUImagePicture *inputImage = [[GPUImagePicture alloc] initWithImage:myImage];
        [inputImage addTarget:filterGPU];
        [filterGPU useNextFrameForImageCapture];
        [inputImage processImage];
        return [filterGPU imageFromCurrentFramebuffer];
        
        //return [filterGPU imageByFilteringImage:myImage];
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
        return [UIImage imageWithCGImage:cgImage];
    }
}

- (UIImage *)imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 1.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

- (UIImage *)snapshot:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 1.0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}



- (void)divideImage:(UIImage *)image withBlockSize:(int)blockSize andPutInView:(UIView *)view{
    
    [[view subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)]; //remove all subviews first!!!
    
    CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
    UIImage *resizedImage = [image resizedImageToSize:screenFrame.size];
    [view setBackgroundColor:[UIColor blackColor]];
    
    int partId = 100;
    if (blockSize != -1) {
        for (int x = 0; x < screenFrame.size.width; x += blockSize) {
            for(int y = 0; y < screenFrame.size.height; y += blockSize) {
                
                CGImageRef cgSubImage = CGImageCreateWithImageInRect(resizedImage.CGImage, CGRectMake(x, y, blockSize, blockSize));
                UIImage *subImage = [UIImage imageWithCGImage:cgSubImage];
                UIImageView *subImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, blockSize, blockSize)];
                subImageView.userInteractionEnabled = YES;
                [subImageView setImage:subImage];
                subImageView.tag = partId;
                [view addSubview:subImageView];
                partId++;
                CGImageRelease(cgSubImage);
            }
        }
    }
    else{
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:screenFrame];
        imageView.userInteractionEnabled = YES;
        [imageView setImage:resizedImage];
        imageView.tag = partId;
        [view addSubview:imageView];
    }
}

- (void)addGestureRecognizersToSubviewsFromView:(UIView *)view andViewController:(UIViewController *)viewController{
    for (UIView *subveiw in view.subviews) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:viewController
                                                                              action:@selector(tap:)];
        tap.numberOfTapsRequired = 1;
        [subveiw addGestureRecognizer:tap];
    }
}

- (UIImageView *)getImageViewWithTag:(NSInteger)tag fromView:(UIView *)view{
    UIView *tempView;
    for (UIView *subview in view.subviews) {
        if (subview.tag == tag) {
            tempView = subview;
            break;
        }
    }
    UIImageView *subImageView = (UIImageView *)tempView;
    return subImageView;
}

- (void)putBorderWithWidth:(float)borderWidth aroundImageViewsFromView:(UIView *)view{
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[UIImageView class]]){
            UIImageView *subImageView = (UIImageView *)subview;
            [subImageView.layer setBorderColor: [[UIColor blackColor] CGColor]];
            [subImageView.layer setBorderWidth: borderWidth];
        }
    }
}

- (void)removeBorderAroundImageViewsFromView:(UIView *)view{
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[UIImageView class]]){
            UIImageView *subImageView = (UIImageView *)subview;
            [subImageView.layer setBorderWidth:0.0];
        }
        
    }
}

- (void)applyRandomFiltersToView:(UIView *)view{
    //DO NOT PROCESS ON THE MAIN THREAD: USE THIS
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //        // switch to a background thread and perform your expensive operation
    //
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //            // switch back to the main thread to update your UI
    //
    //        });
    //    });
    
    
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[UIImageView class]]){
            UIImageView *subImageView = (UIImageView *)subview;
            subImageView.image = [self processImage:subImageView.image withFilterName:[self.filterNamesCI objectAtIndex:(arc4random() % self.filterNamesCI.count)]];
        }
    }
    //TODO:snapshot
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
    NSLog(@"Dealloc is called. This should never happen for a singleton");
}


@end
