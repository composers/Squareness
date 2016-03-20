//
//  FSQBaseViewController.h
//  Squareness
//
//  Created by Stefan Stolevski on 3/19/16.
//  Copyright © 2016 Stefan Stolevski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSQModelController.h"
@interface FSQBaseViewController : UIViewController

@property (nonatomic, strong) FSQModelController *sharedModel;
- (instancetype)initWithModel:(FSQModelController *)model;
- (void)startLoading;
- (void)stopLoading;
@end
