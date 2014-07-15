//
//  FSQProcessSquareViewController.h
//  FSquares
//
//  Created by Stefan Stolevski on 7/14/14.
//  Copyright (c) 2014 Stefan Stolevski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSQProcessSquareViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

- (IBAction)apply:(id)sender;
- (IBAction)reset:(id)sender;
- (IBAction)done:(id)sender;

@end
