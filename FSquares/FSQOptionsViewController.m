//
//  FSQOptionsViewController.m
//  Squareness
//
//  Created by Stefan Stolevski on 7/12/14.
//  Copyright (c) 2014 Stefan Stolevski. All rights reserved.
//

#import "FSQOptionsViewController.h"
#import "FSQModelController.h"
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"
#import "CarouselViewController.h"
#import "TNCheckBoxGroup.h"


@interface FSQOptionsViewController ()

@end

@implementation FSQOptionsViewController

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
    [self createChooseFiltersCheckbox];
}



- (void)createChooseFiltersCheckbox{
    
    NSMutableArray *filtersData = [[NSMutableArray alloc] initWithCapacity:modelController.filterNamesUI.count];
    
    for (int i = 0; i < modelController.filterNamesUI.count; i++)
    {
        TNRectangularCheckBoxData *checkboxData = [[TNRectangularCheckBoxData alloc] init];
        checkboxData.identifier = [modelController.filterNamesCI objectAtIndex:i];
        checkboxData.labelText = [modelController.filterNamesUI objectAtIndex:i];
        checkboxData.labelColor = [UIColor darkGrayColor];
        checkboxData.borderColor = [UIColor darkGrayColor];
        checkboxData.rectangleColor = [UIColor darkGrayColor];
        checkboxData.borderWidth = checkboxData.borderHeight = 20;
        checkboxData.rectangleWidth = checkboxData.rectangleHeight = 15;
        checkboxData.checked = YES;
        [filtersData addObject:checkboxData];
    }


    TNCheckBoxGroup *chooseFiltersCheckbox = [[TNCheckBoxGroup alloc] initWithCheckBoxData:filtersData style:TNCheckBoxLayoutVertical];
    [chooseFiltersCheckbox create];
    chooseFiltersCheckbox.position = CGPointMake(20, 20);
    [self.chooseFiltersCheckboxContainer addSubview:chooseFiltersCheckbox];
    UIScrollView *scrollView = (UIScrollView *)self.chooseFiltersCheckboxContainer;
    scrollView.contentSize = CGSizeMake(0, chooseFiltersCheckbox.frame.size.height + 20);
    [scrollView.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [scrollView.layer setBorderWidth: 2.0];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chooseFiltersUpdate:) name:GROUP_CHANGED object:chooseFiltersCheckbox];
}


- (void)chooseFiltersUpdate:(NSNotification *)notification {
    
    
    [modelController.filterNamesChosen removeAllObjects];
    TNCheckBoxGroup *chooseFiltersCheckbox = notification.object;
    
    for (TNRectangularCheckBoxData *checkboxData in chooseFiltersCheckbox.checkedCheckBoxes)
    {
        [modelController.filterNamesChosen addObject:checkboxData.identifier];
    }
    
    UINavigationController *navigationController = (UINavigationController *)self.sidePanelController.centerPanel;
    CarouselViewController *carouselController = [navigationController.viewControllers objectAtIndex:0];

    [carouselController.carousel performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
    
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        [carouselController.carousel reloadData];
    //    });
}


- (IBAction)squareSizeChanged:(UISegmentedControl *)sender {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navigationController = (UINavigationController *)self.sidePanelController.centerPanel;
        CarouselViewController *carouselController = [navigationController.viewControllers objectAtIndex:0];
        
        modelController.image = [modelController generateImageFromSubimages:modelController.subImages];
        
        switch (sender.selectedSegmentIndex)
        {
            case 0:
                modelController.gridSquareSize = 40;
                break;
            case 1:
                modelController.gridSquareSize = 80;
                break;
            case 2:
                modelController.gridSquareSize = 160;
                break;
            case 3:
                modelController.gridSquareSize = 320;
            default:
                break;
        }

        
        modelController.originalSubImages = [modelController divideImage:modelController.originalImage withSquareSize:modelController.gridSquareSize andPutInView:carouselController.scrollView];
        
        modelController.subImages = [modelController divideImage:modelController.image withSquareSize:modelController.gridSquareSize andPutInView:carouselController.scrollView];
        
        [modelController addGestureRecognizersToSubviewsFromView:carouselController.scrollView andViewController:carouselController];
    });
}
- (IBAction)applyGrid:(UIButton *)sender {
    UINavigationController *navigationController = (UINavigationController *)self.sidePanelController.centerPanel;
    CarouselViewController *carouselController = [navigationController.viewControllers objectAtIndex:0];
    
    [modelController putBorderWithWidth:BLACK_BORDER_WIDTH aroundImageViewsFromView:carouselController.scrollView];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
