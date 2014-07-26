//
//  FSQFirstViewController.m
//  FSquares
//
//  Created by Stefan Stolevski on 7/12/14.
//  Copyright (c) 2014 Stefan Stolevski. All rights reserved.
//

#import "FSQFirstViewController.h"
#import "UIImage+Resize.h"
#import "FSQModelController.h"
#import "MLPSpotlight.h"


@interface FSQFirstViewController ()

@end

@implementation FSQFirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [MLPSpotlight addSpotlightInView:self.view atPoint:self.view.center];
    
}

- (void)viewWillAppear:(BOOL)animated{
    
//    NSString *imgPath= [[NSBundle mainBundle] pathForResource:@"squares" ofType:@"jpg"];
//    UIImage *backgroundImage = [UIImage imageWithContentsOfFile:imgPath];
//self.view.backgroundColor = [UIColor colorWithPatternImage:[backgroundImage resizedImageToSize:self.view.frame.size]];
    
    [self.view setAlpha:0];
    [UIView animateWithDuration:0.9
                          delay:0.1
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.view setAlpha:1.0];
                     }completion:nil];

    
}

- (void)viewWillDisappear:(BOOL)animated{
  
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)selectPhotoFromAlbum:(UIButton *)sender {
  UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
  photoPicker.delegate = self;
  photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  
  [self presentViewController:photoPicker animated:YES completion:NULL];
}

- (IBAction)takePhotoWithCamera:(UIButton *)sender {
  
  UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
  photoPicker.delegate = self;
  photoPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
  
  [self presentViewController:photoPicker animated:YES completion:NULL];
  
}

- (void)imagePickerController:(UIImagePickerController *)photoPicker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
  CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
  UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
  modelController.image = [image resizedImageToFitInSize:screenFrame.size scaleIfSmaller:YES];
  [photoPicker dismissViewControllerAnimated:YES completion:nil];
}
@end
