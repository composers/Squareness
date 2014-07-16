//
//  FSQModelController.h
//  FSquares
//
//  Created by Stefan Stolevski on 7/14/14.
//  Copyright (c) 2014 Stefan Stolevski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSQModelController : NSObject
@property (nonatomic, retain) NSArray *filterNamesUI;
@property (nonatomic, retain) NSArray *filterNamesCI;
@property (nonatomic, retain) NSString *filterNameSelectedCI;

@property (nonatomic, assign) BOOL gridStatus;
@property (nonatomic, assign) BOOL usePreselectedFilterStatus;
@property (nonatomic, assign) NSInteger gridSquareSize;

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) UIImage *processedImage;
@property (nonatomic, retain) UIImageView *selectedSubImageView;


+ (id)sharedInstance;
- (UIImage *)processImage:(UIImage *)myImage withFilterName:(NSString *)filterName;
//- (UIImage *)imageWithView:(UIView *)view;
- (UIImage *)snapshot:(UIView *)view;
- (void)divideImage:(UIImage *)image withBlockSize:(int)blockSize andPutInView:(UIView *)rootView;
- (void)addGestureRecognizersToSubviewsFromViewController:(UIViewController *)viewController;
- (UIImageView *)getImageViewWithTag:(NSInteger)tag fromView:(UIView *)rootView;
- (void)putBorderWithWidth:(float)borderWidth aroundImageViewsFromView:(UIView *)rootView;
- (void)removeBorderAroundImageViewsFromView:(UIView *)rootView;
- (void)tap:(UITapGestureRecognizer*)gesture;
- (NSMutableArray *)getImagesFromImage:(UIImage *)image withRow:(NSInteger)rows withColumn:(NSInteger)columns;
@end
