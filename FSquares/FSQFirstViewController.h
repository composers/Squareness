//
//  FSQFirstViewController.h
//  Squareness
//
//  Created by Stefan Stolevski on 7/12/14.
//  Copyright (c) 2014 Stefan Stolevski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSQFirstViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *saveImageButton;
- (IBAction)selectPhotoFromAlbum:(UIButton *)sender;
- (IBAction)saveImage:(UIButton *)sender;
- (IBAction)displayInfo:(UIButton *)sender;


@end
