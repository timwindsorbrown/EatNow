//
//  LoadingButton.m
//  EatNow
//
//  Created by Tim Windsor Brown on 10/10/2015.
//  Copyright © 2015 ExNihilo. All rights reserved.
//

#import "LoadingButton.h"

@implementation LoadingButton

- (void) showLoading:(BOOL)show {
    
    
    if (show) {
        
        [self.spinner startAnimating];
        [UIView animateWithDuration:0.2f animations:^{
            
            self.spinner.alpha = 1;
            
        }];
    }
    else {
        
        [UIView animateWithDuration:0.2f animations:^{
            
            self.spinner.alpha = 0;
            
        } completion:^(BOOL finished) {
            
            [self.spinner stopAnimating];
            
        }];
    }
}

@end
