//
//  CustomView.m
//  Squareness
//
//  Created by Stefan Stolevski on 10/21/14.
//  Copyright (c) 2014 Stefan Stolevski. All rights reserved.
//

#import "CustomView.h"

@implementation CustomView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+ (id)customView
{
    CustomView *customView = [[[NSBundle mainBundle] loadNibNamed:@"CustomView" owner:nil options:nil] lastObject];
    
    // make sure customView is not nil or the wrong class!
    if ([customView isKindOfClass:[CustomView class]])
        return customView;
    else
        return nil;
}
@end
