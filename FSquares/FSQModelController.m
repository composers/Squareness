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
#import "UIImage+Border.h"

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
        
        self.gridSquareSize = LARGEST_SQUARE_SIZE / 2;
        
        [self initFilters];
        
        UIImage *image = [UIImage imageNamed:@"default_image.JPG"];
        
        CGSize newSize = CGSizeMake(LARGEST_SQUARE_SIZE * 2, LARGEST_SQUARE_SIZE * 2);
        
        image = [image resizedImageToSize:newSize];
        
        _originalImage = image;
        
        CGImageRef newCgIm = CGImageCreateCopy(image.CGImage);
        _image = [UIImage imageWithCGImage:newCgIm
                                     scale:image.scale
                               orientation:image.imageOrientation];
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

- (UIImage *)processImage:(UIImage *)myImage
           withFilterName:(NSString *)filterName{
    
    if (myImage == nil) {
        //NSLog(@"No image loaded");
        return nil;
    }
    
    //NSLog(@"Image processing with filter %@", filterName);
    if ([filterName isEqualToString:@"AddBorderFilter"])
    {
        return [myImage imageWithBorder:BLACK_BORDER_WIDTH];
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

- (void)generateImageFromSubimages
{
    CGFloat squareWidth = self.gridSquareSize;
    CGFloat squareHeight = self.gridSquareSize;
    CGFloat imageWidth = self.image.size.width;
    CGFloat imageHeight = self.image.size.height;
    
    int partId = 100;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.image.size.width, self.image.size.height), NO, 1);
    
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
                squareWidth = self.gridSquareSize;
            }
            
            if (y + squareHeight > imageHeight)
            {
                squareHeight = imageHeight - y;
            }
            else
            {
                squareHeight = self.gridSquareSize;
            }
            
            
            [[self.subImages objectForKey:[NSNumber numberWithInteger:partId]] drawAtPoint:CGPointMake(x, y)];
            partId++;
        }
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    self.image = image;
}


- (void)dealloc {
    // Should never be called, but just here for clarity really.
    NSLog(@"Dealloc is called. This should never happen for a singleton");
}


@end
