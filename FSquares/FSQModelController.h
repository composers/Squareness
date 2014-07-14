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
@property (nonatomic, retain) NSString *filterNameSelectedUI;
@property (nonatomic, retain) NSString *filterNameSelectedCI;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, assign) BOOL gridStatus;
@property (nonatomic, assign) BOOL usePreselectedFilterStatus;
@property (nonatomic, assign) NSInteger gridSquareSize;

+ (id)sharedInstance;
@end
