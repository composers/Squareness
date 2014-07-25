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
@property (nonatomic, assign) NSInteger gridSquareSize;

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) UIImageView *selectedSubImageView;
@property (nonatomic, retain) NSMutableDictionary *subImageViews;

+ (id)sharedInstance;
- (UIImage *)processImage:(UIImage *)myImage withFilterName:(NSString *)filterName;
- (UIImage *)snapshot:(UIView *)view;
- (NSMutableDictionary *)divideImage:(UIImage *)image withBlockSize:(int)blockSize;
- (void)putSubImageViews:(NSMutableDictionary *)subImageViews InView:(UIView *)view;

- (void)addGestureRecognizersToSubviewsFromView:(UIView *)view andViewController:(UIViewController *)viewController;
- (UIImageView *)getImageViewWithTag:(NSInteger)tag fromView:(UIView *)rootView;
- (void)putBorderWithWidth:(float)borderWidth aroundImageViewsFromView:(UIView *)rootView;
- (void)removeBorderAroundImageViewsFromView:(UIView *)rootView;
- (void)applyRandomFiltersToView:(UIView *)view;
- (void)applyRandomFiltersToSubImageViews:(NSMutableDictionary *)subImageViews;
- (UIImage *)imageWithColor:(UIColor *)color andFrame:(CGRect)rect;
@end

FSQModelController *modelController;
