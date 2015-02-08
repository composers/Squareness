//
//  FSQModelController.h
//  Squareness
//
//  Created by Stefan Stolevski on 7/14/14.
//  Copyright (c) 2014 Stefan Stolevski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSQModelController : NSObject
@property (nonatomic, strong) NSArray *filterNamesUI;
@property (nonatomic, strong) NSArray *filterNamesCI;
@property (nonatomic, strong) NSString *filterNameSelectedCI;
@property (nonatomic, strong) NSMutableArray *filterNamesChosen;

@property (nonatomic, assign) BOOL gridStatus;
@property (nonatomic, assign) int gridSquareSize;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *originalImage;

@property (nonatomic, strong) UIImageView *selectedSubImageView;

@property (nonatomic, strong) NSMutableDictionary *originalSubImages;
@property (nonatomic, strong) NSMutableDictionary *subImages;


+ (id)sharedInstance;

- (UIImage *)processImage:(UIImage *)myImage withFilterName:(NSString *)filterName;

- (UIImage *)generateImageFromSubimages:(NSMutableDictionary *)subImages;

- (NSMutableDictionary *)divideImage:(UIImage *)image withSquareSize:(NSInteger)squareSize andPutInView:(UIView *)view;

- (void)addGestureRecognizersToSubviewsFromView:(UIView *)view andViewController:(UIViewController *)viewController;

- (void)putBorderWithWidth:(float)borderWidth aroundImageViewsFromView:(UIView *)rootView;

@end

FSQModelController *modelController;
