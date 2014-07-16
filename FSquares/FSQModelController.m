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
#import "FSQProcessSquareViewController.h"

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
      
        NSString *imgPath= [[NSBundle mainBundle] pathForResource:@"squares" ofType:@"jpg"];
        self.image = [UIImage imageWithContentsOfFile:imgPath];
        
        self.gridStatus = YES;
        self.usePreselectedFilterStatus = NO;
        self.gridSquareSize = 80;
        
    }
    return self;
}

- (UIImage *)processImage:(UIImage *)myImage withFilterName:(NSString *)filterName{;
    
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

-(NSMutableArray *)getImagesFromImage:(UIImage *)image withRow:(NSInteger)rows withColumn:(NSInteger)columns
{
    NSMutableArray *images = [NSMutableArray array];
    CGSize imageSize = image.size;
    CGFloat xPos = 0.0, yPos = 0.0;
    CGFloat width = imageSize.width/rows;
    CGFloat height = imageSize.height/columns;
    for (int y = 0; y < columns; y++) {
        xPos = 0.0;
        for (int x = 0; x < rows; x++) {
            
            CGRect rect = CGRectMake(xPos, yPos, width, height);
            CGImageRef cImage = CGImageCreateWithImageInRect([image CGImage],  rect);
            
            UIImage *dImage = [[UIImage alloc] initWithCGImage:cImage];
            [images addObject:dImage];
            xPos += width;
        }
        yPos += height;
    }
    return images;
}

- (void)putImages:(NSMutableArray *)images withRow:(NSInteger)rows withColumn:(NSInteger)columns intoView:(UIView *)view{
    
}


- (void)divideImage:(UIImage *)image withBlockSize:(int)blockSize andPutInView:(UIView *)rootView{
  
  [[rootView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)]; //remove all subviews first!!!
  
  CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
  UIImage *resizedImage = [image resizedImageToSize:screenFrame.size];
  [rootView setBackgroundColor:[UIColor blackColor]];
    
  int partId = 100;
    if (blockSize != -1) {
        for (int x = 0; x < screenFrame.size.width; x += blockSize) {
            for(int y = 0; y < screenFrame.size.height; y += blockSize) {
                
                CGImageRef cgSubImage = CGImageCreateWithImageInRect(resizedImage.CGImage, CGRectMake(x, y, blockSize, blockSize));
                UIImage *subImage = [UIImage imageWithCGImage:cgSubImage];
                UIImageView *subImageView = [[UIImageView alloc] initWithImage:subImage];
                
                UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(x, y, blockSize, blockSize)];
                [subView addSubview:subImageView];
                
                subView.tag = partId;
                
                [rootView addSubview:subView];
                partId++;
                CGImageRelease(cgSubImage);
            }
        }
    }
    else{
        UIImageView *imageView = [[UIImageView alloc] initWithImage:resizedImage];
        
        UIView *view = [[UIView alloc] initWithFrame:screenFrame];
        [view addSubview:imageView];
        
        view.tag = partId;
        
        [rootView addSubview:view];
    }
  }

- (void)addGestureRecognizersToSubviewsFromViewController:(UIViewController *)viewController{
  for (UIView *subveiw in viewController.view.subviews) {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:viewController
                                                                          action:@selector(tap:)];
    tap.numberOfTapsRequired = 1;
    [subveiw addGestureRecognizer:tap];
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

- (void)dealloc {
    // Should never be called, but just here for clarity really.
    NSLog(@"Dealloc is called. This should never happen for a singleton");
}


@end
