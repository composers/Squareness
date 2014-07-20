//
//  CarouselViewController.h
//  FSquares
//
//  Created by Stefan Stolevski on 7/19/14.
//  Copyright (c) 2014 Stefan Stolevski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"

@interface CarouselViewController : UIViewController <iCarouselDataSource, iCarouselDelegate>
@property (weak, nonatomic) IBOutlet iCarousel *carousel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end
