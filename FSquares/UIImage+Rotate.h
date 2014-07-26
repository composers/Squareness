//
//  UIImage+Rotate.h
//  FSquares
//
//  Created by Stefan Stolevski on 7/26/14.
//  Copyright (c) 2014 Stefan Stolevski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Rotate)
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;
@end
