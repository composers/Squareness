//
//  FSQFirstViewController.h
//  FSquares
//
//  Created by Stefan Stolevski on 7/12/14.
//  Copyright (c) 2014 Stefan Stolevski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSQFirstViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
- (IBAction)selectPhotoFromAlbum:(UIButton *)sender;
- (IBAction)takePhotoWithCamera:(UIButton *)sender;
- (IBAction)saveImage:(UIButton *)sender;

@end
