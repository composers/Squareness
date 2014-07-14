//
//  FSQImageProcessController.m
//  FSquares
//
//  Created by Stefan Stolevski on 7/12/14.
//  Copyright (c) 2014 Stefan Stolevski. All rights reserved.
//

#import "FSQImageProcessController.h"
#import "UIImage+Resize.h"

@implementation FSQImageProcessController

- (void)divideImage:(UIImage *)image withBlockSize:(int)blockSize useGrid:(BOOL)useGrid andPutInView:(UIView *)rootView{
    
    [[rootView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)]; //remove all subviews first
    
    CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
    UIImage *resizedImage = [image resizedImageToSize:screenFrame.size];
    [rootView setBackgroundColor:[UIColor blackColor]];
    
    int partId = 100;
    for (int x = 0; x < screenFrame.size.width; x += blockSize) {
        for(int y = 0; y < screenFrame.size.height; y += blockSize) {
            
            CGImageRef cgImg = CGImageCreateWithImageInRect(resizedImage.CGImage, CGRectMake(x, y, blockSize, blockSize));
            UIImage *part = [UIImage imageWithCGImage:cgImg];
            UIImageView *iv = [[UIImageView alloc] initWithImage:part];
            
            if (useGrid) {
                [iv.layer setBorderColor: [[UIColor blackColor] CGColor]];
                [iv.layer setBorderWidth: (float)blockSize/80];
            }
            
            UIView *sView = [[UIView alloc] initWithFrame:CGRectMake(x, y, blockSize, blockSize)];
            [sView addSubview:iv];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(tap:)];
            tap.numberOfTapsRequired = 1;
            [sView addGestureRecognizer:tap];
            
            sView.tag = partId;
            
            [rootView addSubview:sView];
            partId++;
            CGImageRelease(cgImg);
        }
    }
}
- (UIImageView *)getImageViewWithTag:(NSInteger)tag fromView:(UIView *)rootView{
    UIView *tempView;
    for (UIView *myView in rootView.subviews) {
        if (myView.tag == tag) {
            tempView = myView;
            break;
        }
    }
    
    UIImageView *imageView = tempView.subviews[0];
    return imageView;
}

//- (void)tap:(UITapGestureRecognizer*)gesture
//{
//    self.touchedId = gesture.view.tag;
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Filter options"
//                                                    message:@"Choose Filter"
//                                                   delegate:self
//                                          cancelButtonTitle:@"Cancel"
//                                          otherButtonTitles:@"Sepia", @"Blur", @"Mono Grey", @"Noir", @"Cool Vintage", @"Tonal", @"Warm Vintage", nil];
//    alert.delegate = self;
//    [alert show];
//}

- (UIImage *)processImage:(UIImage *)myImage withFilterName:(NSString *)filterName{
    
    CIContext *context = [CIContext contextWithOptions:nil];               // 1
    CIImage *image = [CIImage imageWithCGImage:myImage.CGImage];               // 2
    CIFilter *filter = [CIFilter filterWithName:filterName];           // 3
    [filter setValue:image forKey:kCIInputImageKey];
    
    [filter setDefaults];
    //[filter setValue:intensity forKey:kCIInputIntensityKey];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];              // 4
    CGRect extent = [result extent];
    CGImageRef cgImage = [context createCGImage:result fromRect:extent];   // 5
    UIImage *newImage = [UIImage imageWithCGImage:cgImage];
    
    return newImage;
}



@end
