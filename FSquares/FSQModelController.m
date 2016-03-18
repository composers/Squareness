//
//  FSQModelController.m
//  Squareness
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

@property (nonatomic, retain) GPUImageSmoothToonFilter *gpuImageSmoothToonFilter;
@property (nonatomic, retain) GPUImageSwirlFilter *gpuImageSwirlFilter;
@property (nonatomic, retain) GPUImageMonochromeFilter *gpuImageMonochromeFilter;

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
    if (self = [super init])
    {
        
        NSString *filterNamesUIPlistPath = [[NSBundle mainBundle] pathForResource:@"FilterNamesUser" ofType:@"plist"];
        self.filterNamesUI = [NSArray arrayWithContentsOfFile:filterNamesUIPlistPath];
        
        NSString *filterNamesCIPlistPath = [[NSBundle mainBundle] pathForResource:@"FilterNamesCoreImage" ofType:@"plist"];
        
        self.filterNamesCI = [NSArray arrayWithContentsOfFile:filterNamesCIPlistPath];
        
        self.filterNameSelectedCI = [self.filterNamesCI objectAtIndex:0];
        
        self.filterNamesChosen = [NSMutableArray arrayWithContentsOfFile:filterNamesCIPlistPath];
        
        [self.filterNamesChosen removeObject:@"AddBorderFilter"];
        [self.filterNamesChosen removeObject:@"GPUImageSwirlFilter"];
        
        self.gridSquareSize = 160;
        
        [self initFilters];
        
        UIImage *image = [UIImage imageNamed:@"artwork-source.png"];
        
        CGSize newSize = CGSizeMake(640.0, 640.0);
        
        image = [image resizedImageToSize:newSize];
        
        _originalImage = image;
        
        CGImageRef newCgIm = CGImageCreateCopy(image.CGImage);
        _image = [UIImage imageWithCGImage:newCgIm scale:image.scale orientation:image.imageOrientation];
        CGImageRelease(newCgIm);
    }
    return self;
}

- (void)initFilters {
    
    _gpuImageSmoothToonFilter = [[GPUImageSmoothToonFilter alloc] init];
    _gpuImageSmoothToonFilter.threshold = 0.4;
    
    _gpuImageSwirlFilter = [[GPUImageSwirlFilter alloc] init];
    _gpuImageMonochromeFilter = [[GPUImageMonochromeFilter alloc] init];
}

- (UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (UIImage *)processImage:(UIImage *)myImage withFilterName:(NSString *)filterName{
    
    if (myImage == nil) {
        //NSLog(@"No image loaded");
        return nil;
    }
    
    //NSLog(@"Image processing with filter %@", filterName);
    if ([filterName isEqualToString:@"AddBorderFilter"])
    {
        return [self imageWithBorderWidth:BLACK_BORDER_WIDTH * 2 FromImage:myImage];
    }
    
    if ([filterName containsString:@"GPUImage"]) {
        
        id filterGPU;
        
        
        if ([filterName isEqualToString:@"GPUImageSmoothToonFilter"]) {
            filterGPU = _gpuImageSmoothToonFilter;
        }
        
        if ([filterName isEqualToString:@"GPUImageSwirlFilter"]) {
            filterGPU = _gpuImageSwirlFilter;
        }
        
        
        if ([filterName isEqualToString:@"GPUImageRedFilter"]) {
            [_gpuImageMonochromeFilter setColorRed:1.0 green:0.68 blue:0.68];
            filterGPU = _gpuImageMonochromeFilter;
        }
        
        if ([filterName isEqualToString:@"GPUImageGreenFilter"]) {
            [_gpuImageMonochromeFilter setColorRed:0.68 green:1.0 blue:0.68];
            //[_gpuImageMonochromeFilter setColorRed:170.0/255.0 green:212.0/255.0 blue:80.0/255.0];
            filterGPU = _gpuImageMonochromeFilter;
        }
        
        if ([filterName isEqualToString:@"GPUImageBlueFilter"]) {
            [_gpuImageMonochromeFilter setColorRed:0.68 green:0.68 blue:1.0];
            filterGPU = _gpuImageMonochromeFilter;
        }
        
        if ([filterName isEqualToString:@"GPUImageOrangeFilter"]) {
            [_gpuImageMonochromeFilter setColorRed:255.0/255.0 green:153.0/255.0 blue:18.0/255.0];
            
            filterGPU = _gpuImageMonochromeFilter;
        }
        
        
        //            GPUImagePicture *inputImage = [[GPUImagePicture alloc] initWithImage:myImage];
        //            [inputImage addTarget:filterGPU];
        //            [filterGPU useNextFrameForImageCapture];
        //            [inputImage processImage];
        //            return [filterGPU imageFromCurrentFramebuffer];
        
        return [filterGPU imageByFilteringImage:myImage];
    }
    else
    {
        
        CIContext *context = [CIContext contextWithOptions:nil];               // 1
        CIImage *image = [CIImage imageWithCGImage:myImage.CGImage];               // 2
        CIFilter *filter = [CIFilter filterWithName:filterName];           // 3
        [filter setValue:image forKey:kCIInputImageKey];
        
        [filter setDefaults];
        
        CIImage *result = [filter valueForKey:kCIOutputImageKey];              // 4
        CGRect extent = [result extent];
        CGImageRef cgImage = [context createCGImage:result fromRect:extent];   // 5
        
        UIImage *outImage =  [UIImage imageWithCGImage:cgImage];
        
        CGImageRelease(cgImage);
        
        return outImage;
    }
}

- (UIImage *)generateImageFromSubimages:(NSMutableDictionary *)subImages
{
    CGFloat squareWidth = modelController.gridSquareSize;
    CGFloat squareHeight = modelController.gridSquareSize;
    CGFloat imageWidth = modelController.image.size.width;
    CGFloat imageHeight = modelController.image.size.height;
    
    int partId = 100;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(modelController.image.size.width, modelController.image.size.height), NO, 1);
    
    for (CGFloat x = 0; x < imageWidth; x += squareWidth)
    {
        for(CGFloat y = 0; y < imageHeight; y += squareHeight)
        {
            if (x + squareWidth > imageWidth)
            {
                squareWidth = imageWidth - x;
            }
            else
            {
                squareWidth = modelController.gridSquareSize;
            }
            
            if (y + squareHeight > imageHeight)
            {
                squareHeight = imageHeight - y;
            }
            else
            {
                squareHeight = modelController.gridSquareSize;
            }
            
            
            [[subImages objectForKey:[NSNumber numberWithInteger:partId]] drawAtPoint:CGPointMake(x, y)];
            partId++;
        }
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return image;
    
}

- (NSMutableDictionary *)divideImage:(UIImage *)image withSquareSize:(NSInteger)squareSize andPutInView:(UIView *)view
{
    [[view subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)]; //remove all subviews first!!!
    
    NSMutableDictionary *subImages = [[NSMutableDictionary alloc] init];
    NSInteger partId = 100;
    
    CGFloat squareWidth = squareSize;
    CGFloat squareHeight = squareSize;
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    
    float ratio = view.frame.size.width / imageWidth;
    
    for (CGFloat x = 0; x < imageWidth; x += squareWidth)
    {
        for(CGFloat y = 0; y < imageHeight; y += squareHeight)
        {
            if (x + squareWidth > imageWidth)
            {
                squareWidth = imageWidth - x;
            }
            else
            {
                squareWidth = squareSize;
            }
            
            if (y + squareHeight > imageHeight)
            {
                squareHeight = imageHeight - y;
            }
            else
            {
                squareHeight = squareSize;
            }
            
            CGImageRef cgSubImage = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(x, y, squareWidth, squareHeight));
            
            UIImage *subImage = [UIImage imageWithCGImage:cgSubImage];
            
            [subImages setObject:subImage forKey:[NSNumber numberWithInteger:partId]];
            
            UIImageView *subImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x * ratio, y * ratio, squareWidth * ratio, squareHeight * ratio)];
            subImageView.userInteractionEnabled = YES;
            [subImageView setImage:subImage];
            subImageView.tag = partId;
            [view addSubview:subImageView];
            partId++;
            
            
            CGImageRelease(cgSubImage);
        }
    }
    return subImages;
}

- (void)addGestureRecognizersToSubviewsFromView:(UIView *)view andViewController:(UIViewController *)viewController{
    for (UIView *subveiw in view.subviews)
    {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:viewController
                                                                              action:@selector(tap:)];
        tap.numberOfTapsRequired = 1;
        [subveiw addGestureRecognizer:tap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:viewController
                                                                                    action:@selector(doubletapAction:)];
        doubleTap.numberOfTapsRequired = 2;
        [subveiw addGestureRecognizer:doubleTap];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:viewController action:@selector(longPressAction:)];
        longPress.numberOfTouchesRequired = 1;
        longPress.minimumPressDuration = 0.5;
        [subveiw addGestureRecognizer:longPress];
    }
}

- (UIImage*)imageWithBorderWidth:(float)borderWidth FromImage:(UIImage*)source;
{
    CGSize size = [source size];
    UIGraphicsBeginImageContext(size);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    [source drawInRect:rect blendMode:kCGBlendModeNormal alpha:1.0];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
    CGContextSetLineWidth(context, borderWidth);
    CGContextStrokeRect(context, rect);
    UIImage *testImg =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return testImg;
}

- (void)putBorderWithWidth:(float)borderWidth aroundImageViewsFromView:(UIView *)view{
    for (UIView *subview in view.subviews)
    {
        if ([subview isKindOfClass:[UIImageView class]])
        {
            UIImageView *subImageView = (UIImageView *)subview;
            
            subImageView.image = [self imageWithBorderWidth:borderWidth FromImage:subImageView.image];
            
            [modelController.subImages setObject:subImageView.image forKey:[NSNumber numberWithInteger:subImageView.tag]];
        }
    }
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
    NSLog(@"Dealloc is called. This should never happen for a singleton");
}


@end
