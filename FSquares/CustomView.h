//
//  CustomView.h
//  Squareness
//
//  Created by Stefan Stolevski on 10/21/14.
//  Copyright (c) 2014 Stefan Stolevski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
+ (id)customView;
@end
