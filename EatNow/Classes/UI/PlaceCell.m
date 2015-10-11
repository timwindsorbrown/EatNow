//
//  PlaceCell.m
//  EatNow
//
//  Created by Tim Windsor Brown on 10/10/2015.
//  Copyright © 2015 ExNihilo. All rights reserved.
//

#import "PlaceCell.h"

@implementation PlaceCell

- (void) setupWithPlace:(PlaceAnnotation*)place
{
    self.nameLabel.text = place.name;
    self.ratingLabel.text = place.rating.length ? [NSString stringWithFormat:@"%@ / 5.0", place.rating] : @"";
}

@end
