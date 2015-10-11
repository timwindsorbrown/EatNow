//
//  ConnectionManager.h
//  EatNow
//
//  Created by Tim Windsor Brown on 10/10/2015.
//  Copyright © 2015 ExNihilo. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@interface ConnectionManager : NSObject

+ (void) requestPlacesNearMe:(CLLocationCoordinate2D)coordinate
              googleMapsType:(NSString*)type
                      radius:(float)radius
                  completion:(void (^)(NSArray* places))completionBlock
                  errorBlock:(void (^)(NSError* error))errorBlock;

@end
