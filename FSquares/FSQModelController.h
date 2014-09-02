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
@property (nonatomic, assign) NSInteger gridSquareSize;

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) UIImageView *selectedSubImageView;

+ (id)sharedInstance;

- (UIImage *)processImage:(UIImage *)myImage withFilterName:(NSString *)filterName;

- (UIImage *)scrollViewSnapshot:(UIScrollView *)scrollView;

- (NSMutableDictionary *)divideImage;
- (void)putSubImageViews:(NSMutableDictionary *)subImageViews InView:(UIView *)view;
- (void)addGestureRecognizersToSubviewsFromView:(UIView *)view andViewController:(UIViewController *)viewController;

- (void)putBorderWithWidth:(float)borderWidth aroundImageViewsFromView:(UIView *)rootView;
- (void)removeBorderAroundImageViewsFromView:(UIView *)rootView;

@end

FSQModelController *modelController;
