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
}

- (void)viewWillAppear:(BOOL)animated{
    
    NSString *imgPath= [[NSBundle mainBundle] pathForResource:@"squares" ofType:@"jpg"];
    UIImage *backgroundImage = [UIImage imageWithContentsOfFile:imgPath];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[backgroundImage resizedImageToSize:self.view.frame.size]];
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
    modelController.image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [photoPicker dismissViewControllerAnimated:YES completion:nil];
}
@end
