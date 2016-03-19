//
//  FSQOptionsViewController.m
//  Squareness
//
//  Created by Stefan Stolevski on 7/12/14.
//  Copyright (c) 2014 Stefan Stolevski. All rights reserved.
//

#import "FSQOptionsViewController.h"
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"
#import "CarouselViewController.h"
#import "TNCheckBoxGroup.h"


@interface FSQOptionsViewController ()
@property (nonatomic, strong) FSQModelController *sharedModel;
@end

@implementation FSQOptionsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createChooseFiltersCheckbox];
}



- (void)createChooseFiltersCheckbox{

    NSMutableArray *filtersData = [[NSMutableArray alloc] initWithCapacity:self.sharedModel.filterNamesUI.count];
    
    for (int i = 0; i < self.sharedModel.filterNamesUI.count; i++)
    {
        TNRectangularCheckBoxData *checkboxData = [[TNRectangularCheckBoxData alloc] init];
        checkboxData.identifier = [self.sharedModel.filterNamesCI objectAtIndex:i];
        checkboxData.labelText = [self.sharedModel.filterNamesUI objectAtIndex:i];
        checkboxData.labelColor = [UIColor darkGrayColor];
        checkboxData.borderColor = [UIColor darkGrayColor];
        checkboxData.rectangleColor = [UIColor darkGrayColor];
        checkboxData.borderWidth = checkboxData.borderHeight = 20;
        checkboxData.rectangleWidth = checkboxData.rectangleHeight = 15;
        
        if([self.sharedModel.filterNamesChosen containsObject:checkboxData.identifier])
        {
            checkboxData.checked = YES;
        }
        else
        {
            checkboxData.checked = NO;
        }
        
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
    
    FSQModelController *sharedModel = [FSQModelController sharedInstance];
    [sharedModel.filterNamesChosen removeAllObjects];
    TNCheckBoxGroup *chooseFiltersCheckbox = notification.object;
    
    for (TNRectangularCheckBoxData *checkboxData in chooseFiltersCheckbox.checkedCheckBoxes)
    {
        [sharedModel.filterNamesChosen addObject:checkboxData.identifier];
    }
    
    UINavigationController *navigationController = (UINavigationController *)self.sidePanelController.centerPanel;
    CarouselViewController *carouselController = [navigationController.viewControllers objectAtIndex:0];

    [carouselController.carousel performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
    
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        [carouselController.carousel reloadData];
    //    });
}


- (IBAction)squareSizeChanged:(UISegmentedControl *)sender {
    
    FSQModelController *sharedModel = [FSQModelController sharedInstance];
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *navigationController = (UINavigationController *)self.sidePanelController.centerPanel;
        CarouselViewController *carouselController = [navigationController.viewControllers objectAtIndex:0];
        
        sharedModel.image = [sharedModel generateImageFromSubimages:sharedModel.subImages];
        
        switch (sender.selectedSegmentIndex)
        {
            case 0:
                sharedModel.gridSquareSize = 40;
                break;
            case 1:
                sharedModel.gridSquareSize = 80;
                break;
            case 2:
                sharedModel.gridSquareSize = 160;
                break;
            case 3:
                sharedModel.gridSquareSize = 320;
            default:
                break;
        }

        
        sharedModel.originalSubImages = [sharedModel divideImage:sharedModel.originalImage withSquareSize:sharedModel.gridSquareSize andPutInView:carouselController.scrollView];
        
        sharedModel.subImages = [sharedModel divideImage:sharedModel.image withSquareSize:sharedModel.gridSquareSize andPutInView:carouselController.scrollView];
        
        [sharedModel addGestureRecognizersToSubviewsFromView:carouselController.scrollView andViewController:carouselController];
    });
}
- (IBAction)applyGrid:(UIButton *)sender {
     FSQModelController *sharedModel = [FSQModelController sharedInstance];
    UINavigationController *navigationController = (UINavigationController *)self.sidePanelController.centerPanel;
    CarouselViewController *carouselController = [navigationController.viewControllers objectAtIndex:0];
    
    [sharedModel putBorderWithWidth:BLACK_BORDER_WIDTH aroundImageViewsFromView:carouselController.scrollView];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
