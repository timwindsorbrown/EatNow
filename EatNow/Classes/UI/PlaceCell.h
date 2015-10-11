//
//  PlaceCell.h
//  EatNow
//
//  Created by Tim Windsor Brown on 10/10/2015.
//  Copyright © 2015 ExNihilo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaceAnnotation.h"

@interface PlaceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;

- (void) setupWithPlace:(PlaceAnnotation*)place;

@end
