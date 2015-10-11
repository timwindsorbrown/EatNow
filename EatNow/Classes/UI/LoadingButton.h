//
//  LoadingButton.h
//  EatNow
//
//  Created by Tim Windsor Brown on 10/10/2015.
//  Copyright © 2015 ExNihilo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingButton : UIButton
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

- (void) showLoading:(BOOL)show;

@end
