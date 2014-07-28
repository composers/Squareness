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
#import "UIImage+Rotate.h"

@interface FSQModelController()
@property (nonatomic, retain) GPUImagePixellateFilter *gpuImagePixellateFilter;
@property (nonatomic, retain) GPUImageSmoothToonFilter *gpuImageSmoothToonFilter;
@property (nonatomic, retain) GPUImageSwirlFilter *gpuImageSwirlFilter;
@property (nonatomic, retain) GPUImageiOSBlurFilter *gpuImageiOSBlurFilter;
@property (nonatomic, retain) GPUImagePolkaDotFilter *gpuImagePolkaDotFilter;
@property (nonatomic, retain) GPUImageMosaicFilter *gpuImageMosaicFilter;


@end

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
      
    self.filterNamesChosen = [NSMutableArray arrayWithContentsOfFile:filterNamesCIPlistPath];
    
    self.gridStatus = YES;
    self.gridSquareSize = 80;
    
    [self initFilters];
    
  }
  return self;
}

- (void)initFilters {
    _gpuImageiOSBlurFilter = [[GPUImageiOSBlurFilter alloc] init];
    _gpuImageMosaicFilter = [[GPUImageMosaicFilter alloc] init];
    _gpuImagePixellateFilter = [[GPUImagePixellateFilter alloc] init];
    _gpuImagePolkaDotFilter = [[GPUImagePolkaDotFilter alloc] init];
    _gpuImageSmoothToonFilter = [[GPUImageSmoothToonFilter alloc] init];
    _gpuImageSwirlFilter = [[GPUImageSwirlFilter alloc] init];
}

- (UIImage *)processImage:(UIImage *)myImage withFilterName:(NSString *)filterName{
    
    if (myImage == nil) {
        NSLog(@"No image loaded");
        return nil;
    }
    
  NSLog(@"Image processing with filter %@", filterName);
  
  if ([filterName containsString:@"GPUImage"]) {
    
    id filterGPU;
    
   
    if ([filterName isEqualToString:@"GPUImagePixellateFilter"]) {
        filterGPU = _gpuImagePixellateFilter;
    }
    if ([filterName isEqualToString:@"GPUImageSmoothToonFilter"]) {
        filterGPU = _gpuImageSmoothToonFilter;
    }
    
    if ([filterName isEqualToString:@"GPUImageSwirlFilter"]) {
        filterGPU = _gpuImageSwirlFilter;
    }
    
    if ([filterName isEqualToString:@"GPUImageiOSBlurFilter"]) {
      filterGPU = _gpuImageiOSBlurFilter;
      GPUImageiOSBlurFilter *blurFilter = (GPUImageiOSBlurFilter *)filterGPU;
      blurFilter.blurRadiusInPixels = 1.0;
    }

    if ([filterName isEqualToString:@"GPUImagePolkaDotFilter"]) {
      filterGPU = _gpuImagePolkaDotFilter;
    }
    
    if ([filterName isEqualToString:@"GPUImageMosaicFilter"]) {
        filterGPU = _gpuImageMosaicFilter;
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

- (UIImage *)snapshot:(UIView *)view
{
  UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 1.0);
  [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return image;
}

- (NSMutableDictionary *)divideImage{
    CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
    if (modelController.image.size.height < modelController.image.size.width) {
        modelController.image = [modelController.image imageRotatedByDegrees:90];
    }
    UIImage *resizedImage = [self.image resizedImageToSize:screenFrame.size];
    NSMutableDictionary *subImageViews = [[NSMutableDictionary alloc] init];
    int partId = 100;
 
        for (int x = 0; x < resizedImage.size.width; x += self.gridSquareSize) {
            for(int y = 0; y < resizedImage.size.height; y += self.gridSquareSize) {
                
                CGImageRef cgSubImage = CGImageCreateWithImageInRect(resizedImage.CGImage, CGRectMake(x, y, self.gridSquareSize, self.gridSquareSize));
                UIImage *subImage = [UIImage imageWithCGImage:cgSubImage];
                UIImageView *subImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, self.gridSquareSize, self.gridSquareSize)];
                subImageView.userInteractionEnabled = YES;
                [subImageView setImage:subImage];
                subImageView.tag = partId;
                [subImageViews setObject:subImageView forKey:[NSNumber numberWithInt:subImageView.tag]];
                partId++;
                CGImageRelease(cgSubImage);
            }
        }
    return subImageViews;
}

- (void)putSubImageViews:(NSMutableDictionary *)subImageViews InView:(UIView *)view{
    [[view subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)]; //remove all subviews first!!!
    NSArray *subImageViewsArray = [subImageViews allValues];
    
    for (UIImageView *subImageView in subImageViewsArray) {
        [view addSubview:subImageView];
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

- (void)dealloc {
  // Should never be called, but just here for clarity really.
  NSLog(@"Dealloc is called. This should never happen for a singleton");
}


@end
