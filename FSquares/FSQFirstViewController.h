//
//  FSQFirstViewController.h
//  Squareness
//
//  Created by Stefan Stolevski on 7/12/14.
//  Copyright (c) 2014 Stefan Stolevski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAIntroView.h"
#import "FSQBaseViewController.h"

@interface FSQFirstViewController : FSQBaseViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, EAIntroDelegate>
@property (weak, nonatomic) IBOutlet UIButton *saveImageButton;
@property (weak, nonatomic) IBOutlet UIView *littleSquare;
@property (weak, nonatomic) IBOutlet UIButton *resetImageButton;
- (IBAction)selectPhotoFromAlbum:(UIButton *)sender;
- (IBAction)takePhoto:(id)sender;
- (IBAction)saveImage:(UIButton *)sender;
- (IBAction)displayInfo:(UIButton *)sender;
- (IBAction)resetImage:(UIButton *)sender;
- (IBAction)shareImage:(UIButton *)sender;
@end
