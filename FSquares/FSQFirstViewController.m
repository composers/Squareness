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
#import "FSQImageViewController.h"

@interface FSQFirstViewController ()

@end

@implementation FSQFirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        UITabBarItem * tabBarItem = [[UITabBarItem alloc] initWithTitle: @"new image"
                                                                image: nil //or your icon
                                                                  tag: 0];
        [self setTabBarItem:tabBarItem];
      
      NSString *imgPath= [[NSBundle mainBundle] pathForResource:@"squares" ofType:@"jpg"];
      UIImage *backgroundImage = [UIImage imageWithContentsOfFile:imgPath];
        
      //UIImage *backgroundImage = [[UIImage imageNamed:@"squares.jpg"] resizedImageToSize:self.view.frame.size];
        
      self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)selectPhotoFromAlbum:(UIButton *)sender {
  FSQModelController *modelController = [FSQModelController sharedInstance];
  modelController.image = nil;
  modelController.processedImage = nil;
  
  UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
  photoPicker.delegate = self;
  photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  
  [self presentViewController:photoPicker animated:YES completion:NULL];
}

- (IBAction)takePhotoWithCamera:(UIButton *)sender {
  FSQModelController *modelController = [FSQModelController sharedInstance];
  modelController.image = nil;
  modelController.processedImage = nil;
  
  UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
  
  photoPicker.delegate = self;
  photoPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
  
  [self presentViewController:photoPicker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)photoPicker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
  [photoPicker dismissViewControllerAnimated:YES completion:nil];
  FSQModelController *modelController = [FSQModelController sharedInstance];
  modelController.image = [info valueForKey:UIImagePickerControllerOriginalImage];
  
  
  FSQImageViewController *vc = self.tabBarController.viewControllers[1];
  [modelController divideImage:modelController.image withBlockSize:modelController.gridSquareSize andPutInView:vc.view];
  [modelController addGestureRecognizersToSubviewsFromViewController:vc];
}
@end
