//
//  UIView+Divide.m
//  Squareness
//
//  Created by Stefan Stolevski on 3/19/16.
//  Copyright © 2016 Stefan Stolevski. All rights reserved.
//

#import "UIView+Divide.h"

@implementation UIView (Divide)
- (NSMutableDictionary *)addImage:(UIImage *)image
                   withSquareSize:(NSInteger)squareSize
{
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)]; //remove all subviews first!!!
    
    NSMutableDictionary *subImages = [[NSMutableDictionary alloc] init];
    NSInteger partId = 100;
    
    CGFloat squareWidth = squareSize;
    CGFloat squareHeight = squareSize;
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    
    float ratio = self.frame.size.width / imageWidth;
    
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
            [self addSubview:subImageView];
            partId++;
            
            
            CGImageRelease(cgSubImage);
        }
    }
    return subImages;
}

@end
