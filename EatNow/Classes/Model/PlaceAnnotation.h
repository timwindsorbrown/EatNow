//
//  Place.h
//  EatNow
//
//  Created by Tim Windsor Brown on 10/10/2015.
//  Copyright © 2015 ExNihilo. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <Foundation/Foundation.h>

@interface PlaceAnnotation : MKPointAnnotation <MKAnnotation>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *rating;

@end
