//
//  FSQModelController.h
//  Squareness
//
//  Created by Stefan Stolevski on 7/14/14.
//  Copyright (c) 2014 Stefan Stolevski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSQModelController : NSObject
@property (nonatomic, retain) NSArray *filterNamesUI;
@property (nonatomic, retain) NSArray *filterNamesCI;
@property (nonatomic, retain) NSString *filterNameSelectedCI;
@property (nonatomic, retain) NSMutableArray *filterNamesChosen;

@property (nonatomic, assign) BOOL gridStatus;
@property (nonatomic, assign) int gridSquareSize;

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) UIImage *originalImage;

@property (nonatomic, retain) UIImageView *selectedSubImageView;

@property (nonatomic, retain) NSMutableDictionary *originalSubImages;
@property (nonatomic, retain) NSMutableDictionary *subImages;


+ (id)sharedInstance;

- (UIImage *)processImage:(UIImage *)myImage withFilterName:(NSString *)filterName;

- (UIImage *)generateImageFromSubimages:(NSMutableDictionary *)subImages;

- (NSMutableDictionary *)divideImage:(UIImage *)image withSquareSize:(NSInteger)squareSize andPutInView:(UIView *)view;

- (void)addGestureRecognizersToSubviewsFromView:(UIView *)view andViewController:(UIViewController *)viewController;

- (void)putBorderWithWidth:(float)borderWidth aroundImageViewsFromView:(UIView *)rootView;
- (void)removeBorderAroundImageViewsFromView:(UIView *)rootView;

@end

FSQModelController *modelController;
